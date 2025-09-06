require("dotenv").config();
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const cors = require("cors")({ origin: true });

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

console.log("Firestore projectId (resolved):", admin.app().options.projectId);

exports.fetchWebFaaShifts = onCall(
  { timeoutSeconds: 300, memory: "1GiB", region: "us-central1" },
  async (request) => {
    const puppeteer = require("puppeteer-core");
    const chromium = require("@sparticuz/chromium");

    const { username, password, periodId, cookies } = request.data || {};
    if (!username || !password) {
      throw new HttpsError(
        "invalid-argument",
        "Username and password are required"
      );
    }

    let browser;

    try {
      let launchOptions;

      if (process.env.FUNCTIONS_EMULATOR) {
        // Local development
        const chromePath =
          "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"; // adjust if needed
        launchOptions = {
          executablePath: chromePath,
          headless: false,
          args: ["--no-sandbox", "--disable-setuid-sandbox"],
          defaultViewport: null,
        };
      } else {
        // Deployed Gen2 function
        launchOptions = {
          args: chromium.args,
          defaultViewport: chromium.defaultViewport,
          executablePath: await chromium.executablePath(),
          headless: chromium.headless,
        };
      }

      browser = await puppeteer.launch(launchOptions);
      const page = await browser.newPage();

      // --- Login helper ---
      const login = async () => {
        await page.goto("https://wmtscheduler.faa.gov/gatekeeper", {
          waitUntil: "networkidle2",
        });

        await Promise.all([
          page.click("#btnLogin"),
          page
            .waitForNavigation({
              waitUntil: "networkidle2",
              timeout: 15000,
            })
            .catch(() => {}),
        ]);

        const usernameFieldFound = await page
          .waitForSelector('input[name="identifier"]', {
            visible: true,
            timeout: 40000,
          })
          .then(() => true)
          .catch(() => false);

        if (!usernameFieldFound) {
          const code = await page
            .$eval(".widget .error-code", (el) => el.innerText)
            .catch(() => "403");
          const message = await page
            .$eval(".widget .o-form-title", (el) => el.innerText)
            .catch(() => "Access Forbidden");
          throw new HttpsError(
            "permission-denied",
            `${code} Error: ${message}`
          );
        }

        await page.type('input[name="identifier"]', username, { delay: 100 });
        await Promise.all([
          page.click('input[type="submit"][value="Next"]'),
          page.waitForSelector('input[name="credentials.passcode"]', {
            visible: true,
            timeout: 40000,
          }),
        ]);

        await page.type('input[name="credentials.passcode"]', password, {
          delay: 100,
        });
        await page.click('input[type="submit"][value="Verify"]');
        await new Promise((r) => setTimeout(r, 2000));

        const errorMessage = await page
          .$eval(".o-form-error-container", (el) => el.innerText.trim())
          .catch(() => "");
        if (errorMessage) {
          throw new HttpsError("unauthenticated", errorMessage);
        }
      };

      // --- Use client cookies if available ---
      if (cookies && Array.isArray(cookies)) {
        console.log("Using client-provided cookies");
        await page.setCookie(...cookies);
      } else {
        console.log("No cookies provided, logging in...");
        await login();
      }

      // --- Option 1: No periodId (initial call) ---
      if (!periodId) {
        await page.goto("https://wmtscheduler.faa.gov/Views/MySchedule", {
          waitUntil: "networkidle2",
        });

        const { scheduleData, payPeriods } = await page.evaluate(() => {
          const table = document.querySelector('table[border="1"]');
          let scheduleData = [];
          if (table) {
            scheduleData = Array.from(table.querySelectorAll("tbody tr"))
              .flatMap((row) =>
                Array.from(row.querySelectorAll("td")).map((cell) => {
                  const lines = cell.innerText
                    .split("\n")
                    .map((l) => l.trim())
                    .filter(Boolean);
                  return lines.length >= 2
                    ? { day: lines[0], date: lines[1], code: lines[2] || "" }
                    : null;
                })
              )
              .filter(Boolean);
          }

          const select = document.querySelector("#PayPeriodId");
          let payPeriods = [];
          if (select) {
            const all = Array.from(select.options).map((opt) => ({
              value: opt.value,
              selected: opt.selected || false,
            }));
            const selectedIndex = all.findIndex((opt) => opt.selected);
            payPeriods = all.slice(selectedIndex);
          }
          return { scheduleData, payPeriods };
        });

        if (!scheduleData || scheduleData.length === 0) {
          throw new HttpsError(
            "not-found",
            "Schedule table not found or empty"
          );
        }

        const newCookies = (await page.cookies()).map(c => ({
          name: c.name,
          value: c.value,
          domain: c.domain,
          path: c.path,
          secure: c.secure,
          httpOnly: c.httpOnly,
          sameSite: c.sameSite,
          expires: c.expires,
        }));

        return { schedule: scheduleData, payPeriods, cookies: newCookies };
      }

      // --- Option 2: Specific pay period ---
      else {
        await page.goto(
          `https://wmtscheduler.faa.gov/Views/MySchedule/OnGet?PayPeriodId=${periodId}`,
          { waitUntil: "networkidle2" }
        );

        if (page.url().includes("oauth2")) {
          console.log("Cookies expired, logging in again...");
          await login();
          await page.goto(
            `https://wmtscheduler.faa.gov/Views/MySchedule/OnGet?PayPeriodId=${periodId}`,
            { waitUntil: "networkidle2" }
          );
        }

        const scheduleData = await page.evaluate(() => {
          const table = document.querySelector('table[border="1"]');
          if (!table) return [];
          return Array.from(table.querySelectorAll("tbody tr"))
            .flatMap((row) =>
              Array.from(row.querySelectorAll("td")).map((cell) => {
                const lines = cell.innerText
                  .split("\n")
                  .map((l) => l.trim())
                  .filter(Boolean);
                return lines.length >= 2
                  ? { day: lines[0], date: lines[1], code: lines[2] || "" }
                  : null;
              })
            )
            .filter(Boolean);
        });

        if (!scheduleData || scheduleData.length === 0) {
          throw new HttpsError(
            "not-found",
            "Schedule table not found or empty"
          );
        }

        const newCookies = (await page.cookies()).map(c => ({
          name: c.name,
          value: c.value,
          domain: c.domain,
          path: c.path,
          secure: c.secure,
          httpOnly: c.httpOnly,
          sameSite: c.sameSite,
          expires: c.expires,
        }));

        return { schedule: scheduleData, payPeriod: periodId, cookies: newCookies };
      }
    } catch (err) {
      console.error("Error in fetchWebFaaShifts:", err);
      if (err instanceof HttpsError) throw err;
      throw new HttpsError("internal", err.message || "Internal error");
    } finally {
      if (browser) await browser.close();
    }
  }
);

// --- Delete account endpoint ---
exports.deleteAccountWeb = onRequest(async (req, res) => {
  cors(req, res, async () => {
    if (req.method === "OPTIONS") return res.status(204).send("");
    if (req.method !== "POST") return res.status(405).send("Method not allowed");

    const { email, password } = req.body || {};
    if (!email || !password)
      return res.status(400).send("Email and password required.");

    try {
      const fetch = (await import("node-fetch")).default;
      const apiKey = process.env.APP_API_KEY;
      if (!apiKey) return res.status(500).send("API key not configured");

      const resp = await fetch(
        `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ email, password, returnSecureToken: true }),
        }
      );

      const data = await resp.json();
      if (!resp.ok)
        return res.status(401).send(data.error?.message || "Invalid credentials");

      const uid = data.localId;

      await admin.auth().deleteUser(uid).catch(() => {});
      await admin
        .firestore()
        .collection("users")
        .doc(uid)
        .delete()
        .catch(() => {});

      return res.status(200).send("Account successfully deleted.");
    } catch (err) {
      console.error("Error in deleteAccountWeb:", err);
      return res.status(500).send(`Internal server error: ${err.message}`);
    }
  });
});

require("dotenv").config();
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const functions = require("firebase-functions");

const cors = require("cors")({ origin: true });

if (!admin.apps.length) {
  admin.initializeApp();
}

exports.fetchFaaShifts = onCall(
  { timeoutSeconds: 300, memory: "1GiB" },
  async (request) => {
    const puppeteer = require("puppeteer-core");
    const chromium = require("@sparticuz/chromium");

    const { username, password } = request.data || {};
    if (!username || !password) {
      throw new HttpsError("invalid-argument", "Username and password are required");
    }

    let browser;
    try {
      // Launch options
      const launchOptions = {
        args: chromium.args,
        defaultViewport: chromium.defaultViewport,
        executablePath: await chromium.executablePath(),
        headless: chromium.headless,
      };

      browser = await puppeteer.launch(launchOptions);
      const page = await browser.newPage();

      // 1. Open gatekeeper
      await page.goto("https://wmtscheduler.faa.gov/gatekeeper", { waitUntil: "networkidle2" });

      // 2. Click login button
      await Promise.all([
        page.click("#btnLogin"),
        page.waitForNavigation({ waitUntil: "networkidle2", timeout: 15000 }).catch(() => {})
      ]);

      // 3. Wait for username field or detect 403
      const usernameFieldFound = await page.waitForSelector('input[name="identifier"]', { visible: true, timeout: 40000 })
        .then(() => true)
        .catch(() => false);

      if (!usernameFieldFound) {
        const code = await page.$eval(".widget .error-code", el => el.innerText).catch(() => "403");
        const message = await page.$eval(".widget .o-form-title", el => el.innerText).catch(() => "Access Forbidden");
        throw new HttpsError("permission-denied", `${code} Error: ${message}`);
      }

      // 4. Fill username
      await page.type('input[name="identifier"]', username, { delay: 100 });
      await Promise.all([
        page.click('input[type="submit"][value="Next"]'),
        page.waitForSelector('input[name="credentials.passcode"]', { visible: true, timeout: 40000 }),
      ]);

      // 5. Fill password
      await page.type('input[name="credentials.passcode"]', password, { delay: 100 });
      await page.click('input[type="submit"][value="Verify"]');

      // Wait a short moment for the error div to update
      await new Promise(resolve => setTimeout(resolve, 2000));

      // 6. Check for sign-in error
      const errorMessage = await page.$eval('.o-form-error-container', el => el.innerText.trim())
        .catch(() => ''); // If div not found, treat as empty

      if (errorMessage.length > 0) {
        throw new HttpsError('unauthenticated', errorMessage);
      }
      // 7. Navigate to schedule page
      await page.goto("https://wmtscheduler.faa.gov/Views/MySchedule", { waitUntil: "networkidle2" });

      // 8. Parse schedule table
      const scheduleData = await page.evaluate(() => {
        const table = document.querySelector('table[border="1"]');
        if (!table) return null;

        return Array.from(table.querySelectorAll("tbody tr"))
          .flatMap(row => Array.from(row.querySelectorAll("td")).map(cell => {
            const lines = cell.innerText.split("\n").map(l => l.trim()).filter(Boolean);
            return lines.length >= 2
              ? { day: lines[0] || "", date: lines[1] || "", code: lines[2] || "" }
              : null;
          }))
          .filter(Boolean);
      });

      if (!scheduleData || scheduleData.length === 0) {
        throw new HttpsError("not-found", "Schedule table not found or empty");
      }

      return { schedule: scheduleData };

    } catch (err) {
      console.error("Error in fetchWebFaaSchedule:", err);
      if (err instanceof HttpsError) throw err;
      throw new HttpsError("internal", err.message || "Internal error");
    } finally {
      if (browser) await browser.close();
    }
  }
);

exports.deleteAccountWeb = onRequest(async (req, res) => {
  cors(req, res, async () => {
    if (req.method === "OPTIONS") return res.status(204).send("");

    if (req.method !== "POST") return res.status(405).send("Method not allowed");

    const { email, password } = req.body || {};
    if (!email || !password) return res.status(400).send("Email and password required.");

    try {
      const fetch = (await import("node-fetch")).default;
      const apiKey = process.env.APP_API_KEY; // renamed variable
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
      if (!resp.ok) return res.status(401).send(data.error?.message || "Invalid credentials");

      const uid = data.localId;

      await admin.auth().deleteUser(uid).catch(() => {});
      await admin.firestore().collection("users").doc(uid).delete().catch(() => {});

      return res.status(200).send("Account successfully deleted.");
    } catch (err) {
      console.error("Error in deleteAccountWeb:", err);
      return res.status(500).send(`Internal server error: ${err.message}`);
    }
  });
});
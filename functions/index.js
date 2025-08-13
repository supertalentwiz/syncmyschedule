const puppeteer = require("puppeteer-core");
const chromium = require("@sparticuz/chromium");
const { onCall } = require("firebase-functions/v2/https");

exports.fetchWebFaaSchedule = onCall(
  {
    timeoutSeconds: 300,
    memory: "1GiB",
  },
  async (request) => {
    const { username, password } = request.data || {};
    if (!username || !password) {
      throw new Error("Username and password are required");
    }

    let browser;
    try {
      browser = await puppeteer.launch({
        args: chromium.args,
        defaultViewport: chromium.defaultViewport,
        executablePath: await chromium.executablePath(),
        headless: chromium.headless,
      });

      const page = await browser.newPage();

      console.log("Going to Gatekeeper...");
      await page.goto("https://wmtscheduler.faa.gov/gatekeeper", {
        waitUntil: "networkidle2",
      });

      // Click login button and wait for login input or 403 error
      await page.click("#btnLogin");

      await Promise.race([
        page.waitForSelector('input[name="identifier"]', { visible: true, timeout: 40000 }),
        page.waitForSelector('.widget .error-code', { visible: true, timeout: 5000 }),
      ]);

      const is403Error = await page.$eval('.widget .error-code', el => el.innerText).catch(() => null);
      if (is403Error === '403') {
        const errorMessage = await page.$eval('.widget .o-form-title', el => el.innerText).catch(() => 'Access Forbidden');
        throw new Error(`403 Error: ${errorMessage}`);
      }

      // Fill username and click Next
      await page.type('input[name="identifier"]', username, { delay: 100 });
      await Promise.all([
        page.click('input[type="submit"][value="Next"]'),
        page.waitForSelector('input[name="credentials.passcode"]', {
          visible: true,
          timeout: 40000,
        }),
      ]);

      // Fill password and click Verify
      await page.type('input[name="credentials.passcode"]', password, {
        delay: 100,
      });
      await Promise.all([
        page.click('input[type="submit"][value="Verify"]'),
        page.waitForNavigation({
          waitUntil: "networkidle2",
          timeout: 60000,
        }),
      ]);

      // Check for "Unable to sign in" error after Verify
      const signInError = await page.$eval('.o-form-error-container[role="alert"] p', el => el.innerText).catch(() => null);
      if (signInError) {
        throw new Error(`Sign-in Error: ${signInError}`);
      }

      // Go to schedule page
      await page.goto("https://wmtscheduler.faa.gov/Views/MySchedule", {
        waitUntil: "networkidle2",
      });

      const scheduleData = await page.evaluate(() => {
        const scheduleTable = document.querySelector('table[border="1"]');
        if (!scheduleTable) return null;

        const rows = Array.from(scheduleTable.querySelectorAll("tbody tr"));
        const schedule = [];

        rows.forEach((row) => {
          const cells = Array.from(row.querySelectorAll("td"));
          cells.forEach((cell) => {
            const lines = cell.innerText
              .split("\n")
              .map((l) => l.trim())
              .filter((l) => l.length > 0);
            if (lines.length >= 3) {
              schedule.push({
                day: lines[0],
                date: lines[1],
                code: lines[2],
              });
            }
          });
        });

        return schedule;
      });

      if (!scheduleData) {
        throw new Error("Schedule table not found");
      }

      return { schedule: scheduleData };
    } catch (err) {
      console.error("Error in fetchFaaSchedule:", err);
      throw new Error(err.message || "Internal error");
    } finally {
      if (browser) {
        await browser.close();
      }
    }
  }
);

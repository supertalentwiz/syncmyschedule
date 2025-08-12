const functions = require("firebase-functions");
const puppeteer = require("puppeteer");

exports.fetchFaaSchedule = functions.https.onCall(async (data, context) => {
  const { username, password } = data.data || data;

  if (!username || !password) {
    throw new functions.https.HttpsError('invalid-argument', 'Username and password are required');
  }

  const browser = await puppeteer.launch({
    args: ['--no-sandbox', '--disable-setuid-sandbox'], // Firebase env settings
    headless: true,
  });

  try {
    const page = await browser.newPage();

    // 1. Go to Gatekeeper page
    console.log('Going to Gatekeeper...');
    await page.goto('https://wmtscheduler.faa.gov/gatekeeper', { waitUntil: 'networkidle2' });
    console.log('Loaded Gatekeeper page');

    // 2. Click the "Login" button (input with id=btnLogin)
    await Promise.all([
      page.click('#btnLogin'),
      page.waitForSelector('input[name="identifier"]', { visible: true, timeout: 40000 }),
    ]);
    console.log('Clicked login button and loaded login page');

    // 3. On Okta login page, enter username/email, click Next
    await page.type('input[name="identifier"]', username, { delay: 100 });
    await Promise.all([
      page.click('input[type="submit"][value="Next"]'),
      page.waitForSelector('input[name="credentials.passcode"]', { visible: true, timeout: 40000 }),
    ]);
    console.log('Entered username and loaded password page');

    // 4. Enter password on next page, click Verify
    await page.type('input[name="credentials.passcode"]', password, { delay: 100 });
    await Promise.all([
      page.click('input[type="submit"][value="Verify"]'),
      page.waitForNavigation({ waitUntil: 'networkidle2', timeout: 60000 }),
    ]);
    console.log('Entered password and redirected to main dashboard');

    // 5. Navigate explicitly to MySchedule page to get schedule table
    await page.goto('https://wmtscheduler.faa.gov/Views/MySchedule', { waitUntil: 'networkidle2' });
    console.log('Loaded MySchedule page');

    // 6. Extract the schedule table content
    const scheduleData = await page.evaluate(() => {
      const scheduleTable = document.querySelector('table[border="1"]');
      if (!scheduleTable) return null;

      const rows = Array.from(scheduleTable.querySelectorAll('tbody tr'));
      const schedule = [];

      rows.forEach(row => {
        const cells = Array.from(row.querySelectorAll('td'));
        cells.forEach(cell => {
          const lines = cell.innerText.split('\n').map(l => l.trim()).filter(l => l.length > 0);
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
      throw new functions.https.HttpsError('not-found', 'Schedule table not found');
    }

    await browser.close();

    return { schedule: scheduleData };
  } catch (error) {
    await browser.close();
    console.error('Error in fetchFaaSchedule:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

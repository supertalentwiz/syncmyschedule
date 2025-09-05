const fetch = require("node-fetch");

async function testFetch(username, password, periodId, cookies) {
  // Build the request body
  const body = { data: { username, password } };
  if (periodId) body.data.periodId = periodId;
  if (cookies) body.data.cookies = cookies; // include cookies if provided

  const res = await fetch(
    "http://127.0.0.1:5001/syncmyschedule-58722/us-central1/fetchWebFaaShifts",
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    }
  );

  try {
    const json = await res.json();

    // Firebase onCall responses come wrapped in { result: ... }
    if (json.result) {
      console.log("✅ Response:", JSON.stringify(json.result, null, 2));
      return json.result;
    } else {
      console.log("⚠️ Raw response:", JSON.stringify(json, null, 2));
      return json;
    }
  } catch (err) {
    console.error("❌ Failed to parse response:", err);
  }
}

// --- Usage example ---
(async () => {
  // First call: login and fetch schedule
  const first = await testFetch("daniel.m.correia", "Wjourney25!");

  // Second call: reuse cookies from first response
  if (first && first.cookies) {
    await testFetch("daniel.m.correia", "Wjourney25!", first.payPeriods?.[0]?.value, first.cookies);
  }
})();

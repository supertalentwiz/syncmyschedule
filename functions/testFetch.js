const fetch = require("node-fetch");

async function testFetch(username, password, periodId) {
  const body = { data: { username, password } };
  if (periodId) body.data.periodId = periodId;

  const res = await fetch(
    "http://127.0.0.1:5001/syncmyschedule-58722/us-central1/fetchFaaShifts",
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    }
  );

  try {
    const json = await res.json();
    console.log("Response:", JSON.stringify(json, null, 2));
  } catch (err) {
    console.error("Failed to parse response:", err);
  }
}

// Replace with test FAA credentials
testFetch("daniel.m.correia", "Wjourney25!");

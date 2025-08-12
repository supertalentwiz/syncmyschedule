// functions/index.js
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// A simple callable function that returns mock schedule JSON
exports.fetchScheduleMock = functions.https.onCall(async (data, context) => {
  // data: { userId, optional: debug }
  // NOTE: For Milestone 1 this returns mock data so you don't touch FAA systems
  const mock = [
    { date: "2025-08-12", code: "0700AWS", start: "07:00", end: "15:00" },
    { date: "2025-08-14", code: "SL", allDay: true }
  ];
  return { success: true, schedule: mock };
});

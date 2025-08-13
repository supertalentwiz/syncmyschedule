# FAA Compliance Checklist (M1)

## Credential & Data Security
- [x] No remote credential storage (MVP).
- [x] Plan to use flutter_secure_storage for local (M2).
- [x] All traffic HTTPS.

## User-Initiated Automation
- [x] No background fetches; function callable only when user taps "Fetch".
- [x] No timers/schedules.

## Branding & Representation
- [x] No FAA logos or marks.
- [x] Disclaimer: "Not affiliated with or endorsed by the FAA."

## User Disclosure
- [x] First-launch modal requires acceptance.
- [x] Disclose automation mimics manual web access.
- [x] Inform credentials used only to log in and fetch schedule.

## Headless Browser (Puppeteer)
- [x] Stub exists; real login added in M2.
- [x] Scope limited to user's own schedule.
- [x] Respect load times; single fetch per tap.

## Legal Review
- [x] FAA Terms reviewed (links to be added).
- [x] CFAA risk considered; user-auth only.
- [x] Gatekeeper notice to be captured in M2 test screenshots.

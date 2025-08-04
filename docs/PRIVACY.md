# Privacy

OracleLight is designed to respect user privacy. All personal data, including
mood entries, settings and rule events, is stored locally on the user's
device in an AES‑256‑GCM encrypted SQLite database. The encryption key is
randomly generated on first launch and stored in the iOS Keychain using
`kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`, ensuring it never leaves the
device.

The app does **not** perform any network requests or use analytics services.
Crash reporting is optional and uses Apple’s built‑in `OSLog` and log
collection mechanisms. The App Privacy Manifest declares that no data is
collected.

During onboarding the user is presented with a privacy oath explaining how
their data is handled. Notification permissions are requested on a provisional
basis and escalated only if the user declines, in line with Apple’s
best practice guidance for respectful permission prompts.
# Security

OracleLight employs multiple layers of security to protect user data and the
integrity of the application:

## Database Encryption

* All persistent data is stored in `oracledb.sqlite`, an SQLite file encrypted
  using SQLCipher’s AES‑256‑GCM algorithm via GRDB.
* A 256‑bit random encryption key is generated on first launch and persisted
  securely in the iOS Keychain using the `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`
  accessibility class. The key never leaves the device.
* Database reads and writes are performed through GRDB’s `DatabasePool` which
  serialises access and supports SQLCipher transparently.

## Secret Management

* Build secrets and signing keys are managed via fastlane match and GitHub
  Actions secrets. Secret scanning is enabled through GitHub Advanced
  Security to prevent accidental disclosure.
* The repository includes a `.gitignore` that excludes derived data and
  credentials.

## Static Analysis

* SwiftLint and SwiftFormat are integrated as build plugins to enforce
  consistent style and catch common issues early.
* Xcode’s built‑in analyser is run as part of the CI pipeline.

## Networking

* The application intentionally contains **no network code**. All features
  operate entirely on device, eliminating the risk of unauthorised data
  exfiltration or man‑in‑the‑middle attacks.

## Crash Reporting

* Crash reporting is opt‑in. When enabled by the user, logs are collected via
  Apple’s `OSLog` and `log collect` tools. No third‑party crash analytics
  services are used, ensuring that logs remain on device and under the user’s
  control.
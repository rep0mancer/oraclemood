# Architecture

OracleLight is structured using the Model‑View‑ViewModel (MVVM) pattern and
leverages modern SwiftUI, Combine and Swift Concurrency features. The design
separates concerns cleanly and promotes testability.

## Layers

### Models

The models (`MoodEntry`, `Settings`, `RuleEvent`, `Mood`, `Palette`, etc.) are
simple `Codable` structs and enums. Persistent models conform to GRDB’s
`MutablePersistableRecord` and `FetchableRecord` to provide automatic
mapping to the encrypted database.

### Services

`DatabaseService` encapsulates all database access. It sets up the encrypted
SQLite database using GRDB and SQLCipher, defines migrations and exposes
async CRUD methods. `KeychainService` manages the encryption key in the
Keychain.

### Actors

Three actors orchestrate business logic:

* **MoodStore** — An `ObservableObject` that publishes mood entries via
  `@Published`. It writes to the database and refreshes itself after each
  insert.
* **RuleEngine** — Evaluates mood sequences to trigger praise or advisory
  notifications. It inserts `RuleEvent` records and schedules local
  notifications.
* **PromptScheduler** — Computes a day’s worth of notification requests each
  night at 02:00, respecting the minimum interval between prompts and
  avoiding conflicts with manual mood entries.

These actors use Swift Concurrency to ensure all database writes occur off
the main thread and to prevent race conditions.

### Views

All UI is built with SwiftUI. `OracleLightApp` loads settings and decides
whether to present the onboarding flow or the main `HomeView`. The
onboarding flow contains three subviews: a privacy oath, prompt schedule
editor and palette selector. `HomeView` presents daily, weekly and monthly
charts using the Swift Charts framework. The settings screen allows the
user to edit prompt times, change the minimum interval, select a palette,
export data, view legal documents and purchase the app via StoreKit.

### Live Activity

The app uses ActivityKit to display a mood selection Live Activity in the
Dynamic Island and on the Lock Screen. The user can quickly tap a mood glyph
from the Live Activity, which writes the mood to the database and ends the
activity.

## Concurrency

Swift Concurrency and actors ensure that long‑running operations such as
database writes, rule evaluation and notification scheduling do not block the
main thread. Combine is used in the `MoodStore` to publish changes to the
UI.
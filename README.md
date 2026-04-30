# Container

A SwiftUI screen architecture for Swift 5.9+ / iOS 17+ that splits each feature into **Model**, **Content**, and **Display** layers, wired together by a small **`ScreenContainer`** type in the **Container** Swift package. The example app (**ContainerExample**) shows multi-tab navigation, typed routes, and stub deep linking.

## Repository layout

- **`Sources/Container/`** — The **Container** library. The only UI building block you typically import is **`ScreenContainer`**, which connects an observable model to a pure content mapper and a display view.
- **`Example/ContainerExample/`** — Demo app: **Landing**, **LaunchTimes**, **ProductGallery**, plus **NavRouter**, **AppShellView**, **Navigation/FlowRoutes.swift**, and **ContentView** as the app root.

Add the package to an Xcode target (local path or SPM) and `import Container` wherever you define a screen that uses `ScreenContainer`.

## The three layers

Every example screen follows the same separation of concerns:

| Layer | Role | Typical contents |
| ----- | ---- | ---------------- |
| **Model** | Owns mutable **state**, **navigation intents**, **dependencies** (services, loaders), and **async work** (loads, mutations). Marked `@MainActor` and `@Observable` so SwiftUI can subscribe to changes. | `struct State`, optional `struct Navigation`, `func load…() async`, injected `fetcher` / `imageLoader`, etc. |
| **Content** | A **value type** (often a `struct`) plus a **pure** `buildContent(from: Model) -> Content` function. Maps model state into everything the UI needs to **render**, without side effects. No `View` types, no SwiftUI in the mapper beyond what’s unavoidable. | `YourScreenContent` with `let` fields; static `buildContent(from:)` on a feature `enum` namespace. |
| **Display** | SwiftUI **views** that take **`Content`** (and only touch **Model** when unavoidable—for example binding actions or reading `@Environment(\.navRouter)`). Should **not** embed business rules or network calls; it **lays out** what Content provides. | `struct Screen`, `struct Display`, `ScreenContainer(…)`, `.navigationTitle`, lists, buttons. |

**Why split this way?**

- **Testability**: Content mapping is a pure function of model state.
- **Predictability**: Async work and routing flags live in one place (Model or NavRouter).
- **Reuse**: The same Content could feed a different Display (e.g. compact vs regular) if needed.

The package type **`ScreenContainer`** implements the pipeline:

```22:24:Sources/Container/ScreenContainer.swift
    public var body: some View {
        display(mapContent(model))
    }
```

So at runtime: **model → `mapContent` → `Content` → `display(Content)` → SwiftUI tree**.

## `Screen` vs `Display`

In the example, each feature defines:

- **`Feature.Screen`** — Holds `@Bindable model`, builds `ScreenContainer(model:mapContent:display:)`, and attaches lifecycle modifiers (`.task`, `.refreshable`) that call **Model** methods. Sometimes uses `makeDisplay(content:)` to construct **Display** with extra dependencies.
- **`Feature.Display`** — Stateless (or nearly) UI from **`Content`**; uses **Model** only when the screen needs two-way actions (e.g. toggling `model.navigation.showLaunchTimes`).

When you only need one-way presentation, prefer **`@Environment(\.navRouter)`** and **`navRouter?.push(SomeRoute.detail)`** for navigation instead of pushing more flags through Model.

## How to add a new screen (step-by-step)

The following matches **ContainerExample** conventions (`Feature+Model.swift`, `Feature+Content.swift`, `Feature+Display.swift` under a feature folder).

### 1. Create the feature folder and files

Example: **`Example/ContainerExample/Settings/`**

- `Settings+Model.swift` — `extension Settings { @Observable final class Model { … } }`, `struct State`, etc.
- `Settings+Content.swift` — `struct SettingsScreenContent { … }` and `extension Settings { static func buildContent(from model: Model) -> SettingsScreenContent }`
- `Settings+Display.swift` — `enum Settings { }` (namespace), `Screen` + `Display` inside `extension Settings`

Use a **sentinel enum** `enum Settings {}` so `extension Settings` can hold `Model`, `Screen`, and static helpers without a bulky outer type.

### 2. Implement **Model**

- Mark the class **`@MainActor`**, **`@Observable`**.
- Put domain state in **`State`**; use **`Navigation`** (or similar) only for **cross-feature intents** that the app root observes (e.g. switching tabs), not for every pushed detail.
- Inject services via **`init(...)`** with defaults for previews.
- Expose **`async`** loaders/actors; call them from **`Screen`** with `.task` / `.refreshable`.

### 3. Implement **Content**

- Define **`YourScreenContent`** with **immutable** fields the Display needs.
- Implement **`YourFeature.buildContent(from: Model) -> YourScreenContent`** on `@MainActor` if it touches MainActor-isolated model types.
- **Do not** perform networking or mutate model here.

### 4. Implement **Display** and **Screen**

- **`Screen.body`**: `ScreenContainer(model: model, mapContent: YourFeature.buildContent(from:), display: makeDisplay(content:))` plus `.task` / `.refreshable` as needed.
- **`Display`**: Prefer `let content: YourScreenContent` only. Use **`NavigationStack`** only if this screen is a **root** elsewhere; in the example app, roots live inside **`AppShellView`**.
- For in-tab navigation, read **`@Environment(\.navRouter) private var navRouter`** and call **`navRouter?.push(MyRoute.something)`** (see [Navigation](#navigation)).

### 5. Register routes and stack (if the screen is pushed inside a tab)

- In **`Navigation/FlowRoutes.swift`**, add **`enum YourRoute: Hashable`** cases and conform to **`RoutedTab`** with **`static var mainTab`** pointing at the correct **`MainTab`**.
- In **`AppShellView`**, inside the right **`NavigationStack(path:)`**, add **`.navigationDestination(for: YourRoute.self) { … }`** and use your **`Feature.Screen`** (or a detail view) as needed.

### 6. Wire models at the app root

- In **`ContentView`**, add **`@State private var yourModel = YourFeature.Model()`**.
- Pass **`yourModel`** into **`AppShellView`** and into the stack where **`Your.Screen`** appears.

### 7. Add source files to Xcode

Add the new Swift files under **`Example/ContainerExample.xcodeproj`** (group + **Compile Sources** for **ContainerExample**).

### 8. (Optional) New tab

If the screen is its own tab:

- Add a **`MainTab`** case and extend **`CaseIterable`** ordering / **`tabBarOrder`** labels in **`FlowRoutes.swift`** (or wherever **`MainTab`** lives).
- In **`NavRouter`**, extend **`pathStorage`** initialization via **`MainTab.allCases`** and add **`var yourTabPath: NavigationPath`** computed accessors like the existing paths.
- In **`AppShellView`**, add another **`NavigationStack`** + **`ZStack`** branch and a **tab bar** button.

---

## Navigation

The example app does **not** use a single global `NavigationPath` for everything. Instead:

1. **`NavRouter`** (`Example/ContainerExample/NavRouter.swift`) holds **`selectedTab`** (`MainTab`) and one **`NavigationPath` per tab** (backed by **`pathStorage`**), plus APIs to change tab and mutate paths.
2. **`AppShellView`** builds a **custom tab bar** (not `TabView`) and a **`ZStack` of three `NavigationStack`s**—one per tab—so each flow keeps its own back stack while the tab bar stays stable.
3. **`RoutedTab`** (`FlowRoutes.swift`) ties each route enum (**`LandingRoute`**, **`LaunchesRoute`**, **`ProductsRoute`**) to a **`MainTab`**, so **`NavRouter`** can offer generic **`push`**, **`open`**, and **`replaceStack(with:)`** without per-tab copy-paste.

### Routing flow (mental model)

- **User taps a tab** → **`NavRouter.selectTab(_:)`** updates **`selectedTab`** with an **`easeInOut`** animation (no spring).
- **User taps an in-screen control** → **`navRouter?.push(SomeRoute.x)`** appends a **Hashable** route onto **that tab’s** path; SwiftUI’s **`navigationDestination(for:)`** presents the matching detail UI.
- **Deep link / cold open to a destination** → **`AppDeepLink.parse(url:)`** returns a value; **`NavRouter.apply(deepLink:)`** switches tab if needed and uses **`replaceStack(with:)`** so the stack is **reset** then **seeded** with one destination (good for URLs that imply a single canonical screen).

### `NavRouter` API (summary)

- **`selectTab(_:)`** — Change tab with the standard short ease-in-out transition.
- **`selectTab(_:animation:)`** — Supply an `Animation` or pass `nil` to update `selectedTab` without `withAnimation`.
- **`push<R: RoutedTab>(_ route: R)`** — Append on the route’s tab (user is usually already on that tab).
- **`open<R: RoutedTab>(_ route: R)`** — Select tab, then append (no stack clear).
- **`replaceStack<R: RoutedTab>(with route: R)`** — Select tab, replace path with a fresh stack containing **`route`** (used by deep links).
- **`apply(deepLink:)`** — Fan-out from **`AppDeepLink`**.
- **`syncCrossTabNavigation(landingModel:)`** — Reads legacy **Landing** flags and calls **`selectTab`** (example of feature-driven tab switch).

### Environment

**`AppShellView`** installs **`.environment(\.navRouter, navRouter)`**. Feature **Display** views use **`@Environment(\.navRouter) private var navRouter`** (optional **`NavRouter?`** for previews).

### Deep linking (design)

- **Scheme:** `container-example`
- **Parser:** **`AppDeepLink.parse(url:)`** in **`FlowRoutes.swift`** (extend for production universal links).
- **Delivery:** **`ContentView`** uses **`.onOpenURL`**; if **`parse`** returns non-`nil`, **`navRouter.apply(deepLink:)`** runs.
- **Registration:** **`Example/ContainerExample/Info.plist`** declares **`CFBundleURLTypes`** (scheme `container-example`). The **ContainerExample** target sets **`INFOPLIST_FILE`** and **`GENERATE_INFOPLIST_FILE = YES`**, so Xcode merges that plist with the generated entries (display name, scene manifest, etc.). Relying on **`INFOPLIST_KEY_CFBundleURLTypes`** alone may not produce **`CFBundleURLTypes`** in the built app, which leads to **`openurl`** failures (OSStatus **-10814**, no registered handler).

### Testing deep links in the Simulator

1. **Build and run** **ContainerExample** on a simulator (so the app is installed with the URL scheme).
2. **Leave the app in the foreground or background** (not required to be on a specific tab).
3. From Terminal, send a URL to the **booted** simulator. Every URL the stub parser accepts (see **`FlowRoutes.swift`**), as **`openurl booted`** commands:

   ```bash
   # Tab only (no detail push)
   xcrun simctl openurl booted "container-example://tab/landing"
   xcrun simctl openurl booted "container-example://tab/launches"
   xcrun simctl openurl booted "container-example://tab/products"

   # Landing — detail A vs B (`beta` is the only path that opens detail B; anything else or no path → A)
   xcrun simctl openurl booted "container-example://landing/alpha"
   xcrun simctl openurl booted "container-example://landing/beta"

   # Launches
   xcrun simctl openurl booted "container-example://launches/alpha"
   xcrun simctl openurl booted "container-example://launches/beta"

   # Products
   xcrun simctl openurl booted "container-example://products/alpha"
   xcrun simctl openurl booted "container-example://products/beta"
   ```

   Equivalent to **detail A**: omit the path (e.g. `container-example://products`) or use any first segment except **`beta`** (e.g. `…/foo`). There is no separate parser case for **`alpha`**—it is just a readable alias for the default.

4. **Pick a specific device** if you use multiple simulators:

   ```bash
   xcrun simctl list devices available
   xcrun simctl openurl <DEVICE_UDID> "container-example://tab/products"
   ```

5. **If nothing happens** (or you see **-10814**), confirm **`CFBundleURLTypes`** appears in the built **`ContainerExample.app/Info.plist`** (e.g. `plutil -p …/Info.plist`), the **scheme** matches exactly (`container-example`), and the simulator that received **openurl** is the one where you installed the app.

6. **Safari in Simulator** — You can also type `container-example://landing/alpha` in the address bar; iOS should prompt to open the app if the scheme is registered.

---

## Building and testing

From the repo root:

```bash
swift test          # Container package tests
```

Open **`Example/ContainerExample.xcodeproj`** in Xcode to build and run the sample app on a simulator or device.

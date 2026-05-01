# StemRuntimeSDK

Your AI can now ship complete native iOS features, not just code snippets. **StemJSON** is a declarative language describing a full feature — screens, interactions, data, navigation — and **StemRuntimeSDK** runs it as native SwiftUI on-device. AI authors the feature; users get native iOS.

![iOS](https://img.shields.io/badge/iOS-18.0%2B-blue?logo=apple)
![Swift](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)
![Xcode](https://img.shields.io/badge/Xcode-26.0%2B-blue?logo=xcode)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen?logo=swift)
![License](https://img.shields.io/badge/license-Proprietary%20Freeware-lightgrey)

---

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Zip-Packaged Modules](#zip-packaged-modules)
- [Core API](#core-api)
- [State Observation & Events](#state-observation--events)
- [Module Lifecycle](#module-lifecycle)
- [UIKit Integration](#uikit-integration)
- [Navigation Embedding](#navigation-embedding)
- [Custom Repositories](#custom-repositories)
- [Custom Services](#custom-services)
- [Error Handling](#error-handling)
- [Diagnostics & Logging](#diagnostics--logging)
- [Module JSON](#module-json)
- [Thread Safety & Swift 6 Concurrency](#thread-safety--swift-6-concurrency)
- [License](#license)

---

## Requirements

| Dependency | Minimum |
|---|---|
| iOS | 18.0 |
| Swift | 6.0 |
| Xcode | 26.0 |

---

## Installation

### Swift Package Manager

Add the package in Xcode via **File › Add Package Dependencies**, or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/vkrychun/stem-runtime-swift.git", from: "1.0.0")
]
```

---

## Quick Start

```swift
import SwiftUI
import StemRuntimeSDK

struct DashboardView: View {
    private let runtime = StemRuntime()
    @State private var stemView: AnyView?

    var body: some View {
        Group {
            if let stemView { stemView }
            else { ProgressView() }
        }
        .task {
            guard
                let url    = Bundle.main.url(forResource: "dashboard", withExtension: "json"),
                let render = try? await runtime.validate(contentsOf: url).get()
            else { return }
            stemView = AnyView(render)
        }
    }
}
```

Three steps in practice: create a runtime, validate a JSON module (file or raw `Data`), embed the returned render — `StemRender` conforms to `View`. The SDK accepts either a single `.json` file or a zip-packaged module and picks the loader from the byte stream — no flag required.

---

## Zip-Packaged Modules

Use a zip when a module needs bundled assets, localisation, or sub-modules.

```
my_feature.zip
├── main.json                  ← required — the module root
├── details.json               ← sub-module, loaded via file://details.json
├── localization/
│   ├── en.strings             ← "key" = "value"; format
│   └── uk.strings
└── assets/
    └── logo.png               ← loaded via file://assets/logo.png
```

- Package resources are referenced with `file://<relative-path>` and take precedence over host-app resources with the same path.
- A zip without `main.json` at the root fails validation.
- `.strings` files under `localization/` back `l10n://` sources and the `localize(key, fallback)` expression function. The runtime falls back to the host app bundle if a key is missing.

See [StemJSON Specification §14](https://github.com/vkrychun/StemJSON/blob/main/spec/v1.0.md#14-package--distribution) for the full package format.

---

## Core API

### `StemRuntime`

The entry point. Create one per app or feature scope.

```swift
// Default
let runtime = StemRuntime()

// With diagnostics
let runtime = StemRuntime(.init(enabled: true, minLevel: .warning))
```

Fluent configuration:

```swift
let runtime = StemRuntime()
    .navigationEmbedded()
    .register(MyRemoteRepository.self, as: StemRepositoryType.remote)
```

### Validation

```swift
func validate(data: Data, ignore: [StemIssueSeverity] = []) async -> Result<StemRender, StemValidationReport>
func validate(contentsOf url: URL, ignore: [StemIssueSeverity] = []) async -> Result<StemRender, StemValidationReport>
```

`ignore` suppresses non-critical severity levels from causing a `.failure` (e.g. `[.warning, .note]`).

`StemValidationReport` conforms to `LocalizedError` and `CustomStringConvertible`. Its `description` is a human- and machine-readable report:

```
=== Validation Report: 2 errors, 1 warning ===
❌ ERROR | login_btn → onTap | [V002] Value 'repositoryId' is missing
...
```

The format is designed for **AI-in-the-loop authoring**: feed the report back to the model and it will revise the StemJSON module until validation passes.

### `StemRender`

The value returned by `validate`. It conforms to `View`, `Identifiable`, and `Equatable`, so you can use it in three ways:

```swift
// 1. Embed in SwiftUI — StemRender is a View
var body: some View { render }

// 2. Render in UIKit
let vc = runtime.renderViewController(render)

// 3. Read metadata declared in the module's JSON `context`
let title: String? = render.title
let icon:  String? = render.icon
```

Being `Identifiable` and `Equatable` makes it safe to use in `ForEach` and SwiftUI diffing.

---

## State Observation & Events

### Subscribe to a state key

```swift
let cancellable = runtime.subscribe(to: "cartCount", in: render) { value in
    updateBadge(value)
}
```

### Stream state changes

```swift
for await value in runtime.stream(for: "cartCount", from: render) {
    updateBadge(value)
}
```

### Trigger events from native code

```swift
runtime.trigger(event: "themeChanged", data: ["mode": "dark"])
```

The payload is bound into the matching `onCustom` handler's context. Inside the module JSON, read fields as `@{<action.id>.<field>}`. Always pass every field the handler needs in the payload — path predicates with `@{…}` are not supported inside filter values (see StemJSON spec §6.2.1).

---

## Module Lifecycle

A module cannot terminate itself — it only mutates its own state. The host observes a sentinel state key and calls `kill`:

```swift
let cancellable = runtime.subscribe(to: "onClose", in: render) { value in
    guard value as? Bool == true else { return }
    Task {
        await runtime.kill(render)
        isPresented = false
    }
}
```

`kill` is a hard termination — the next `validate` produces a fresh module from initial state. Dismissing without `kill` preserves state so the next open resumes where the user left off.

---

## UIKit Integration

### Embed as a child view controller (recommended)

```swift
let render = try? await runtime.validate(contentsOf: url).get()
let stemVC = runtime.renderViewController(render!)
addChild(stemVC)
view.addSubview(stemVC.view)
stemVC.view.frame = view.bounds
stemVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
stemVC.didMove(toParent: self)
```

### Embed as a bare `UIView`

Use only when a child view controller is not possible — `renderViewController` is preferred because it propagates safe-area insets, trait changes, and keyboard avoidance.

```swift
let stemView = await runtime.renderView(render)
containerView.addSubview(stemView)
// pin edges with Auto Layout
```

---

## Navigation Embedding

By default a module creates its own `NavigationStack`. When the module is pushed **inside a host navigation flow**, call `.navigationEmbedded()` so internal `navigation` components participate in the host's stack instead:

```swift
let runtime = StemRuntime()
    .navigationEmbedded()
```

With this enabled, `link` destinations and `navigate push` actions land on the host's stack; back-swipe and pop operations sync automatically.

> **`link.destination` must have `"type": "module"`.** A `scroll` / `vstack` placed there renders but its `events` (notably `onAppear`) will not fire. Always wrap pushed layouts as `{ "type": "module", "state": {…}, "children": [ … ] }`. See StemJSON spec §link.

Do **not** use `.navigationEmbedded()` for self-contained modules (tab root, modal presentation) — they manage their own navigation.

---

## Custom Repositories

Built-in repositories registered automatically:

| Key | Built-in implementation |
|---|---|
| `StemRepositoryType.remote` | HTTP/REST |
| `StemRepositoryType.secured` | Keychain-backed secure storage |
| `StemRepositoryType.local` | On-device document storage |
| `StemRepositoryType.photos` | Photo library |

Override any of them, or register your own under a custom `StemDependencyType`:

```swift
final class ProductRepository: StemRepository {
    typealias Entity = ProductEntity

    struct Configuration: Decodable, Sendable { let baseURL: String }

    let id: String
    let config: Configuration

    init(id: String, config: Configuration) throws {
        self.id = id
        self.config = config
    }

    func read(_ input: Entity.Read) async throws(StemActionError) -> Entity.Read.Response { /* … */ }
    func create(_ input: Entity.Create) async throws(StemActionError) -> Entity.Create.Response { /* … */ }
    func update(_ input: Entity.Update) async throws(StemActionError) -> Entity.Update.Response { /* … */ }
    func delete(_ input: Entity.Delete) async throws(StemActionError) -> Entity.Delete.Response { /* … */ }
}

runtime.register(ProductRepository.self, as: StemRepositoryType.remote)
```

For streaming sources (WebSocket, Firestore listener, SSE), also conform to `StemListenable` to back the `listen` action:

```swift
extension ProductRepository: StemListenable {
    func listen(_ params: AnyDecodable) -> AsyncThrowingStream<AnyDecodable, Error> { /* … */ }
}
```

---

## Custom Services

Services handle operations outside CRUD semantics — analytics, biometrics, camera, location, deep links, health, and so on. The SDK pre-registers `audio` (system sounds and haptics) and `push` (**local notifications only** — for remote push, register your own implementation). Everything else is a host-provided implementation.

Conform to `StemService` and implement `execute`:

```swift
final class AnalyticsService: StemService, Decodable {
    let id: String

    @MainActor
    func execute(_ input: Any?) async throws(StemActionError) -> Any? {
        // track event, return value for `output.success`, or nil for fire-and-forget
        return nil
    }
}

runtime.register(AnalyticsService.self, as: StemServiceType.analytics)
```

`execute` runs on the main actor. Throw `StemActionError` to trigger the `output.failure` chain.

For dependencies that don't fit the built-in repository or service categories, define a custom key:

```swift
enum AppDependency: String, StemDependencyType { case featureFlags }
runtime.register(FeatureFlagService.self, as: AppDependency.featureFlags)
```

---

## Error Handling

All SDK errors surface as `StemActionError`, with a typed `StemErrorCode` and a human-readable `message`.

```swift
let result = await runtime.validate(data: jsonData)
switch result {
case .success(let render):  hostView = AnyView(render)
case .failure(let report):  print(report.errorDescription ?? report.description)
}
```

Build errors in your own repositories and services with the dedicated initialisers:

```swift
throw StemActionError(httpStatusCode: response.statusCode)
throw StemActionError(osStatus: keychainStatus)
throw StemActionError(.network(.notFound), "Product \(id) not found")
throw StemActionError(error, fallback: .unknown)
```

Conform your domain errors to `StemActionErrorConvertible` to let the SDK translate them automatically:

```swift
extension MyDomainError: StemActionErrorConvertible {
    func asStemActionError() -> StemActionError { /* … */ }
}
```

`StemErrorCode` groups codes into `GeneralError`, `NetworkError`, `StorageError`, `SecurityError`, `FirestoreError`, and a `.custom` bridge for your own types.

---

## Diagnostics & Logging

```swift
// Explicit configuration
let runtime = StemRuntime(.init(enabled: true, minLevel: .warning))

// Silence
let runtime = StemRuntime(.init(enabled: false))
```

Defaults match the build: `.bingo` in DEBUG, `.warning` in Release. Pass a `Diagnostics.Configuration` explicitly to override.

Severity levels: `.bingo`, `.info`, `.note`, `.warning`, `.error`, `.critical`.

Messages are emitted through OSLog under the subsystem `com.stem.runtime.sdk`.

---

## Module JSON

StemJSON modules are a declarative tree: every component has a `type`, optional `context`, optional `state`, and optional `children`. Values anywhere in the tree may be static, state-bound (`${field}`), context-bound (`@{key}`), or expression-evaluated (`{{ expr }}`).

```json
{ "id": "email_field", "type": "textfield",
  "context": { "_label": "Email", "_text": "${email}" } }
```

For the full component catalogue, value syntax, style options, and action types see the [**StemJSON v1.0 Specification**](https://github.com/vkrychun/StemJSON/blob/main/spec/v1.0.md).

### Schema versioning

Add `"version": "1.0"` at the module root. The SDK uses it to protect forward compatibility:

| Module vs SDK | Behaviour |
|---|---|
| Same or lower | Renders normally |
| Higher minor | Renders — unknown features show a placeholder |
| Higher major | Validation fails |

Unknown component types never crash the SDK — they render an informational placeholder and their children still display.

---

## Thread Safety & Swift 6 Concurrency

The SDK uses Swift 6 strict concurrency. All public types are `Sendable`.

| Main actor only | Any thread |
|---|---|
| Embedding a `StemRender` in a SwiftUI hierarchy | `StemRuntime()` |
| `renderViewController(_:)` / `renderView(_:)` | `validate(data:)` / `validate(contentsOf:)` |
| `StemService.execute(_:)` | `subscribe` / `stream` / `trigger` / `kill` / `register` |

Custom repositories and services must declare their `Configuration` and `Response` types `Sendable`.

---

## License

Distributed under a Proprietary Freeware License. Unlicensed builds display a small "Powered by StemJSON" badge on physical devices — its corner is configurable to fit your UI:

```swift
StemRuntime().watermarkPosition(.topTrailing)
```

See [LICENSE](LICENSE) and [TERMS_AND_CONDITIONS.md](TERMS_AND_CONDITIONS.md). Pricing: [stemjson.com/sdk/pricing](https://stemjson.com/sdk/pricing). Enquiries: [vkrychun@stemjson.com](mailto:vkrychun@stemjson.com).

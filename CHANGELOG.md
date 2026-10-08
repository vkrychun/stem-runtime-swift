# Changelog

All notable changes to **StemRuntimeSDK** are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). The project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.2.0] — TBD

Implements the [StemJSON v1.2 specification](https://github.com/vkrychun/StemJSON/blob/main/spec/v1.2.md).

### Added
- `chart` component — bar, line, area, point, and pie series over an array of data elements, matching [StemJSON v1.2.0](https://github.com/vkrychun/StemJSON/blob/main/spec/v1.2.md) §4.2 and §7.28. All series share the axes; an axis is time, category, or number, declared or taken from the data. Several bar series draw grouped side by side, and a pie draws its first pie series. Series colors come from the series, `style.chart.palette`, or the platform defaults. Missing or invalid `_data`, `_series`, series kinds, and axis types are reported by validation.
- `web` component — shows a web page inside the component frame, matching §4.2 and §7.29. Only `https://`, `http://`, and `file://` sources load (a `file://` source resolves inside the module package); anything else leaves the frame empty. `_allowsNavigation`, `_scrollEnabled`, and `style.web` control link taps, scrolling, and JavaScript. An `http://` source needs an App Transport Security exception in the host app. `StemRuntime.audit` reports a `web` source like a remote endpoint.
- `navigate` operation `open` — hands an `https`, `http`, `mailto`, or `tel` URL to the system, matching §10.8. `output.success` runs after the hand-off and `output.failure` runs when the URL is refused or nothing can open it. The navigation stack is untouched, and no `navigation` ancestor is required.
- `onChange` accepts an array of observers, one per element, matching §9.2. Each observer fires for its own key. Previously the observers of an array never fired.
- `slice(array, start, end?)`, `pow(base, exponent)`, `sqrt(x)`, and `log(x, base?)` expression functions, matching §8.6. `slice` counts negative bounds from the tail and clamps out-of-range ones. The math functions return none for non-numeric input and for any result that is not finite; `log` is natural without a base and exact for bases 10 and 2. `prefix` and `suffix` now work on arrays as well as strings.

### Changed
- A determinate `progress` renders as a horizontal bar instead of a ring. A `progress` without `_value` shows an indeterminate spinner, `_total` defaults to 1, and neither key produces a warning when omitted. The bar fills the available width.
- A remote `image` whose load fails now shows its `_placeholder` (the system photo icon when none is declared) instead of shimmering forever. The shimmer still shows while the image downloads.
- A `datepicker` whose `_date`, `_min`, or `_max` resolves to a number reads it as Unix seconds. Previously it showed the current time and overwrote the stored value on save. A `_min` later than `_max` no longer crashes.
- Everything a host can see — failure messages, validation reports, and logs — now carries only the diagnostic code, severity, JSON path, and the values the module declared. Type names, resolved URLs, file paths, and other runtime details are no longer included. The rendered `StemValidationReport` text no longer has severity emoji or phase labels. With `_debug`, the declared expression is logged; resolved values appear only while a debugger is attached.

### Conformance
- Forward compatibility, matching §18.2: constructs a later minor revision introduces degrade to warnings. Unknown events and action kinds are skipped, unknown functions evaluate to none, an unknown dependency kind is omitted, and an action addressing it, or an unknown `navigate` operation, runs its `output.failure`. A module with a dependency kind this runtime does not know now renders instead of failing. Unrecognised values of an enumerated key (fonts, alignment, colors, and so on) remain validation errors at every declared version.
- `StemRuntime.compatibility(_:)` selects `.degrade` (default) or `.strict`, matching §18.1. Strict refuses a module that declares a later minor revision with a single error naming the required revision. `StemRuntime.supportedSpec` reports the revision the runtime implements, `"1.2"`. A module declaring `"1.2"` validates without a version warning, and version findings are reported at `/version`.
- `StemRender.diagnostics` — the findings that did not stop a module from rendering (warnings and notes, including the missing-`version` note), already filtered by `ignore`. Empty when there are none.
- `StemValidationReport.issues` — a structured list of findings, each with `code`, `severity`, `path`, and `message`, so a host or an authoring loop can act on them without parsing text.
- A style domain or key the renderer does not read now produces a warning at its JSON path, as does a dictionary under `picker` or `datePicker` (they take a bare string). Previously such keys were ignored silently.
- An action object that names no action kind now produces a warning; it still does nothing. `output`, `success`, or `failure` inside an action's `input` also warns, because it is never read as the chain.
- A bare array of actions under `onChange` produces a warning and never fires; use observer objects.
- `StemRuntime.audit` takes the namespace the host passes to `validate` as `StemSecurityPolicy.hostNamespace`. Without one, a module that declares `local` or `secured` stores gets an info finding that its data lives in the shared layout (§5.3). The audit also now reaches components under `dynamic` rows, `link` destinations, and `conditional` branches that it previously skipped, and counts them toward the component cap. `navigate` `open` with an `http(s)` URL is reported like other endpoints.

### Fixed
- A `state` write merges per key: declared keys are written and undeclared keys are dropped. Previously a write naming at least one declared key was applied whole and created the undeclared ones.
- A `state` write without an `output.success` chain reaches every ancestor module that declares the key. Previously it stopped one level up, so a root module never saw a grandchild's write.

---

## [1.1.0] — 2026-07-02

### Added
- `ai` action — calls an AI provider and binds the result into a module, the foundation for AI-driven backends (a game opponent, summarization, on-the-fly data shaping). It POSTs a literal provider request `body` through a host-registered `remote` repository and optionally unwraps the response (`responsePath` plus a default `parseJson` JSON-parse), so the chained `@{id}` is the clean answer. Provider-agnostic — the model, prompt, and response schema all live in `body`, and the API key is injected by the repository's auth interceptor (never in JSON), so the same module targets OpenAI or Anthropic by pointing `provider` at a different repository. Matches [StemJSON v1.1.0](https://github.com/vkrychun/StemJSON/blob/main/spec/v1.1.md) §10.11.
- `StemRuntime.audit(data:policy:)` — opt-in static security review of a module before you run it. Without instantiating the module (no timers, network, or listeners start), it reports the capabilities the module declares — network endpoints, device services, on-device storage, repeating timers, and live data subscriptions — as severity-rated findings plus a capability summary, so a host can decide whether to load content from an untrusted author. Tunable via `StemSecurityPolicy` (allow-lists, an interval floor, a component cap, and a `trustedSource` shortcut).
- `switch(test1, value1, …, default)` expression function — a flat multi-way conditional matching [StemJSON v1.1.0](https://github.com/vkrychun/StemJSON/blob/main/spec/v1.1.md) §8.6. Lazy/short-circuit like the ternary (only the matched value is evaluated); odd arity with a mandatory default. Removes the deeply nested ternaries that cause unbalanced-paren errors in generated modules. A module using `switch()` should declare `"version": "1.1"`.
- `random()` / `random(min, max)` and `range(n)` / `range(start, end)` expression functions for declarative randomization, matching [StemJSON v1.1.0](https://github.com/vkrychun/StemJSON/blob/main/spec/v1.1.md) §8.6.1. `map(range(n), random(a, b))` generates structured data (grids/boards) without hardcoding. `random()` is nondeterministic — resolve it once in an action/lifecycle value (frozen into state), never in a render binding.
- `validate(data:namespace:)` / `validate(contentsOf:namespace:)` — an optional per-module storage namespace. When supplied, a module's on-device data (its local database and secured items) is isolated to that namespace, so two modules that declare the same storage ids - or two installs of the same tool - keep separate data. Omit it for the previous shared behavior.
- Collection functions `setAt`, `removeAt`, `insertAt`, `keys`, `values`, and `removeKey` — matching [StemJSON v1.1.0](https://github.com/vkrychun/StemJSON/blob/main/spec/v1.1.md) §8.6. Edit an array element by position (`setAt` / `removeAt` / `insertAt`; negative indices count from the tail) and inspect or prune dictionaries (`keys` sorted, `values` key-aligned, `removeKey`); all return a new value. Positional editing makes piece-moving board games and index-addressed grids work directly.

### Changed
- **Migration required for custom dependencies:** `StemRepository` and `StemService` conformers must now declare the registry key they are registered under — add `var dependencyType: any StemDependencyType { <your key> }` (e.g. `StemRepositoryType.remote`, or your custom `StemDependencyType`). The static security audit uses it to name the capability. Built-in dependencies are unaffected.

### Clarified
- Chained ternaries (`a ? b : c ? d : e`) require no parentheses — already supported, now covered by tests.

### Fixed
- Typed numbers are now parsed locale-aware, so decimal input no longer reads as 0.
- A `dynamic` list rendered over an array with repeated values — a board with identical pieces, repeated empty cells, or a list with duplicate entries — no longer collapses those rows together: each row resolves its own `@{index}`, so a tap or per-row binding targets the correct element.
- Repeating `interval` timers now update on every tick. A countdown whose tick reads state — e.g. `{{ ${seconds} - 1 }}` — previously could stay frozen; it now reflects the latest value each tick.
- A malformed `onChange` / `onCustom` event in its object form (`{ "observed" | "name", "actions" }`) now reports a precise error naming the missing required field, instead of a misleading "expected array" message. The action-array form remains accepted.

---

## [1.0.2] — 2026-06-12

### Changed
- Component `type` is now resolved case-insensitively, matching [StemJSON v1.0.2](https://github.com/vkrychun/StemJSON/blob/main/spec/v1.0.md) — the canonical form is lowercase. Existing modules are unaffected.

---

## [1.0.1] — 2026-06-01

### Added
- Clearer validation warnings for common authoring mistakes: unknown function names, malformed pipes, invalid `cast` sources, operators or function calls inside `${…}`/`@{…}` paths, and writes to undeclared state keys.
- `cast(int|double, 'date')` interprets numeric values as Unix-epoch seconds.
- Multiple modals per `style.modal` block (e.g. an alert and a sheet on one component).
- `"zero"` keyword on EdgeInsets fields.

### Fixed
- `cast(_, 'date')` parses ISO 8601, RFC 3339, and common locale string forms.
- Cross-type comparison between dates and numeric epoch values.
- `map` honours the wrapped `{ region: { center, span } }` position shape (fixes off-screen annotation pin).
- `photos.read` always returns an array.
- Keyboard dismissal in `textfield` / `texteditor` now works reliably across all host integrations.

---

## [1.0.0] — 2026-04-20

Initial release. Implements the [StemJSON v1.0 specification](https://github.com/vkrychun/StemJSON/blob/main/spec/v1.0.md).

---

[1.2.0]: https://github.com/vkrychun/stem-runtime-swift/releases/tag/v1.2.0
[1.1.0]: https://github.com/vkrychun/stem-runtime-swift/releases/tag/v1.1.0
[1.0.2]: https://github.com/vkrychun/stem-runtime-swift/releases/tag/v1.0.2
[1.0.1]: https://github.com/vkrychun/stem-runtime-swift/releases/tag/v1.0.1
[1.0.0]: https://github.com/vkrychun/stem-runtime-swift/releases/tag/v1.0.0

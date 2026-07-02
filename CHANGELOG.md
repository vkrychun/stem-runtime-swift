# Changelog

All notable changes to **StemRuntimeSDK** are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). The project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.1.0] — 2026-07-02

### Added
- `ai` action — calls an AI provider and binds the result into a module, the foundation for AI-driven backends (a game opponent, summarization, on-the-fly data shaping). It POSTs a literal provider request `body` through a host-registered `remote` repository and optionally unwraps the response (`responsePath` plus a default `parseJson` JSON-parse), so the chained `@{id}` is the clean answer. Provider-agnostic — the model, prompt, and response schema all live in `body`, and the API key is injected by the repository's auth interceptor (never in JSON), so the same module targets OpenAI or Anthropic by pointing `provider` at a different repository. Matches [StemJSON v1.1.0](https://github.com/vkrychun/StemJSON/blob/main/spec/v1.1.md) §10.11.
- `StemRuntime.audit(data:policy:)` — opt-in static security review of a module before you run it. Without instantiating the module (no timers, network, or listeners start), it reports the capabilities the module declares — network endpoints, device services, on-device storage, repeating timers, and live data subscriptions — as severity-rated findings plus a capability summary, so a host can decide whether to load content from an untrusted author. Tunable via `StemSecurityPolicy` (allow-lists, an interval floor, a component cap, and a `trustedSource` shortcut).
- `switch(test1, value1, …, default)` expression function — a flat multi-way conditional matching [StemJSON v1.1.0](https://github.com/vkrychun/StemJSON/blob/main/spec/v1.1.md) §8.6. Lazy/short-circuit like the ternary (only the matched value is evaluated); odd arity with a mandatory default. Removes the deeply nested ternaries that cause unbalanced-paren errors in generated modules. A module using `switch()` should declare `"version": "1.1"`.
- `random()` / `random(min, max)` and `range(n)` / `range(start, end)` expression functions for declarative randomization, matching [StemJSON v1.1.0](https://github.com/vkrychun/StemJSON/blob/main/spec/v1.1.md) §8.6.1. `map(range(n), random(a, b))` generates structured data (grids/boards) without hardcoding. `random()` is nondeterministic — resolve it once in an action/lifecycle value (frozen into state), never in a render binding.
- `validate(data:namespace:)` / `validate(contentsOf:namespace:)` — an optional per-module storage namespace. When supplied, a module's on-device data (its local database and secured items) is isolated to that namespace, so two modules that declare the same storage ids - or two installs of the same tool - keep separate data. Omit it for the previous shared behavior.
- Collection functions `setAt`, `removeAt`, `insertAt`, `keys`, `values`, and `removeKey` — matching [StemJSON v1.1.0](https://github.com/vkrychun/StemJSON/blob/main/spec/v1.1.md) §8.6. Edit an array element by position (`setAt` / `removeAt` / `insertAt`; negative indices count from the tail) and inspect or prune dictionaries (`keys` sorted, `values` key-aligned, `removeKey`); all return a new value. Positional editing makes piece-moving board games and index-addressed grids work directly.

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

[1.1.0]: https://github.com/vkrychun/stem-runtime-swift/releases/tag/v1.1.0
[1.0.2]: https://github.com/vkrychun/stem-runtime-swift/releases/tag/v1.0.2
[1.0.1]: https://github.com/vkrychun/stem-runtime-swift/releases/tag/v1.0.1
[1.0.0]: https://github.com/vkrychun/stem-runtime-swift/releases/tag/v1.0.0

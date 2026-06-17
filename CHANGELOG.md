# Changelog

All notable changes to **StemRuntimeSDK** are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). The project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.1.0] — Unreleased

### Added
- `switch(test1, value1, …, default)` expression function — a flat multi-way conditional matching [StemJSON v1.1.0](https://github.com/vkrychun/StemJSON/blob/main/spec/v1.1.md) §8.6. Lazy/short-circuit like the ternary (only the matched value is evaluated); odd arity with a mandatory default. Removes the deeply nested ternaries that cause unbalanced-paren errors in generated modules. A module using `switch()` should declare `"version": "1.1"`.
- `random()` / `random(min, max)` and `range(n)` / `range(start, end)` expression functions for declarative randomization ([StemJSON v1.1.0](https://github.com/vkrychun/StemJSON/blob/main/spec/v1.1.md) §8.6.1). `map(range(n), random(a, b))` generates fresh structured data (grids/boards) so games/puzzles regenerate on reset without hardcoding. `random()` is nondeterministic — resolve it once in an action/lifecycle value (frozen into state), never in a render binding. Calling either function with the wrong number of arguments is flagged by validation (diagnostic V015).

### Clarified
- Chained ternaries (`a ? b : c ? d : e`) require no parentheses — already supported, now covered by tests.

### Fixed
- Repeating `interval` timers now update on every tick. A countdown whose tick reads state — e.g. `{{ ${seconds} - 1 }}` — previously could stay frozen; it now reflects the latest value each tick.
- A malformed `onChange` / `onCustom` event written in its object form (`{ "observed" | "name", "actions" }`) now reports a precise error naming the missing required field, instead of a misleading "expected array, found object" message. The bare action-array form remains accepted.

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

[1.0.2]: https://github.com/vkrychun/stem-runtime-swift/releases/tag/v1.0.2
[1.0.1]: https://github.com/vkrychun/stem-runtime-swift/releases/tag/v1.0.1
[1.0.0]: https://github.com/vkrychun/stem-runtime-swift/releases/tag/v1.0.0

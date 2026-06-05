# Changelog

All notable changes to **StemRuntimeSDK** are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). The project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.0.1]: https://github.com/vkrychun/stem-runtime-swift/releases/tag/v1.0.1
[1.0.0]: https://github.com/vkrychun/stem-runtime-swift/releases/tag/v1.0.0

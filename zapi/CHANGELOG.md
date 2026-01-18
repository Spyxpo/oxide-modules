# Changelog

All notable changes to the Zapi module will be documented in this file.

## [0.0.2] - 2025-01-18

### Added

- New `ZapiUtils` class with static utility methods

### Changed

- Refactored utility functions to class-based OOP pattern
- Added static methods to `ZapiUtils` class: `urlDecode()`, `urlEncode()`, `jsonEncode()`, `jsonDecode()`, `escapeJsonString()`, `startsWith()`, `endsWith()`, `contains()`, `toHex()`
- Module-level convenience functions now delegate to class static methods for consistent API

### Documentation

- Updated version to 0.0.2

## [0.0.1] - 2025-01-17

### Added

- Initial release of the Zapi web framework module
- Core `Zapp` class for creating web applications
- Route registration with `get()`, `post()`, `put()`, `delete()`, `patch()` methods
- Request object with `path`, `method`, `headers`, `query`, `body`, `params` properties
- Response helpers: `text()`, `json()`, `html()`, `redirect()`, `status()`
- Static file serving with `static()` method
- Middleware support with `use()` method
- Route parameters with `:param` syntax
- Query string parsing
- JSON request/response handling
- CORS support helper
- Error handling with custom error pages
- Development server with `run()` method

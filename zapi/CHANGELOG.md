# Changelog

All notable changes to the Zapi module will be documented in this file.

## [0.0.1] - 2025-01-17

### Added
- Initial release of the Zapi web framework module
- Core `App` class for creating web applications
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

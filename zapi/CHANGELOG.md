# Changelog

All notable changes to the Zapi module will be documented in this file.

## [0.0.1] - 2025-01-18

### Added

- Initial release of the Zapi web framework module
- Core `Zapp` class for creating web applications with OOP pattern
- Static factory methods: `Zapp.create()`, `Zapp.createApi()`, `Zapp.createWithCors()`
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
- `ZapiUtils` class with static utility methods: `urlDecode()`, `urlEncode()`, `jsonEncode()`, `jsonDecode()`, `escapeJsonString()`, `startsWith()`, `endsWith()`, `contains()`, `toHex()`

### Usage

```oxide
use zapi

app = Zapp.create()
app.get("/", func(req, res)
    res.text("Hello, World!")
endfunc)
app.run(3000)
```

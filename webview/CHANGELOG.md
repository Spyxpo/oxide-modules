# Changelog

All notable changes to the Webview module will be documented in this file.

## [0.0.2] - 2025-01-23

### Fixed

- Bug fixes and stability improvements

### Improved

- Minor refinements and enhancements

---

## [0.0.1] - 2025-01-18

### Added

- Initial release of the Webview module with OOP pattern
- `Webview` class for object-oriented webview management
- Static factory methods: `Webview.create()`, `Webview.createWithUrl()`, `Webview.createWithHtml()`
- Static convenience methods: `Webview.openUrl()`, `Webview.openHtml()`, `Webview.dialog()`, `Webview.alert()`, `Webview.confirm()`, `Webview.createApp()`, `Webview.createTransparent()`
- Core webview functions: `create`, `navigate`, `loadHtml`, `run`, `destroy`
- Window control: `setTitle`, `setSize`, `setResizable`, `setVisible`, `setFullscreen`
- Window control functions: `center()`, `setPosition()`, `getPosition()`, `getSize()`
- Window size constraints: `setMinSize()`, `setMaxSize()`
- Window state functions: `minimize()`, `maximize()`, `restore()`
- Window focus functions: `isFocused()`, `focus()`
- Always on top support: `setAlwaysOnTop()`
- Window opacity control: `setOpacity()`
- Window icon support (Linux): `setIcon()`
- Load HTML with base URL: `loadHtmlWithBase()`
- JavaScript interaction: `eval`, `inject`, `bind`
- Async JavaScript execution: `evalAsync()`
- Unbind JavaScript functions: `unbind()`
- Navigation control: `goBack`, `goForward`, `reload`, `stop`, `getUrl`, `getTitle`
- Navigation state functions: `canGoBack()`, `canGoForward()`, `isLoading()`, `getLoadingProgress()`
- Reload bypassing cache: `reloadIgnoringCache()`
- Configuration: `setDevTools`, `setUserAgent`, `setBackgroundColor`
- DevTools control: `openDevTools()`, `closeDevTools()`
- Get user agent: `getUserAgent()`
- Web settings: `setJavaScriptEnabled()`, `setLocalStorageEnabled()`, `setDatabasesEnabled()`
- Zoom control: `setZoom()`, `getZoom()`
- Context menu control: `setContextMenuEnabled()`
- Data clearing: `clearCookies()`, `clearLocalStorage()`, `clearCache()`, `clearAllData()`
- Print and export: `printPage()`, `savePdf()`, `screenshot()`
- Event callbacks: navigation events, title change, load progress, close request, new window, download, console messages
- macOS implementation using WebKit (WKWebView)
- Linux implementation using WebKitGTK (webkit2gtk-4.0)
- Windows stub (requires WebView2 implementation)

### Usage

```oxide
use webview

wv = Webview.create("My App", 800, 600)
wv.load("https://example.com")
wv.start()
```

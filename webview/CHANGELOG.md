# Changelog

All notable changes to the Webview module will be documented in this file.

## [0.0.1] - 2025-01-17

### Added

- Initial release of the Webview module
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
- Convenience functions: `openUrl`, `openHtml`, `dialog()`, `alert()`, `confirm()`, `createApp()`, `createTransparent()`
- Object-oriented `Webview` class with chainable methods
- macOS implementation using WebKit (WKWebView)
- Linux implementation using WebKitGTK (webkit2gtk-4.0)
- Windows stub (requires WebView2 implementation)

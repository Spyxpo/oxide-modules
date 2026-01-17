# Changelog

All notable changes to the Webview module will be documented in this file.

## [0.0.2] - 2025-01-17

### Added
- New window control functions: `center()`, `setPosition()`, `getPosition()`, `getSize()`
- Window size constraints: `setMinSize()`, `setMaxSize()`
- Window state functions: `minimize()`, `maximize()`, `restore()`
- Window focus functions: `isFocused()`, `focus()`
- Always on top support: `setAlwaysOnTop()`
- Window opacity control: `setOpacity()`
- Window icon support (Linux): `setIcon()`
- Load HTML with base URL: `loadHtmlWithBase()`
- Async JavaScript execution: `evalAsync()`
- Unbind JavaScript functions: `unbind()`
- Navigation state functions: `canGoBack()`, `canGoForward()`, `isLoading()`, `getLoadingProgress()`
- Reload bypassing cache: `reloadIgnoringCache()`
- DevTools control: `openDevTools()`, `closeDevTools()`
- Get user agent: `getUserAgent()`
- Web settings: `setJavaScriptEnabled()`, `setLocalStorageEnabled()`, `setDatabasesEnabled()`
- Zoom control: `setZoom()`, `getZoom()`
- Context menu control: `setContextMenuEnabled()`
- Data clearing: `clearCookies()`, `clearLocalStorage()`, `clearCache()`, `clearAllData()`
- Print and export: `printPage()`, `savePdf()`, `screenshot()`
- Event callbacks (stubs): navigation events, title change, load progress, close request, new window, download, console messages
- Convenience functions: `dialog()`, `alert()`, `confirm()`, `createApp()`, `createTransparent()`
- Enhanced `Webview` class with chainable methods and improved state management

### Changed
- Improved URL handling with automatic http:// prefix for malformed URLs
- Better webview autoresizing on window resize
- Added default Quit menu for macOS
- Enhanced error handling in navigation delegates
- Improved window release management to prevent memory leaks

### Fixed
- Fixed potential null pointer dereferences in URL/title getters
- Fixed window not releasing properly on close
- Fixed webview not stopping loading on destroy
- Improved JavaScript evaluation timeout handling
- Better handling of empty/null strings in native code

## [0.0.1] - 2025-01-17

### Added
- Initial release of the Webview module
- Core webview functions: `create`, `navigate`, `loadHtml`, `run`, `destroy`
- Window control: `setTitle`, `setSize`, `setResizable`, `setVisible`, `setFullscreen`
- JavaScript interaction: `eval`, `inject`, `bind`
- Navigation control: `goBack`, `goForward`, `reload`, `stop`, `getUrl`, `getTitle`
- Configuration: `setDevTools`, `setUserAgent`, `setBackgroundColor`
- Convenience functions: `openUrl`, `openHtml`
- Object-oriented `Webview` class for easier usage
- macOS implementation using WebKit (WKWebView)
- Linux implementation using WebKitGTK (webkit2gtk-4.0)
- Windows stub (requires WebView2 implementation)

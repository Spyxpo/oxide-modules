# Changelog

All notable changes to the Webview module will be documented in this file.

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

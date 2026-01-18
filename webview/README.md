# Webview Module for Oxide

Cross-platform native webview module for embedding web content in Oxide desktop applications.

## Overview

The webview module provides a simple API to create native webview windows that can display web content (HTML, CSS, JavaScript) in your Oxide applications. It uses the platform's native webview technology:

- **macOS**: WebKit (WKWebView)
- **Linux**: WebKitGTK (webkit2gtk-4.0)
- **Windows**: WebView2 (Microsoft Edge)

## Installation

```bash
oxide install webview
```

## Requirements

### macOS
- macOS 10.13 or later
- WebKit framework (built-in)

### Linux
- GTK+ 3.0
- WebKitGTK 4.0

Install dependencies:
```bash
# Ubuntu/Debian
sudo apt install libgtk-3-dev libwebkit2gtk-4.0-dev

# Fedora
sudo dnf install gtk3-devel webkit2gtk3-devel

# Arch Linux
sudo pacman -S gtk3 webkit2gtk
```

### Windows
- Windows 10 or later
- WebView2 Runtime (automatically installed with Edge)

## Quick Start

```oxide
use webview

# Create a webview using OOP pattern
wv = Webview.create("My App", 800, 600)
wv.load("https://example.com")
wv.start()
```

## Usage Examples

### Basic Example

```oxide
use webview

# Create and show webview
wv = Webview.create("My App", 800, 600)
wv.load("https://example.com")
wv.start()
```

### Load HTML Content

```oxide
use webview

html = "<html><body><h1>Hello from Oxide!</h1></body></html>"

wv = Webview.createWithHtml(html, "HTML Demo", 640, 480)
wv.start()
```

### Using Factory Methods

```oxide
use webview

# Create with URL directly
wv = Webview.createWithUrl("https://oxide-lang.dev", "Browser", 1024, 768)
wv.start()

# Create with HTML content
wv = Webview.createWithHtml("<h1>Hello!</h1>", "Demo", 400, 300)
wv.start()
```

### JavaScript Interaction

```oxide
use webview

wv = Webview.create("JS Demo", 800, 600)
wv.loadContent("<html><body><div id='result'></div></body></html>", None)

# Execute JavaScript
wv.executeJs("document.getElementById('result').innerHTML = 'Updated from Oxide!'")

wv.start()
```

### Window Control

```oxide
use webview

wv = Webview.create("Resizable App", 800, 600)
wv.load("https://example.com")

# Window customization
wv.setWindowTitle("New Title")
wv.resize(1024, 768)
wv.centerWindow()
wv.enableDevTools()

wv.start()
```

### Navigation Control

```oxide
use webview

wv = Webview.create("Browser", 1024, 768)
wv.load("https://example.com")

# Navigation methods (chainable)
wv.back()
wv.forward()
wv.refresh()
wv.stopLoading()

# Get current state
url = wv.getCurrentUrl()
title = wv.getCurrentTitle()

wv.start()
```

### Static Convenience Methods

```oxide
use webview

# Quick way to open a URL
Webview.openUrl("https://oxide-lang.dev", "Browser", 800, 600)

# Quick way to show HTML
Webview.openHtml("<h1>Hello!</h1>", "Demo", 400, 300)

# Show an alert dialog
Webview.alert("Operation completed!", "Success")

# Show a confirm dialog
Webview.confirm("Are you sure?", "Confirm")

# Create a dialog
Webview.dialog("<p>Custom content</p>", "Dialog", 350, 200)
```

## API Reference

### Webview Class - Static Factory Methods

| Static Method | Description |
|---------------|-------------|
| `Webview.create(title, w, h)` | Create a new Webview instance |
| `Webview.createWithUrl(url, title, w, h)` | Create webview and navigate to URL |
| `Webview.createWithHtml(html, title, w, h)` | Create webview with HTML content |

### Webview Class - Static Convenience Methods

| Static Method | Description |
|---------------|-------------|
| `Webview.openUrl(url, title, w, h)` | Quick function to open URL |
| `Webview.openHtml(html, title, w, h)` | Quick function to display HTML |
| `Webview.dialog(html, title, w, h)` | Create a dialog with HTML content |
| `Webview.alert(message, title)` | Create an alert dialog |
| `Webview.confirm(message, title)` | Create a confirm dialog |
| `Webview.createApp(title, w, h, url)` | Create webview with common app settings |
| `Webview.createTransparent(title, w, h)` | Create frameless/transparent webview |

### Webview Class - Instance Methods

| Method | Description |
|--------|-------------|
| `wv.open()` | Create and show window |
| `wv.load(url)` | Navigate to URL |
| `wv.loadContent(html, baseUrl)` | Load HTML content |
| `wv.start()` | Run event loop |
| `wv.close()` | Destroy webview |
| `wv.resize(w, h)` | Resize window |
| `wv.setWindowTitle(title)` | Set window title |
| `wv.executeJs(js)` | Execute JavaScript |
| `wv.executeJsAsync(js)` | Execute JavaScript asynchronously |
| `wv.back()` | Go back |
| `wv.forward()` | Go forward |
| `wv.refresh()` | Reload page |
| `wv.stopLoading()` | Stop loading |
| `wv.centerWindow()` | Center window on screen |
| `wv.moveTo(x, y)` | Move window to position |
| `wv.minimizeWindow()` | Minimize window |
| `wv.maximizeWindow()` | Maximize window |
| `wv.restoreWindow()` | Restore window |
| `wv.fullscreen(enabled)` | Toggle fullscreen |
| `wv.show()` | Show window |
| `wv.hide()` | Hide window |
| `wv.enableDevTools()` | Enable developer tools |
| `wv.disableDevTools()` | Disable developer tools |
| `wv.showDevTools()` | Open developer tools |
| `wv.hideDevTools()` | Close developer tools |
| `wv.zoomIn()` | Increase zoom |
| `wv.zoomOut()` | Decrease zoom |
| `wv.resetZoom()` | Reset zoom to 100% |
| `wv.getCurrentUrl()` | Get current URL |
| `wv.getCurrentTitle()` | Get page title |
| `wv.isPageLoading()` | Check if page is loading |
| `wv.getProgress()` | Get loading progress |
| `wv.canNavigateBack()` | Check if can go back |
| `wv.canNavigateForward()` | Check if can go forward |
| `wv.takeScreenshot(path)` | Save screenshot to file |
| `wv.saveAsPdf(path)` | Save page as PDF |
| `wv.print()` | Print the page |
| `wv.clearBrowsingData()` | Clear all browsing data |

### Native Functions (Low-level)

| Function | Description |
|----------|-------------|
| `create(title, width, height)` | Create a new webview window |
| `navigate(url)` | Navigate to a URL |
| `loadHtml(html)` | Load HTML content directly |
| `run()` | Run the event loop (blocking) |
| `destroy()` | Destroy the webview and free resources |
| `setTitle(title)` | Set the window title |
| `setSize(width, height)` | Set window dimensions |
| `setResizable(resizable)` | Enable/disable window resizing (1/0) |
| `setVisible(visible)` | Show/hide the window (1/0) |
| `setFullscreen(fullscreen)` | Toggle fullscreen mode (1/0) |
| `eval(js)` | Execute JavaScript and return result |
| `inject(js)` | Inject JS to run on every page load |
| `goBack()` | Navigate back in history |
| `goForward()` | Navigate forward in history |
| `reload()` | Reload current page |
| `stop()` | Stop loading |
| `getUrl()` | Get current URL |
| `getTitle()` | Get page title |
| `setDevTools(enabled)` | Enable/disable developer tools |
| `setUserAgent(userAgent)` | Set custom user agent |
| `setBackgroundColor(r, g, b, a)` | Set background color (0-255) |

## Building the Native Library

If you need to compile the native library yourself:

### macOS
```bash
cd ~/.oxide/modules/webview/src
clang -shared -o ../liboxide_webview.dylib oxide_webview.c -framework WebKit -framework Cocoa
```

### Linux
```bash
cd ~/.oxide/modules/webview/src
gcc -shared -fPIC -o ../liboxide_webview.so oxide_webview.c $(pkg-config --cflags --libs gtk+-3.0 webkit2gtk-4.0)
```

### Windows
Requires WebView2 SDK. See Microsoft's WebView2 documentation.

## Examples

### Simple Browser

```oxide
use webview

wv = Webview.create("Simple Browser", 1280, 800)
wv.load("https://oxide-lang.dev")
wv.enableDevTools()
wv.start()
```

### Local HTML App

```oxide
use webview

app_html = "
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: system-ui; padding: 20px; }
        button { padding: 10px 20px; font-size: 16px; }
    </style>
</head>
<body>
    <h1>Oxide Desktop App</h1>
    <p>This is a native desktop app built with Oxide!</p>
    <button onclick='alert(\"Hello from JavaScript!\")'>Click Me</button>
</body>
</html>
"

wv = Webview.createWithHtml(app_html, "Desktop App", 600, 400)
wv.start()
```

## License

MIT License

## Author

Oxide Team

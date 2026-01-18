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

## Usage

### Basic Example

```oxide
use webview

# Create a webview window
create("My App", 800, 600)

# Navigate to a URL
navigate("https://example.com")

# Run the event loop (blocking)
run()
```

### Load HTML Content

```oxide
use webview

html = "<html><body><h1>Hello from Oxide!</h1></body></html>"

create("HTML Demo", 640, 480)
loadHtml(html)
run()
```

### Object-Oriented Usage

```oxide
use webview

# Create webview instance
wv = new Webview("My Browser", 1024, 768)
wv.open()
wv.load("https://oxide-lang.dev")
wv.start()
```

### JavaScript Interaction

```oxide
use webview

create("JS Demo", 800, 600)
loadHtml("<html><body><div id='result'></div></body></html>")

# Execute JavaScript
eval("document.getElementById('result').innerHTML = 'Updated from Oxide!'")

# Inject JavaScript to run on every page load
inject("console.log('Page loaded!')")

run()
```

### Window Control

```oxide
use webview

create("Resizable App", 800, 600)
navigate("https://example.com")

# Window customization
setTitle("New Title")
setSize(1024, 768)
setResizable(1)
setFullscreen(0)

# Developer tools (macOS 13.3+, Linux)
setDevTools(1)

run()
```

### Navigation Control

```oxide
use webview

create("Browser", 1024, 768)
navigate("https://example.com")

# Navigation functions
goBack()
goForward()
reload()
stop()

# Get current state
url = getUrl()
title = getTitle()

run()
```

## API Reference

### Core Functions

| Function | Description |
|----------|-------------|
| `create(title, width, height)` | Create a new webview window |
| `navigate(url)` | Navigate to a URL |
| `loadHtml(html)` | Load HTML content directly |
| `run()` | Run the event loop (blocking) |
| `destroy()` | Destroy the webview and free resources |

### Window Control

| Function | Description |
|----------|-------------|
| `setTitle(title)` | Set the window title |
| `setSize(width, height)` | Set window dimensions |
| `setResizable(resizable)` | Enable/disable window resizing (1/0) |
| `setVisible(visible)` | Show/hide the window (1/0) |
| `setFullscreen(fullscreen)` | Toggle fullscreen mode (1/0) |

### JavaScript Interaction

| Function | Description |
|----------|-------------|
| `eval(js)` | Execute JavaScript and return result |
| `inject(js)` | Inject JS to run on every page load |
| `bind(name)` | Bind a function name for JS-to-Oxide calls |

### Navigation

| Function | Description |
|----------|-------------|
| `goBack()` | Navigate back in history |
| `goForward()` | Navigate forward in history |
| `reload()` | Reload current page |
| `stop()` | Stop loading |
| `getUrl()` | Get current URL |
| `getTitle()` | Get page title |

### Configuration

| Function | Description |
|----------|-------------|
| `setDevTools(enabled)` | Enable/disable developer tools |
| `setUserAgent(userAgent)` | Set custom user agent |
| `setBackgroundColor(r, g, b, a)` | Set background color (0-255) |

### Convenience Functions (Module-level and Static Methods)

| Function / Static Method | Description |
|--------------------------|-------------|
| `openUrl(url, title, w, h)` / `Webview.openUrl(...)` | Quick function to open URL |
| `openHtml(html, title, w, h)` / `Webview.openHtml(...)` | Quick function to display HTML |
| `dialog(html, title, w, h)` / `Webview.dialog(...)` | Create a dialog with HTML content |
| `alert(message, title)` / `Webview.alert(...)` | Create an alert dialog |
| `confirm(message, title)` / `Webview.confirm(...)` | Create a confirm dialog |
| `createApp(title, w, h, url)` / `Webview.createApp(...)` | Create webview with common app settings |
| `createTransparent(title, w, h)` / `Webview.createTransparent(...)` | Create frameless/transparent webview |

### Webview Class

```oxide
wv = new Webview(title, width, height)
wv.open()              # Create and show window
wv.load(url)           # Navigate to URL
wv.loadContent(html)   # Load HTML content
wv.start()             # Run event loop
wv.close()             # Destroy webview
wv.resize(w, h)        # Resize window
wv.executeJs(js)       # Execute JavaScript
wv.back()              # Go back
wv.forward()           # Go forward
wv.refresh()           # Reload page
```

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

create("Simple Browser", 1280, 800)
navigate("https://oxide-lang.dev")
setDevTools(1)
run()
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

create("Desktop App", 600, 400)
loadHtml(app_html)
run()
```

## License

MIT License

## Author

Oxide Team

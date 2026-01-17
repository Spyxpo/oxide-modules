# =============================================================================
#  Oxide Webview Module
#  Cross-platform native webview for embedding web content in Oxide applications.
#
#  Requirements:
#    macOS:   WebKit framework (built-in)
#    Linux:   gtk+-3.0 and webkit2gtk-4.0
#    Windows: WebView2 Runtime
#
#  Compile the native library:
#    macOS:  clang -shared -o liboxide_webview.dylib oxide_webview.c -framework WebKit -framework Cocoa
#    Linux:  gcc -shared -fPIC -o liboxide_webview.so oxide_webview.c $(pkg-config --cflags --libs gtk+-3.0 webkit2gtk-4.0)
#    Windows: cl /LD oxide_webview.c /Fe:oxide_webview.dll
#
#  Usage:
#    use webview
#    create("My App", 800, 600)
#    navigate("https://example.com")
#    run()
# =============================================================================

# Link the native webview library
link "./modules/webview/liboxide_webview.dylib"

# -----------------------------------------------------------------------------
# Core Webview Functions
# -----------------------------------------------------------------------------

# Create a new webview window
# title: Window title string
# width: Window width in pixels
# height: Window height in pixels
# Returns: 0 on success, -1 on failure
native func create(title, width, height) from "webview_create"

# Navigate to a URL
# url: The URL to navigate to (http://, https://, or file://)
# Returns: 0 on success, -1 on failure
native func navigate(url) from "webview_navigate"

# Load HTML content directly
# html: HTML string to render
# Returns: 0 on success, -1 on failure
native func loadHtml(html) from "webview_load_html"

# Run the webview event loop (blocking)
# Returns when the window is closed
native func run() from "webview_run"

# Destroy the webview and free resources
native func destroy() from "webview_destroy"

# -----------------------------------------------------------------------------
# Window Control Functions
# -----------------------------------------------------------------------------

# Set the window title
# title: New window title string
native func setTitle(title) from "webview_set_title"

# Set the window size
# width: New width in pixels
# height: New height in pixels
native func setSize(width, height) from "webview_set_size"

# Set whether the window is resizable
# resizable: 1 for resizable, 0 for fixed size
native func setResizable(resizable) from "webview_set_resizable"

# Show or hide the webview window
# visible: 1 to show, 0 to hide
native func setVisible(visible) from "webview_set_visible"

# Set the window to fullscreen mode
# fullscreen: 1 for fullscreen, 0 for windowed
native func setFullscreen(fullscreen) from "webview_set_fullscreen"

# -----------------------------------------------------------------------------
# JavaScript Interaction
# -----------------------------------------------------------------------------

# Execute JavaScript in the webview
# js: JavaScript code to execute
# Returns: Result as string (if any)
native func eval(js) from "webview_eval"

# Inject JavaScript to be executed on every page load
# js: JavaScript code to inject
native func inject(js) from "webview_inject"

# Bind a name to call back to Oxide (for JS-to-Oxide communication)
# name: Function name accessible from JavaScript
native func bind(name) from "webview_bind"

# -----------------------------------------------------------------------------
# Navigation Control
# -----------------------------------------------------------------------------

# Navigate back in history
native func goBack() from "webview_go_back"

# Navigate forward in history
native func goForward() from "webview_go_forward"

# Reload the current page
native func reload() from "webview_reload"

# Stop loading the current page
native func stop() from "webview_stop"

# Get the current URL
# Returns: Current URL as string
native func getUrl() from "webview_get_url"

# Get the page title
# Returns: Current page title as string
native func getTitle() from "webview_get_title"

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

# Enable or disable developer tools
# enabled: 1 to enable, 0 to disable
native func setDevTools(enabled) from "webview_set_devtools"

# Set custom user agent string
# userAgent: User agent string
native func setUserAgent(userAgent) from "webview_set_user_agent"

# Set background color (transparent webview)
# r, g, b, a: Color components (0-255)
native func setBackgroundColor(r, g, b, a) from "webview_set_background_color"

# -----------------------------------------------------------------------------
# Webview Class for Object-Oriented Usage
# -----------------------------------------------------------------------------

class Webview
    func init(title, width, height)
        self.title = title
        self.width = width
        self.height = height
        self.url = ""
        self.html = ""
        self.created = False
    endfunc

    func open()
        result = create(self.title, self.width, self.height)
        if result == 0
            self.created = True
        endif
        return result
    endfunc

    func load(url)
        self.url = url
        return navigate(url)
    endfunc

    func loadContent(html)
        self.html = html
        return loadHtml(html)
    endfunc

    func start()
        run()
    endfunc

    func close()
        destroy()
        self.created = False
    endfunc

    func resize(width, height)
        self.width = width
        self.height = height
        setSize(width, height)
    endfunc

    func executeJs(js)
        return eval(js)
    endfunc

    func back()
        goBack()
    endfunc

    func forward()
        goForward()
    endfunc

    func refresh()
        reload()
    endfunc
endclass

# -----------------------------------------------------------------------------
# Convenience Functions
# -----------------------------------------------------------------------------

# Quick function to open a URL in a webview
func openUrl(url, title, width, height)
    create(title, width, height)
    navigate(url)
    run()
endfunc

# Quick function to display HTML content
func openHtml(html, title, width, height)
    create(title, width, height)
    loadHtml(html)
    run()
endfunc

print "Webview module loaded"

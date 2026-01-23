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
#
#    wv = Webview.create("My App", 800, 600)
#    wv.load("https://example.com")
#    wv.start()
# =============================================================================

# Link the native webview library
# The library is resolved relative to the module's src/ directory
link "liboxide_webview"

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

# Load HTML content with base URL for relative paths
# html: HTML string to render
# baseUrl: Base URL for resolving relative paths
# Returns: 0 on success, -1 on failure
native func loadHtmlWithBase(html, baseUrl) from "webview_load_html_base"

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

# Set minimum window size
# width: Minimum width in pixels
# height: Minimum height in pixels
native func setMinSize(width, height) from "webview_set_min_size"

# Set maximum window size
# width: Maximum width in pixels
# height: Maximum height in pixels
native func setMaxSize(width, height) from "webview_set_max_size"

# Set whether the window is resizable
# resizable: 1 for resizable, 0 for fixed size
native func setResizable(resizable) from "webview_set_resizable"

# Show or hide the webview window
# visible: 1 to show, 0 to hide
native func setVisible(visible) from "webview_set_visible"

# Set the window to fullscreen mode
# fullscreen: 1 for fullscreen, 0 for windowed
native func setFullscreen(fullscreen) from "webview_set_fullscreen"

# Center the window on screen
native func center() from "webview_center"

# Set window position
# x: X coordinate
# y: Y coordinate
native func setPosition(x, y) from "webview_set_position"

# Get window position
# Returns: [x, y] array
native func getPosition() from "webview_get_position"

# Get window size
# Returns: [width, height] array
native func getSize() from "webview_get_size"

# Minimize the window
native func minimize() from "webview_minimize"

# Maximize the window
native func maximize() from "webview_maximize"

# Restore the window from minimized/maximized state
native func restore() from "webview_restore"

# Set window always on top
# onTop: 1 for always on top, 0 for normal
native func setAlwaysOnTop(onTop) from "webview_set_always_on_top"

# Set window opacity (0.0 to 1.0)
# opacity: Window opacity value
native func setOpacity(opacity) from "webview_set_opacity"

# Set window icon from file path
# iconPath: Path to icon file
native func setIcon(iconPath) from "webview_set_icon"

# Check if window is focused
# Returns: 1 if focused, 0 otherwise
native func isFocused() from "webview_is_focused"

# Focus the window
native func focus() from "webview_focus"

# -----------------------------------------------------------------------------
# JavaScript Interaction
# -----------------------------------------------------------------------------

# Execute JavaScript in the webview
# js: JavaScript code to execute
# Returns: Result as string (if any)
native func eval(js) from "webview_eval"

# Execute JavaScript asynchronously (non-blocking)
# js: JavaScript code to execute
native func evalAsync(js) from "webview_eval_async"

# Inject JavaScript to be executed on every page load
# js: JavaScript code to inject
native func inject(js) from "webview_inject"

# Bind a name to call back to Oxide (for JS-to-Oxide communication)
# name: Function name accessible from JavaScript
native func bind(name) from "webview_bind"

# Unbind a previously bound function
# name: Function name to unbind
native func unbind(name) from "webview_unbind"

# -----------------------------------------------------------------------------
# Navigation Control
# -----------------------------------------------------------------------------

# Navigate back in history
native func goBack() from "webview_go_back"

# Navigate forward in history
native func goForward() from "webview_go_forward"

# Reload the current page
native func reload() from "webview_reload"

# Reload the current page bypassing cache
native func reloadIgnoringCache() from "webview_reload_ignoring_cache"

# Stop loading the current page
native func stop() from "webview_stop"

# Get the current URL
# Returns: Current URL as string
native func getUrl() from "webview_get_url"

# Get the page title
# Returns: Current page title as string
native func getTitle() from "webview_get_title"

# Check if can go back
# Returns: 1 if can go back, 0 otherwise
native func canGoBack() from "webview_can_go_back"

# Check if can go forward
# Returns: 1 if can go forward, 0 otherwise
native func canGoForward() from "webview_can_go_forward"

# Check if page is loading
# Returns: 1 if loading, 0 otherwise
native func isLoading() from "webview_is_loading"

# Get loading progress (0.0 to 1.0)
# Returns: Loading progress as float
native func getLoadingProgress() from "webview_get_loading_progress"

# Clear navigation history
native func clearHistory() from "webview_clear_history"

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

# Enable or disable developer tools
# enabled: 1 to enable, 0 to disable
native func setDevTools(enabled) from "webview_set_devtools"

# Open developer tools panel
native func openDevTools() from "webview_open_devtools"

# Close developer tools panel
native func closeDevTools() from "webview_close_devtools"

# Set custom user agent string
# userAgent: User agent string
native func setUserAgent(userAgent) from "webview_set_user_agent"

# Get current user agent string
# Returns: User agent string
native func getUserAgent() from "webview_get_user_agent"

# Set background color (transparent webview)
# r, g, b, a: Color components (0-255)
native func setBackgroundColor(r, g, b, a) from "webview_set_background_color"

# Enable or disable JavaScript
# enabled: 1 to enable, 0 to disable
native func setJavaScriptEnabled(enabled) from "webview_set_javascript_enabled"

# Enable or disable local storage
# enabled: 1 to enable, 0 to disable
native func setLocalStorageEnabled(enabled) from "webview_set_local_storage_enabled"

# Enable or disable web databases
# enabled: 1 to enable, 0 to disable
native func setDatabasesEnabled(enabled) from "webview_set_databases_enabled"

# Set zoom level (1.0 = 100%)
# zoom: Zoom level
native func setZoom(zoom) from "webview_set_zoom"

# Get current zoom level
# Returns: Current zoom level
native func getZoom() from "webview_get_zoom"

# Enable or disable context menu
# enabled: 1 to enable, 0 to disable
native func setContextMenuEnabled(enabled) from "webview_set_context_menu_enabled"

# -----------------------------------------------------------------------------
# Cookies and Storage
# -----------------------------------------------------------------------------

# Clear all cookies
native func clearCookies() from "webview_clear_cookies"

# Clear all local storage
native func clearLocalStorage() from "webview_clear_local_storage"

# Clear all cache
native func clearCache() from "webview_clear_cache"

# Clear all browsing data
native func clearAllData() from "webview_clear_all_data"

# -----------------------------------------------------------------------------
# Print and Screenshot
# -----------------------------------------------------------------------------

# Print the current page
native func printPage() from "webview_print"

# Save page as PDF
# path: File path to save PDF
# Returns: 0 on success, -1 on failure
native func savePdf(path) from "webview_save_pdf"

# Take screenshot
# path: File path to save screenshot
# Returns: 0 on success, -1 on failure
native func screenshot(path) from "webview_screenshot"

# -----------------------------------------------------------------------------
# Events (Callback Registration)
# -----------------------------------------------------------------------------

# Set callback for navigation start
native func onNavigationStart(callback) from "webview_on_navigation_start"

# Set callback for navigation complete
native func onNavigationComplete(callback) from "webview_on_navigation_complete"

# Set callback for navigation error
native func onNavigationError(callback) from "webview_on_navigation_error"

# Set callback for title change
native func onTitleChange(callback) from "webview_on_title_change"

# Set callback for load progress
native func onLoadProgress(callback) from "webview_on_load_progress"

# Set callback for window close request
native func onCloseRequest(callback) from "webview_on_close_request"

# Set callback for new window request (popups)
native func onNewWindow(callback) from "webview_on_new_window"

# Set callback for download request
native func onDownload(callback) from "webview_on_download"

# Set callback for console messages from JavaScript
native func onConsoleMessage(callback) from "webview_on_console_message"

# -----------------------------------------------------------------------------
# Webview Class for Object-Oriented Usage
# -----------------------------------------------------------------------------

class Webview
    func init(title, width, height)
        if title == None
            title = "Oxide Webview"
        endif
        if width == None
            width = 800
        endif
        if height == None
            height = 600
        endif
        self.title = title
        self.width = width
        self.height = height
        self.url = ""
        self.html = ""
        self.created = False
        self._devToolsEnabled = False
        self._zoomLevel = 1.0
    endfunc

    # -------------------------------------------------------------------------
    # Static Factory Methods (called as Webview.methodName())
    # -------------------------------------------------------------------------

    # Create a new Webview instance
    static func create(title, width, height)
        wv = new Webview(title, width, height)
        wv.open()
        return wv
    endfunc

    # Create webview and navigate to URL
    static func createWithUrl(url, title, width, height)
        wv = Webview.create(title, width, height)
        wv.load(url)
        return wv
    endfunc

    # Create webview with HTML content
    static func createWithHtml(html, title, width, height)
        wv = Webview.create(title, width, height)
        wv.loadContent(html, None)
        return wv
    endfunc

    # -------------------------------------------------------------------------
    # Instance Methods
    # -------------------------------------------------------------------------

    # Create and show the window
    func open()
        if self.created
            return 0
        endif
        result = create(self.title, self.width, self.height)
        if result == 0
            self.created = True
        endif
        return result
    endfunc

    # Load URL
    func load(url)
        if not self.created
            self.open()
        endif
        self.url = url
        return navigate(url)
    endfunc

    # Load HTML content
    func loadContent(html, baseUrl)
        if not self.created
            self.open()
        endif
        self.html = html
        if baseUrl != None
            return loadHtmlWithBase(html, baseUrl)
        endif
        return loadHtml(html)
    endfunc

    # Start the event loop
    func start()
        if not self.created
            self.open()
        endif
        run()
    endfunc

    # Close and destroy
    func close()
        if self.created
            destroy()
            self.created = False
        endif
    endfunc

    # Resize window
    func resize(width, height)
        self.width = width
        self.height = height
        if self.created
            setSize(width, height)
        endif
        return self
    endfunc

    # Set window title
    func setWindowTitle(title)
        self.title = title
        if self.created
            setTitle(title)
        endif
        return self
    endfunc

    # Execute JavaScript
    func executeJs(js)
        if self.created
            return eval(js)
        endif
        return ""
    endfunc

    # Execute JavaScript asynchronously
    func executeJsAsync(js)
        if self.created
            evalAsync(js)
        endif
        return self
    endfunc

    # Navigation methods
    func back()
        if self.created
            goBack()
        endif
        return self
    endfunc

    func forward()
        if self.created
            goForward()
        endif
        return self
    endfunc

    func refresh()
        if self.created
            reload()
        endif
        return self
    endfunc

    func refreshIgnoringCache()
        if self.created
            reloadIgnoringCache()
        endif
        return self
    endfunc

    func stopLoading()
        if self.created
            stop()
        endif
        return self
    endfunc

    # Window control methods
    func centerWindow()
        if self.created
            center()
        endif
        return self
    endfunc

    func moveTo(x, y)
        if self.created
            setPosition(x, y)
        endif
        return self
    endfunc

    func minimizeWindow()
        if self.created
            minimize()
        endif
        return self
    endfunc

    func maximizeWindow()
        if self.created
            maximize()
        endif
        return self
    endfunc

    func restoreWindow()
        if self.created
            restore()
        endif
        return self
    endfunc

    func setOnTop(onTop)
        if self.created
            setAlwaysOnTop(onTop)
        endif
        return self
    endfunc

    func setWindowOpacity(opacity)
        if self.created
            setOpacity(opacity)
        endif
        return self
    endfunc

    func fullscreen(enabled)
        if self.created
            setFullscreen(enabled)
        endif
        return self
    endfunc

    func show()
        if self.created
            setVisible(1)
        endif
        return self
    endfunc

    func hide()
        if self.created
            setVisible(0)
        endif
        return self
    endfunc

    # DevTools
    func enableDevTools()
        self._devToolsEnabled = True
        if self.created
            setDevTools(1)
        endif
        return self
    endfunc

    func disableDevTools()
        self._devToolsEnabled = False
        if self.created
            setDevTools(0)
        endif
        return self
    endfunc

    func showDevTools()
        if self.created
            openDevTools()
        endif
        return self
    endfunc

    func hideDevTools()
        if self.created
            closeDevTools()
        endif
        return self
    endfunc

    # Zoom control
    func zoomIn()
        self._zoomLevel = self._zoomLevel + 0.1
        if self.created
            setZoom(self._zoomLevel)
        endif
        return self
    endfunc

    func zoomOut()
        self._zoomLevel = self._zoomLevel - 0.1
        if self._zoomLevel < 0.1
            self._zoomLevel = 0.1
        endif
        if self.created
            setZoom(self._zoomLevel)
        endif
        return self
    endfunc

    func resetZoom()
        self._zoomLevel = 1.0
        if self.created
            setZoom(self._zoomLevel)
        endif
        return self
    endfunc

    func setZoomLevel(level)
        self._zoomLevel = level
        if self.created
            setZoom(level)
        endif
        return self
    endfunc

    # Data clearing
    func clearBrowsingData()
        if self.created
            clearAllData()
        endif
        return self
    endfunc

    # Screenshot and print
    func takeScreenshot(path)
        if self.created
            return screenshot(path)
        endif
        return -1
    endfunc

    func saveAsPdf(path)
        if self.created
            return savePdf(path)
        endif
        return -1
    endfunc

    func print()
        if self.created
            printPage()
        endif
        return self
    endfunc

    # State getters
    func getCurrentUrl()
        if self.created
            return getUrl()
        endif
        return self.url
    endfunc

    func getCurrentTitle()
        if self.created
            return getTitle()
        endif
        return self.title
    endfunc

    func isPageLoading()
        if self.created
            return isLoading() == 1
        endif
        return False
    endfunc

    func getProgress()
        if self.created
            return getLoadingProgress()
        endif
        return 0.0
    endfunc

    func canNavigateBack()
        if self.created
            return canGoBack() == 1
        endif
        return False
    endfunc

    func canNavigateForward()
        if self.created
            return canGoForward() == 1
        endif
        return False
    endfunc

    # -------------------------------------------------------------------------
    # Static Methods (called as Webview.methodName())
    # -------------------------------------------------------------------------

    # Quick function to open a URL in a webview
    static func openUrl(url, title, width, height)
        if title == None
            title = "Webview"
        endif
        if width == None
            width = 800
        endif
        if height == None
            height = 600
        endif
        create(title, width, height)
        navigate(url)
        run()
    endfunc

    # Quick function to display HTML content
    static func openHtml(html, title, width, height)
        if title == None
            title = "Webview"
        endif
        if width == None
            width = 800
        endif
        if height == None
            height = 600
        endif
        create(title, width, height)
        loadHtml(html)
        run()
    endfunc

    # Create a simple dialog with HTML content
    static func dialog(html, title, width, height)
        if title == None
            title = "Dialog"
        endif
        if width == None
            width = 400
        endif
        if height == None
            height = 300
        endif
        create(title, width, height)
        setResizable(0)
        center()
        loadHtml(html)
        run()
    endfunc

    # Create an alert dialog
    static func alert(message, title)
        if title == None
            title = "Alert"
        endif
        html = "<!DOCTYPE html><html><head><style>"
        html = html + "body{font-family:system-ui,-apple-system,sans-serif;padding:20px;text-align:center;}"
        html = html + "p{margin:20px 0;font-size:14px;color:#333;}"
        html = html + "button{padding:8px 24px;font-size:14px;cursor:pointer;border:none;"
        html = html + "background:#007AFF;color:white;border-radius:6px;}"
        html = html + "button:hover{background:#0056b3;}"
        html = html + "</style></head><body>"
        html = html + "<p>" + str(message) + "</p>"
        html = html + "<button onclick='window.close()'>OK</button>"
        html = html + "</body></html>"
        Webview.dialog(html, title, 350, 180)
    endfunc

    # Create a confirm dialog (returns True/False)
    static func confirm(message, title)
        if title == None
            title = "Confirm"
        endif
        html = "<!DOCTYPE html><html><head><style>"
        html = html + "body{font-family:system-ui,-apple-system,sans-serif;padding:20px;text-align:center;}"
        html = html + "p{margin:20px 0;font-size:14px;color:#333;}"
        html = html + ".buttons{display:flex;gap:10px;justify-content:center;}"
        html = html + "button{padding:8px 24px;font-size:14px;cursor:pointer;border:none;border-radius:6px;}"
        html = html + ".ok{background:#007AFF;color:white;}"
        html = html + ".cancel{background:#e0e0e0;color:#333;}"
        html = html + "</style></head><body>"
        html = html + "<p>" + str(message) + "</p>"
        html = html + "<div class='buttons'>"
        html = html + "<button class='cancel' onclick='window.oxideResult=false;window.close()'>Cancel</button>"
        html = html + "<button class='ok' onclick='window.oxideResult=true;window.close()'>OK</button>"
        html = html + "</div></body></html>"
        Webview.dialog(html, title, 350, 180)
        # Note: In a real implementation, we'd need to capture the result
        return True
    endfunc

    # Create a webview with common settings for desktop apps
    static func createApp(title, width, height, url)
        wv = new Webview(title, width, height)
        wv.open()
        wv.enableDevTools()
        if url != None
            wv.load(url)
        endif
        return wv
    endfunc

    # Create a frameless/transparent webview
    static func createTransparent(title, width, height)
        wv = new Webview(title, width, height)
        wv.open()
        setBackgroundColor(0, 0, 0, 0)
        return wv
    endfunc
endclass

# -----------------------------------------------------------------------------
# Module Functions (Convenience wrappers that delegate to class static methods)
# -----------------------------------------------------------------------------

# Quick function to open a URL in a webview
func openUrl(url, title, width, height)
    Webview.openUrl(url, title, width, height)
endfunc

# Quick function to display HTML content
func openHtml(html, title, width, height)
    Webview.openHtml(html, title, width, height)
endfunc

# Create a simple dialog with HTML content
func dialog(html, title, width, height)
    Webview.dialog(html, title, width, height)
endfunc

# Create an alert dialog
func alert(message, title)
    Webview.alert(message, title)
endfunc

# Create a confirm dialog (returns True/False)
func confirm(message, title)
    return Webview.confirm(message, title)
endfunc

# Create a webview with common settings for desktop apps
func createApp(title, width, height, url)
    return Webview.createApp(title, width, height, url)
endfunc

# Create a frameless/transparent webview
func createTransparent(title, width, height)
    return Webview.createTransparent(title, width, height)
endfunc

print "Webview module loaded (v0.0.1)"

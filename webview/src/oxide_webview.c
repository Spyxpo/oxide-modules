/*
 * Oxide Webview Module - Native Implementation
 * Cross-platform native webview for embedding web content in Oxide applications.
 *
 * Compile:
 *   macOS:   clang -shared -o liboxide_webview.dylib oxide_webview.c -framework WebKit -framework Cocoa
 *   Linux:   gcc -shared -fPIC -o liboxide_webview.so oxide_webview.c $(pkg-config --cflags --libs gtk+-3.0 webkit2gtk-4.0)
 *   Windows: cl /LD oxide_webview.c /Fe:oxide_webview.dll (requires WebView2)
 *
 * Requirements:
 *   macOS:   WebKit framework (built-in on macOS 10.13+)
 *   Linux:   gtk+-3.0, webkit2gtk-4.0 (apt install libgtk-3-dev libwebkit2gtk-4.0-dev)
 *   Windows: WebView2 Runtime (https://developer.microsoft.com/microsoft-edge/webview2/)
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
    #define OXIDE_EXPORT __declspec(dllexport)
#else
    #define OXIDE_EXPORT
#endif

/* =============================================================================
 * macOS Implementation using WebKit
 * ============================================================================= */
#ifdef __APPLE__

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

static NSWindow* window = nil;
static WKWebView* webview = nil;
static NSApplication* app = nil;
static char* current_url = NULL;
static char* current_title = NULL;
static char* injected_js = NULL;
static double loading_progress = 0.0;
static BOOL is_loading = NO;

@interface WebviewDelegate : NSObject <WKNavigationDelegate, NSWindowDelegate>
@end

@implementation WebviewDelegate

- (void)webView:(WKWebView *)wv didStartProvisionalNavigation:(WKNavigation *)navigation {
    is_loading = YES;
    loading_progress = 0.0;
}

- (void)webView:(WKWebView *)wv didCommitNavigation:(WKNavigation *)navigation {
    loading_progress = 0.5;
}

- (void)webView:(WKWebView *)wv didFinishNavigation:(WKNavigation *)navigation {
    is_loading = NO;
    loading_progress = 1.0;

    // Update current URL
    if (current_url) free(current_url);
    current_url = strdup([[wv.URL absoluteString] UTF8String] ?: "");

    // Update current title
    if (current_title) free(current_title);
    current_title = strdup([wv.title UTF8String] ?: "");

    // Execute injected JS if any
    if (injected_js) {
        [wv evaluateJavaScript:[NSString stringWithUTF8String:injected_js] completionHandler:nil];
    }
}

- (void)webView:(WKWebView *)wv didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    is_loading = NO;
    loading_progress = 0.0;
}

- (void)webView:(WKWebView *)wv didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    is_loading = NO;
    loading_progress = 0.0;
}

- (BOOL)windowShouldClose:(NSWindow *)sender {
    [NSApp stop:nil];
    return YES;
}

@end

static WebviewDelegate* delegate = nil;

OXIDE_EXPORT long long webview_create(const char* title, long long width, long long height) {
    @autoreleasepool {
        if (!app) {
            app = [NSApplication sharedApplication];
            [app setActivationPolicy:NSApplicationActivationPolicyRegular];

            // Create default menu
            NSMenu* menubar = [[NSMenu alloc] init];
            NSMenuItem* appMenuItem = [[NSMenuItem alloc] init];
            [menubar addItem:appMenuItem];
            NSMenu* appMenu = [[NSMenu alloc] init];
            [appMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
            [appMenuItem setSubmenu:appMenu];
            [app setMainMenu:menubar];
        }

        NSRect frame = NSMakeRect(0, 0, width, height);
        NSUInteger style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                          NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable;

        window = [[NSWindow alloc] initWithContentRect:frame
                                             styleMask:style
                                               backing:NSBackingStoreBuffered
                                                 defer:NO];

        [window setTitle:[NSString stringWithUTF8String:title]];
        [window center];
        [window setReleasedWhenClosed:NO];

        WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
        config.preferences.javaScriptEnabled = YES;

        // Enable local storage
        [config.preferences setValue:@YES forKey:@"localStorageEnabled"];

        webview = [[WKWebView alloc] initWithFrame:frame configuration:config];
        webview.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [window setContentView:webview];

        delegate = [[WebviewDelegate alloc] init];
        webview.navigationDelegate = delegate;
        window.delegate = delegate;

        [window makeKeyAndOrderFront:nil];
        [app activateIgnoringOtherApps:YES];

        return 0;
    }
}

OXIDE_EXPORT long long webview_navigate(const char* url) {
    if (!webview) return -1;
    @autoreleasepool {
        NSString* urlStr = [NSString stringWithUTF8String:url];
        NSURL* nsurl = [NSURL URLWithString:urlStr];
        if (!nsurl) {
            // Try adding http:// prefix
            nsurl = [NSURL URLWithString:[@"http://" stringByAppendingString:urlStr]];
        }
        if (!nsurl) return -1;
        NSURLRequest* request = [NSURLRequest requestWithURL:nsurl];
        [webview loadRequest:request];
        return 0;
    }
}

OXIDE_EXPORT long long webview_load_html(const char* html) {
    if (!webview) return -1;
    @autoreleasepool {
        [webview loadHTMLString:[NSString stringWithUTF8String:html] baseURL:nil];
        return 0;
    }
}

OXIDE_EXPORT long long webview_load_html_base(const char* html, const char* baseUrl) {
    if (!webview) return -1;
    @autoreleasepool {
        NSURL* base = baseUrl ? [NSURL URLWithString:[NSString stringWithUTF8String:baseUrl]] : nil;
        [webview loadHTMLString:[NSString stringWithUTF8String:html] baseURL:base];
        return 0;
    }
}

OXIDE_EXPORT void webview_run(void) {
    if (!app) return;
    @autoreleasepool {
        [app run];
    }
}

OXIDE_EXPORT void webview_destroy(void) {
    @autoreleasepool {
        if (webview) {
            [webview stopLoading];
            webview = nil;
        }
        if (window) {
            [window close];
            window = nil;
        }
        if (current_url) {
            free(current_url);
            current_url = NULL;
        }
        if (current_title) {
            free(current_title);
            current_title = NULL;
        }
        if (injected_js) {
            free(injected_js);
            injected_js = NULL;
        }
    }
}

OXIDE_EXPORT void webview_set_title(const char* title) {
    if (!window) return;
    @autoreleasepool {
        [window setTitle:[NSString stringWithUTF8String:title]];
    }
}

OXIDE_EXPORT void webview_set_size(long long width, long long height) {
    if (!window) return;
    @autoreleasepool {
        NSRect frame = window.frame;
        frame.size.width = width;
        frame.size.height = height;
        [window setFrame:frame display:YES animate:YES];
    }
}

OXIDE_EXPORT void webview_set_min_size(long long width, long long height) {
    if (!window) return;
    @autoreleasepool {
        [window setMinSize:NSMakeSize(width, height)];
    }
}

OXIDE_EXPORT void webview_set_max_size(long long width, long long height) {
    if (!window) return;
    @autoreleasepool {
        [window setMaxSize:NSMakeSize(width, height)];
    }
}

OXIDE_EXPORT void webview_set_resizable(long long resizable) {
    if (!window) return;
    @autoreleasepool {
        NSUInteger style = window.styleMask;
        if (resizable) {
            style |= NSWindowStyleMaskResizable;
        } else {
            style &= ~NSWindowStyleMaskResizable;
        }
        [window setStyleMask:style];
    }
}

OXIDE_EXPORT void webview_set_visible(long long visible) {
    if (!window) return;
    @autoreleasepool {
        if (visible) {
            [window makeKeyAndOrderFront:nil];
        } else {
            [window orderOut:nil];
        }
    }
}

OXIDE_EXPORT void webview_set_fullscreen(long long fullscreen) {
    if (!window) return;
    @autoreleasepool {
        BOOL isFullscreen = (window.styleMask & NSWindowStyleMaskFullScreen) != 0;
        if ((fullscreen && !isFullscreen) || (!fullscreen && isFullscreen)) {
            [window toggleFullScreen:nil];
        }
    }
}

OXIDE_EXPORT void webview_center(void) {
    if (!window) return;
    @autoreleasepool {
        [window center];
    }
}

OXIDE_EXPORT void webview_set_position(long long x, long long y) {
    if (!window) return;
    @autoreleasepool {
        NSRect frame = window.frame;
        // Convert from top-left to bottom-left coordinate system
        NSRect screenFrame = [[NSScreen mainScreen] frame];
        frame.origin.x = x;
        frame.origin.y = screenFrame.size.height - y - frame.size.height;
        [window setFrame:frame display:YES];
    }
}

OXIDE_EXPORT long long webview_get_position(void) {
    // Returns packed x,y - use separate calls in real implementation
    if (!window) return 0;
    @autoreleasepool {
        NSRect frame = window.frame;
        return (long long)frame.origin.x;
    }
}

OXIDE_EXPORT long long webview_get_size(void) {
    // Returns packed width,height - use separate calls in real implementation
    if (!window) return 0;
    @autoreleasepool {
        NSRect frame = window.frame;
        return (long long)frame.size.width;
    }
}

OXIDE_EXPORT void webview_minimize(void) {
    if (!window) return;
    @autoreleasepool {
        [window miniaturize:nil];
    }
}

OXIDE_EXPORT void webview_maximize(void) {
    if (!window) return;
    @autoreleasepool {
        [window zoom:nil];
    }
}

OXIDE_EXPORT void webview_restore(void) {
    if (!window) return;
    @autoreleasepool {
        if ([window isMiniaturized]) {
            [window deminiaturize:nil];
        } else if ([window isZoomed]) {
            [window zoom:nil];
        }
    }
}

OXIDE_EXPORT void webview_set_always_on_top(long long onTop) {
    if (!window) return;
    @autoreleasepool {
        [window setLevel:onTop ? NSFloatingWindowLevel : NSNormalWindowLevel];
    }
}

OXIDE_EXPORT void webview_set_opacity(double opacity) {
    if (!window) return;
    @autoreleasepool {
        [window setAlphaValue:opacity];
    }
}

OXIDE_EXPORT void webview_set_icon(const char* iconPath) {
    // macOS uses app bundle icon, individual window icons not typically used
}

OXIDE_EXPORT long long webview_is_focused(void) {
    if (!window) return 0;
    @autoreleasepool {
        return [window isKeyWindow] ? 1 : 0;
    }
}

OXIDE_EXPORT void webview_focus(void) {
    if (!window) return;
    @autoreleasepool {
        [window makeKeyAndOrderFront:nil];
        [app activateIgnoringOtherApps:YES];
    }
}

static char* eval_result = NULL;

OXIDE_EXPORT const char* webview_eval(const char* js) {
    if (!webview) return "";

    __block BOOL done = NO;
    __block NSString* result = nil;

    @autoreleasepool {
        [webview evaluateJavaScript:[NSString stringWithUTF8String:js]
                  completionHandler:^(id _result, NSError* error) {
            if (!error && _result) {
                result = [NSString stringWithFormat:@"%@", _result];
            }
            done = YES;
        }];

        // Wait for completion (with timeout)
        NSDate* timeout = [NSDate dateWithTimeIntervalSinceNow:5.0];
        while (!done && [[NSDate date] compare:timeout] == NSOrderedAscending) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeout];
        }

        if (eval_result) free(eval_result);
        eval_result = result ? strdup([result UTF8String]) : strdup("");
    }

    return eval_result;
}

OXIDE_EXPORT void webview_eval_async(const char* js) {
    if (!webview) return;
    @autoreleasepool {
        [webview evaluateJavaScript:[NSString stringWithUTF8String:js] completionHandler:nil];
    }
}

OXIDE_EXPORT void webview_inject(const char* js) {
    if (injected_js) free(injected_js);
    injected_js = strdup(js);

    // Also add as user script for new navigations
    if (webview) {
        @autoreleasepool {
            WKUserScript* userScript = [[WKUserScript alloc]
                initWithSource:[NSString stringWithUTF8String:js]
                injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                forMainFrameOnly:YES];
            [webview.configuration.userContentController addUserScript:userScript];
        }
    }
}

OXIDE_EXPORT void webview_bind(const char* name) {
    // Bind a JavaScript function name to call back to Oxide
    // This creates a window.<name>() function that posts messages
    if (!webview) return;
    @autoreleasepool {
        NSString* script = [NSString stringWithFormat:
            @"window.%s = function(...args) { "
            @"  window.webkit.messageHandlers.oxide.postMessage({name: '%s', args: args}); "
            @"};", name, name];

        WKUserScript* userScript = [[WKUserScript alloc]
            initWithSource:script
            injectionTime:WKUserScriptInjectionTimeAtDocumentStart
            forMainFrameOnly:NO];

        [webview.configuration.userContentController addUserScript:userScript];
    }
}

OXIDE_EXPORT void webview_unbind(const char* name) {
    if (!webview) return;
    @autoreleasepool {
        NSString* script = [NSString stringWithFormat:@"delete window.%s;", name];
        [webview evaluateJavaScript:script completionHandler:nil];
    }
}

OXIDE_EXPORT void webview_go_back(void) {
    if (!webview) return;
    @autoreleasepool {
        if ([webview canGoBack]) {
            [webview goBack];
        }
    }
}

OXIDE_EXPORT void webview_go_forward(void) {
    if (!webview) return;
    @autoreleasepool {
        if ([webview canGoForward]) {
            [webview goForward];
        }
    }
}

OXIDE_EXPORT void webview_reload(void) {
    if (!webview) return;
    @autoreleasepool {
        [webview reload];
    }
}

OXIDE_EXPORT void webview_reload_ignoring_cache(void) {
    if (!webview) return;
    @autoreleasepool {
        [webview reloadFromOrigin];
    }
}

OXIDE_EXPORT void webview_stop(void) {
    if (!webview) return;
    @autoreleasepool {
        [webview stopLoading];
    }
}

OXIDE_EXPORT const char* webview_get_url(void) {
    if (!webview) return "";
    @autoreleasepool {
        if (current_url) free(current_url);
        current_url = strdup([[webview.URL absoluteString] UTF8String] ?: "");
    }
    return current_url ? current_url : "";
}

OXIDE_EXPORT const char* webview_get_title(void) {
    if (!webview) return "";
    @autoreleasepool {
        if (current_title) free(current_title);
        current_title = strdup([webview.title UTF8String] ?: "");
    }
    return current_title ? current_title : "";
}

OXIDE_EXPORT long long webview_can_go_back(void) {
    if (!webview) return 0;
    @autoreleasepool {
        return [webview canGoBack] ? 1 : 0;
    }
}

OXIDE_EXPORT long long webview_can_go_forward(void) {
    if (!webview) return 0;
    @autoreleasepool {
        return [webview canGoForward] ? 1 : 0;
    }
}

OXIDE_EXPORT long long webview_is_loading(void) {
    if (!webview) return 0;
    @autoreleasepool {
        return [webview isLoading] ? 1 : 0;
    }
}

OXIDE_EXPORT double webview_get_loading_progress(void) {
    if (!webview) return 0.0;
    @autoreleasepool {
        return webview.estimatedProgress;
    }
}

OXIDE_EXPORT void webview_clear_history(void) {
    // WebKit doesn't expose back/forward list manipulation directly
}

OXIDE_EXPORT void webview_set_devtools(long long enabled) {
    // Developer tools can be enabled via WKPreferences in newer macOS versions
    if (!webview) return;
    @autoreleasepool {
        if (@available(macOS 13.3, *)) {
            webview.inspectable = enabled ? YES : NO;
        }
    }
}

OXIDE_EXPORT void webview_open_devtools(void) {
    // macOS WebKit opens devtools via menu or right-click inspect
    webview_set_devtools(1);
}

OXIDE_EXPORT void webview_close_devtools(void) {
    // Not directly controllable in WebKit
}

OXIDE_EXPORT void webview_set_user_agent(const char* userAgent) {
    if (!webview) return;
    @autoreleasepool {
        webview.customUserAgent = [NSString stringWithUTF8String:userAgent];
    }
}

static char* user_agent_result = NULL;

OXIDE_EXPORT const char* webview_get_user_agent(void) {
    if (!webview) return "";
    @autoreleasepool {
        if (user_agent_result) free(user_agent_result);
        user_agent_result = strdup([webview.customUserAgent UTF8String] ?: "");
    }
    return user_agent_result ? user_agent_result : "";
}

OXIDE_EXPORT void webview_set_background_color(long long r, long long g, long long b, long long a) {
    if (!webview) return;
    @autoreleasepool {
        if (a < 255) {
            // Make webview background transparent
            [webview setValue:@NO forKey:@"drawsBackground"];
            [window setOpaque:NO];
            [window setBackgroundColor:[NSColor clearColor]];
        } else {
            [webview setValue:@YES forKey:@"drawsBackground"];
        }
        NSColor* color = [NSColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/255.0];
        [window setBackgroundColor:color];
    }
}

OXIDE_EXPORT void webview_set_javascript_enabled(long long enabled) {
    if (!webview) return;
    @autoreleasepool {
        webview.configuration.preferences.javaScriptEnabled = enabled ? YES : NO;
    }
}

OXIDE_EXPORT void webview_set_local_storage_enabled(long long enabled) {
    if (!webview) return;
    @autoreleasepool {
        [webview.configuration.preferences setValue:@(enabled ? YES : NO) forKey:@"localStorageEnabled"];
    }
}

OXIDE_EXPORT void webview_set_databases_enabled(long long enabled) {
    if (!webview) return;
    @autoreleasepool {
        [webview.configuration.preferences setValue:@(enabled ? YES : NO) forKey:@"databasesEnabled"];
    }
}

static double zoom_level = 1.0;

OXIDE_EXPORT void webview_set_zoom(double zoom) {
    if (!webview) return;
    zoom_level = zoom;
    @autoreleasepool {
        [webview setPageZoom:zoom];
    }
}

OXIDE_EXPORT double webview_get_zoom(void) {
    if (!webview) return 1.0;
    @autoreleasepool {
        return webview.pageZoom;
    }
}

OXIDE_EXPORT void webview_set_context_menu_enabled(long long enabled) {
    // Would need to subclass WKWebView and override willOpenMenuWithEvent
}

OXIDE_EXPORT void webview_clear_cookies(void) {
    @autoreleasepool {
        WKWebsiteDataStore* store = [WKWebsiteDataStore defaultDataStore];
        NSSet* types = [NSSet setWithObject:WKWebsiteDataTypeCookies];
        [store removeDataOfTypes:types modifiedSince:[NSDate distantPast] completionHandler:^{}];
    }
}

OXIDE_EXPORT void webview_clear_local_storage(void) {
    @autoreleasepool {
        WKWebsiteDataStore* store = [WKWebsiteDataStore defaultDataStore];
        NSSet* types = [NSSet setWithObject:WKWebsiteDataTypeLocalStorage];
        [store removeDataOfTypes:types modifiedSince:[NSDate distantPast] completionHandler:^{}];
    }
}

OXIDE_EXPORT void webview_clear_cache(void) {
    @autoreleasepool {
        WKWebsiteDataStore* store = [WKWebsiteDataStore defaultDataStore];
        NSSet* types = [NSSet setWithObjects:WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache, nil];
        [store removeDataOfTypes:types modifiedSince:[NSDate distantPast] completionHandler:^{}];
    }
}

OXIDE_EXPORT void webview_clear_all_data(void) {
    @autoreleasepool {
        WKWebsiteDataStore* store = [WKWebsiteDataStore defaultDataStore];
        NSSet* types = [WKWebsiteDataStore allWebsiteDataTypes];
        [store removeDataOfTypes:types modifiedSince:[NSDate distantPast] completionHandler:^{}];
    }
}

OXIDE_EXPORT void webview_print(void) {
    if (!webview) return;
    @autoreleasepool {
        NSPrintInfo* printInfo = [NSPrintInfo sharedPrintInfo];
        NSPrintOperation* op = [webview printOperationWithPrintInfo:printInfo];
        [op runOperation];
    }
}

OXIDE_EXPORT long long webview_save_pdf(const char* path) {
    if (!webview) return -1;
    @autoreleasepool {
        // PDF export requires async operation, simplified stub
        return -1;
    }
}

OXIDE_EXPORT long long webview_screenshot(const char* path) {
    if (!webview) return -1;
    @autoreleasepool {
        WKSnapshotConfiguration* config = [[WKSnapshotConfiguration alloc] init];
        __block BOOL done = NO;
        __block BOOL success = NO;

        [webview takeSnapshotWithConfiguration:config completionHandler:^(NSImage* image, NSError* error) {
            if (image && !error) {
                NSBitmapImageRep* rep = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
                NSData* pngData = [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
                success = [pngData writeToFile:[NSString stringWithUTF8String:path] atomically:YES];
            }
            done = YES;
        }];

        NSDate* timeout = [NSDate dateWithTimeIntervalSinceNow:10.0];
        while (!done && [[NSDate date] compare:timeout] == NSOrderedAscending) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeout];
        }

        return success ? 0 : -1;
    }
}

// Event callbacks (stubs - would need proper callback mechanism)
OXIDE_EXPORT void webview_on_navigation_start(void* callback) {}
OXIDE_EXPORT void webview_on_navigation_complete(void* callback) {}
OXIDE_EXPORT void webview_on_navigation_error(void* callback) {}
OXIDE_EXPORT void webview_on_title_change(void* callback) {}
OXIDE_EXPORT void webview_on_load_progress(void* callback) {}
OXIDE_EXPORT void webview_on_close_request(void* callback) {}
OXIDE_EXPORT void webview_on_new_window(void* callback) {}
OXIDE_EXPORT void webview_on_download(void* callback) {}
OXIDE_EXPORT void webview_on_console_message(void* callback) {}

/* =============================================================================
 * Linux Implementation using WebKitGTK
 * ============================================================================= */
#elif defined(__linux__)

#include <gtk/gtk.h>
#include <webkit2/webkit2.h>

static GtkWidget* window = NULL;
static WebKitWebView* webview = NULL;
static char* current_url = NULL;
static char* current_title = NULL;
static char* injected_js = NULL;
static char* eval_result = NULL;
static char* user_agent_result = NULL;
static double zoom_level = 1.0;

static void on_load_changed(WebKitWebView* wv, WebKitLoadEvent event, gpointer data) {
    if (event == WEBKIT_LOAD_FINISHED) {
        // Update current URL
        if (current_url) g_free(current_url);
        current_url = g_strdup(webkit_web_view_get_uri(wv));

        // Update current title
        if (current_title) g_free(current_title);
        current_title = g_strdup(webkit_web_view_get_title(wv) ?: "");

        // Execute injected JS if any
        if (injected_js) {
            webkit_web_view_run_javascript(wv, injected_js, NULL, NULL, NULL);
        }
    }
}

static gboolean on_delete_event(GtkWidget* widget, GdkEvent* event, gpointer data) {
    gtk_main_quit();
    return FALSE;
}

OXIDE_EXPORT long long webview_create(const char* title, long long width, long long height) {
    if (!gtk_init_check(NULL, NULL)) {
        return -1;
    }

    window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(window), title);
    gtk_window_set_default_size(GTK_WINDOW(window), width, height);
    gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);

    g_signal_connect(window, "delete-event", G_CALLBACK(on_delete_event), NULL);

    webview = WEBKIT_WEB_VIEW(webkit_web_view_new());
    g_signal_connect(webview, "load-changed", G_CALLBACK(on_load_changed), NULL);

    gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(webview));
    gtk_widget_show_all(window);

    return 0;
}

OXIDE_EXPORT long long webview_navigate(const char* url) {
    if (!webview) return -1;
    webkit_web_view_load_uri(webview, url);
    return 0;
}

OXIDE_EXPORT long long webview_load_html(const char* html) {
    if (!webview) return -1;
    webkit_web_view_load_html(webview, html, NULL);
    return 0;
}

OXIDE_EXPORT long long webview_load_html_base(const char* html, const char* baseUrl) {
    if (!webview) return -1;
    webkit_web_view_load_html(webview, html, baseUrl);
    return 0;
}

OXIDE_EXPORT void webview_run(void) {
    gtk_main();
}

OXIDE_EXPORT void webview_destroy(void) {
    if (window) {
        gtk_widget_destroy(window);
        window = NULL;
        webview = NULL;
    }
    if (current_url) {
        g_free(current_url);
        current_url = NULL;
    }
    if (current_title) {
        g_free(current_title);
        current_title = NULL;
    }
    if (injected_js) {
        g_free(injected_js);
        injected_js = NULL;
    }
}

OXIDE_EXPORT void webview_set_title(const char* title) {
    if (!window) return;
    gtk_window_set_title(GTK_WINDOW(window), title);
}

OXIDE_EXPORT void webview_set_size(long long width, long long height) {
    if (!window) return;
    gtk_window_resize(GTK_WINDOW(window), width, height);
}

OXIDE_EXPORT void webview_set_min_size(long long width, long long height) {
    if (!window) return;
    GdkGeometry hints;
    hints.min_width = width;
    hints.min_height = height;
    gtk_window_set_geometry_hints(GTK_WINDOW(window), NULL, &hints, GDK_HINT_MIN_SIZE);
}

OXIDE_EXPORT void webview_set_max_size(long long width, long long height) {
    if (!window) return;
    GdkGeometry hints;
    hints.max_width = width;
    hints.max_height = height;
    gtk_window_set_geometry_hints(GTK_WINDOW(window), NULL, &hints, GDK_HINT_MAX_SIZE);
}

OXIDE_EXPORT void webview_set_resizable(long long resizable) {
    if (!window) return;
    gtk_window_set_resizable(GTK_WINDOW(window), resizable ? TRUE : FALSE);
}

OXIDE_EXPORT void webview_set_visible(long long visible) {
    if (!window) return;
    if (visible) {
        gtk_widget_show(window);
    } else {
        gtk_widget_hide(window);
    }
}

OXIDE_EXPORT void webview_set_fullscreen(long long fullscreen) {
    if (!window) return;
    if (fullscreen) {
        gtk_window_fullscreen(GTK_WINDOW(window));
    } else {
        gtk_window_unfullscreen(GTK_WINDOW(window));
    }
}

OXIDE_EXPORT void webview_center(void) {
    if (!window) return;
    gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
}

OXIDE_EXPORT void webview_set_position(long long x, long long y) {
    if (!window) return;
    gtk_window_move(GTK_WINDOW(window), x, y);
}

OXIDE_EXPORT long long webview_get_position(void) {
    if (!window) return 0;
    gint x, y;
    gtk_window_get_position(GTK_WINDOW(window), &x, &y);
    return (long long)x;
}

OXIDE_EXPORT long long webview_get_size(void) {
    if (!window) return 0;
    gint w, h;
    gtk_window_get_size(GTK_WINDOW(window), &w, &h);
    return (long long)w;
}

OXIDE_EXPORT void webview_minimize(void) {
    if (!window) return;
    gtk_window_iconify(GTK_WINDOW(window));
}

OXIDE_EXPORT void webview_maximize(void) {
    if (!window) return;
    gtk_window_maximize(GTK_WINDOW(window));
}

OXIDE_EXPORT void webview_restore(void) {
    if (!window) return;
    gtk_window_unmaximize(GTK_WINDOW(window));
    gtk_window_deiconify(GTK_WINDOW(window));
}

OXIDE_EXPORT void webview_set_always_on_top(long long onTop) {
    if (!window) return;
    gtk_window_set_keep_above(GTK_WINDOW(window), onTop ? TRUE : FALSE);
}

OXIDE_EXPORT void webview_set_opacity(double opacity) {
    if (!window) return;
    gtk_widget_set_opacity(window, opacity);
}

OXIDE_EXPORT void webview_set_icon(const char* iconPath) {
    if (!window) return;
    gtk_window_set_icon_from_file(GTK_WINDOW(window), iconPath, NULL);
}

OXIDE_EXPORT long long webview_is_focused(void) {
    if (!window) return 0;
    return gtk_window_is_active(GTK_WINDOW(window)) ? 1 : 0;
}

OXIDE_EXPORT void webview_focus(void) {
    if (!window) return;
    gtk_window_present(GTK_WINDOW(window));
}

static void eval_callback(GObject* object, GAsyncResult* result, gpointer data) {
    WebKitJavascriptResult* js_result = webkit_web_view_run_javascript_finish(
        WEBKIT_WEB_VIEW(object), result, NULL);

    if (js_result) {
        JSCValue* value = webkit_javascript_result_get_js_value(js_result);
        if (jsc_value_is_string(value)) {
            if (eval_result) g_free(eval_result);
            eval_result = jsc_value_to_string(value);
        }
        webkit_javascript_result_unref(js_result);
    }

    *(gboolean*)data = TRUE;
}

OXIDE_EXPORT const char* webview_eval(const char* js) {
    if (!webview) return "";

    gboolean done = FALSE;
    webkit_web_view_run_javascript(webview, js, NULL, eval_callback, &done);

    // Wait for completion (simple busy wait with timeout)
    int timeout = 5000;
    while (!done && timeout > 0) {
        gtk_main_iteration_do(FALSE);
        g_usleep(1000);
        timeout--;
    }

    return eval_result ? eval_result : "";
}

OXIDE_EXPORT void webview_eval_async(const char* js) {
    if (!webview) return;
    webkit_web_view_run_javascript(webview, js, NULL, NULL, NULL);
}

OXIDE_EXPORT void webview_inject(const char* js) {
    if (injected_js) g_free(injected_js);
    injected_js = g_strdup(js);

    if (webview) {
        WebKitUserContentManager* manager = webkit_web_view_get_user_content_manager(webview);
        WebKitUserScript* script = webkit_user_script_new(
            js, WEBKIT_USER_CONTENT_INJECT_ALL_FRAMES,
            WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_END, NULL, NULL);
        webkit_user_content_manager_add_script(manager, script);
        webkit_user_script_unref(script);
    }
}

OXIDE_EXPORT void webview_bind(const char* name) {
    // Not fully implemented for Linux - would require WebKit message handlers
}

OXIDE_EXPORT void webview_unbind(const char* name) {
    if (!webview) return;
    char script[256];
    snprintf(script, sizeof(script), "delete window.%s;", name);
    webkit_web_view_run_javascript(webview, script, NULL, NULL, NULL);
}

OXIDE_EXPORT void webview_go_back(void) {
    if (!webview) return;
    if (webkit_web_view_can_go_back(webview)) {
        webkit_web_view_go_back(webview);
    }
}

OXIDE_EXPORT void webview_go_forward(void) {
    if (!webview) return;
    if (webkit_web_view_can_go_forward(webview)) {
        webkit_web_view_go_forward(webview);
    }
}

OXIDE_EXPORT void webview_reload(void) {
    if (!webview) return;
    webkit_web_view_reload(webview);
}

OXIDE_EXPORT void webview_reload_ignoring_cache(void) {
    if (!webview) return;
    webkit_web_view_reload_bypass_cache(webview);
}

OXIDE_EXPORT void webview_stop(void) {
    if (!webview) return;
    webkit_web_view_stop_loading(webview);
}

OXIDE_EXPORT const char* webview_get_url(void) {
    return current_url ? current_url : "";
}

OXIDE_EXPORT const char* webview_get_title(void) {
    return current_title ? current_title : "";
}

OXIDE_EXPORT long long webview_can_go_back(void) {
    if (!webview) return 0;
    return webkit_web_view_can_go_back(webview) ? 1 : 0;
}

OXIDE_EXPORT long long webview_can_go_forward(void) {
    if (!webview) return 0;
    return webkit_web_view_can_go_forward(webview) ? 1 : 0;
}

OXIDE_EXPORT long long webview_is_loading(void) {
    if (!webview) return 0;
    return webkit_web_view_is_loading(webview) ? 1 : 0;
}

OXIDE_EXPORT double webview_get_loading_progress(void) {
    if (!webview) return 0.0;
    return webkit_web_view_get_estimated_load_progress(webview);
}

OXIDE_EXPORT void webview_clear_history(void) {
    // WebKitGTK doesn't expose history clearing directly
}

OXIDE_EXPORT void webview_set_devtools(long long enabled) {
    if (!webview) return;
    WebKitSettings* settings = webkit_web_view_get_settings(webview);
    webkit_settings_set_enable_developer_extras(settings, enabled ? TRUE : FALSE);
}

OXIDE_EXPORT void webview_open_devtools(void) {
    if (!webview) return;
    WebKitWebInspector* inspector = webkit_web_view_get_inspector(webview);
    webkit_web_inspector_show(inspector);
}

OXIDE_EXPORT void webview_close_devtools(void) {
    if (!webview) return;
    WebKitWebInspector* inspector = webkit_web_view_get_inspector(webview);
    webkit_web_inspector_close(inspector);
}

OXIDE_EXPORT void webview_set_user_agent(const char* userAgent) {
    if (!webview) return;
    WebKitSettings* settings = webkit_web_view_get_settings(webview);
    webkit_settings_set_user_agent(settings, userAgent);
}

OXIDE_EXPORT const char* webview_get_user_agent(void) {
    if (!webview) return "";
    WebKitSettings* settings = webkit_web_view_get_settings(webview);
    if (user_agent_result) g_free(user_agent_result);
    user_agent_result = g_strdup(webkit_settings_get_user_agent(settings));
    return user_agent_result ? user_agent_result : "";
}

OXIDE_EXPORT void webview_set_background_color(long long r, long long g, long long b, long long a) {
    if (!webview) return;
    GdkRGBA color = { r/255.0, g/255.0, b/255.0, a/255.0 };
    webkit_web_view_set_background_color(webview, &color);
}

OXIDE_EXPORT void webview_set_javascript_enabled(long long enabled) {
    if (!webview) return;
    WebKitSettings* settings = webkit_web_view_get_settings(webview);
    webkit_settings_set_enable_javascript(settings, enabled ? TRUE : FALSE);
}

OXIDE_EXPORT void webview_set_local_storage_enabled(long long enabled) {
    if (!webview) return;
    WebKitSettings* settings = webkit_web_view_get_settings(webview);
    webkit_settings_set_enable_html5_local_storage(settings, enabled ? TRUE : FALSE);
}

OXIDE_EXPORT void webview_set_databases_enabled(long long enabled) {
    if (!webview) return;
    WebKitSettings* settings = webkit_web_view_get_settings(webview);
    webkit_settings_set_enable_html5_database(settings, enabled ? TRUE : FALSE);
}

OXIDE_EXPORT void webview_set_zoom(double zoom) {
    if (!webview) return;
    zoom_level = zoom;
    webkit_web_view_set_zoom_level(webview, zoom);
}

OXIDE_EXPORT double webview_get_zoom(void) {
    if (!webview) return 1.0;
    return webkit_web_view_get_zoom_level(webview);
}

OXIDE_EXPORT void webview_set_context_menu_enabled(long long enabled) {
    // Would need to connect to context-menu signal
}

OXIDE_EXPORT void webview_clear_cookies(void) {
    WebKitWebContext* context = webkit_web_context_get_default();
    WebKitCookieManager* manager = webkit_web_context_get_cookie_manager(context);
    webkit_cookie_manager_delete_all_cookies(manager);
}

OXIDE_EXPORT void webview_clear_local_storage(void) {
    WebKitWebContext* context = webkit_web_context_get_default();
    WebKitWebsiteDataManager* manager = webkit_web_context_get_website_data_manager(context);
    webkit_website_data_manager_clear(manager, WEBKIT_WEBSITE_DATA_LOCAL_STORAGE, 0, NULL, NULL, NULL);
}

OXIDE_EXPORT void webview_clear_cache(void) {
    WebKitWebContext* context = webkit_web_context_get_default();
    WebKitWebsiteDataManager* manager = webkit_web_context_get_website_data_manager(context);
    webkit_website_data_manager_clear(manager,
        WEBKIT_WEBSITE_DATA_DISK_CACHE | WEBKIT_WEBSITE_DATA_MEMORY_CACHE,
        0, NULL, NULL, NULL);
}

OXIDE_EXPORT void webview_clear_all_data(void) {
    WebKitWebContext* context = webkit_web_context_get_default();
    WebKitWebsiteDataManager* manager = webkit_web_context_get_website_data_manager(context);
    webkit_website_data_manager_clear(manager, WEBKIT_WEBSITE_DATA_ALL, 0, NULL, NULL, NULL);
}

OXIDE_EXPORT void webview_print(void) {
    if (!webview) return;
    WebKitPrintOperation* op = webkit_print_operation_new(webview);
    webkit_print_operation_run_dialog(op, GTK_WINDOW(window));
    g_object_unref(op);
}

OXIDE_EXPORT long long webview_save_pdf(const char* path) {
    // Would need async operation
    return -1;
}

OXIDE_EXPORT long long webview_screenshot(const char* path) {
    // Would need async snapshot operation
    return -1;
}

// Event callbacks (stubs)
OXIDE_EXPORT void webview_on_navigation_start(void* callback) {}
OXIDE_EXPORT void webview_on_navigation_complete(void* callback) {}
OXIDE_EXPORT void webview_on_navigation_error(void* callback) {}
OXIDE_EXPORT void webview_on_title_change(void* callback) {}
OXIDE_EXPORT void webview_on_load_progress(void* callback) {}
OXIDE_EXPORT void webview_on_close_request(void* callback) {}
OXIDE_EXPORT void webview_on_new_window(void* callback) {}
OXIDE_EXPORT void webview_on_download(void* callback) {}
OXIDE_EXPORT void webview_on_console_message(void* callback) {}

/* =============================================================================
 * Windows Implementation (Stub - requires WebView2)
 * ============================================================================= */
#elif defined(_WIN32)

// Windows implementation would use Microsoft WebView2
// This is a stub implementation - full implementation requires WebView2 SDK

#include <windows.h>

static HWND window = NULL;
static char* current_url = NULL;
static char* current_title = NULL;

OXIDE_EXPORT long long webview_create(const char* title, long long width, long long height) {
    // Would initialize WebView2 here
    // Requires: WebView2Loader.dll and WebView2 Runtime
    MessageBoxA(NULL, "WebView2 implementation required", "Oxide Webview", MB_OK);
    return -1;
}

OXIDE_EXPORT long long webview_navigate(const char* url) { return -1; }
OXIDE_EXPORT long long webview_load_html(const char* html) { return -1; }
OXIDE_EXPORT long long webview_load_html_base(const char* html, const char* baseUrl) { return -1; }
OXIDE_EXPORT void webview_run(void) {}
OXIDE_EXPORT void webview_destroy(void) {}
OXIDE_EXPORT void webview_set_title(const char* title) {}
OXIDE_EXPORT void webview_set_size(long long width, long long height) {}
OXIDE_EXPORT void webview_set_min_size(long long width, long long height) {}
OXIDE_EXPORT void webview_set_max_size(long long width, long long height) {}
OXIDE_EXPORT void webview_set_resizable(long long resizable) {}
OXIDE_EXPORT void webview_set_visible(long long visible) {}
OXIDE_EXPORT void webview_set_fullscreen(long long fullscreen) {}
OXIDE_EXPORT void webview_center(void) {}
OXIDE_EXPORT void webview_set_position(long long x, long long y) {}
OXIDE_EXPORT long long webview_get_position(void) { return 0; }
OXIDE_EXPORT long long webview_get_size(void) { return 0; }
OXIDE_EXPORT void webview_minimize(void) {}
OXIDE_EXPORT void webview_maximize(void) {}
OXIDE_EXPORT void webview_restore(void) {}
OXIDE_EXPORT void webview_set_always_on_top(long long onTop) {}
OXIDE_EXPORT void webview_set_opacity(double opacity) {}
OXIDE_EXPORT void webview_set_icon(const char* iconPath) {}
OXIDE_EXPORT long long webview_is_focused(void) { return 0; }
OXIDE_EXPORT void webview_focus(void) {}
OXIDE_EXPORT const char* webview_eval(const char* js) { return ""; }
OXIDE_EXPORT void webview_eval_async(const char* js) {}
OXIDE_EXPORT void webview_inject(const char* js) {}
OXIDE_EXPORT void webview_bind(const char* name) {}
OXIDE_EXPORT void webview_unbind(const char* name) {}
OXIDE_EXPORT void webview_go_back(void) {}
OXIDE_EXPORT void webview_go_forward(void) {}
OXIDE_EXPORT void webview_reload(void) {}
OXIDE_EXPORT void webview_reload_ignoring_cache(void) {}
OXIDE_EXPORT void webview_stop(void) {}
OXIDE_EXPORT const char* webview_get_url(void) { return ""; }
OXIDE_EXPORT const char* webview_get_title(void) { return ""; }
OXIDE_EXPORT long long webview_can_go_back(void) { return 0; }
OXIDE_EXPORT long long webview_can_go_forward(void) { return 0; }
OXIDE_EXPORT long long webview_is_loading(void) { return 0; }
OXIDE_EXPORT double webview_get_loading_progress(void) { return 0.0; }
OXIDE_EXPORT void webview_clear_history(void) {}
OXIDE_EXPORT void webview_set_devtools(long long enabled) {}
OXIDE_EXPORT void webview_open_devtools(void) {}
OXIDE_EXPORT void webview_close_devtools(void) {}
OXIDE_EXPORT void webview_set_user_agent(const char* userAgent) {}
OXIDE_EXPORT const char* webview_get_user_agent(void) { return ""; }
OXIDE_EXPORT void webview_set_background_color(long long r, long long g, long long b, long long a) {}
OXIDE_EXPORT void webview_set_javascript_enabled(long long enabled) {}
OXIDE_EXPORT void webview_set_local_storage_enabled(long long enabled) {}
OXIDE_EXPORT void webview_set_databases_enabled(long long enabled) {}
OXIDE_EXPORT void webview_set_zoom(double zoom) {}
OXIDE_EXPORT double webview_get_zoom(void) { return 1.0; }
OXIDE_EXPORT void webview_set_context_menu_enabled(long long enabled) {}
OXIDE_EXPORT void webview_clear_cookies(void) {}
OXIDE_EXPORT void webview_clear_local_storage(void) {}
OXIDE_EXPORT void webview_clear_cache(void) {}
OXIDE_EXPORT void webview_clear_all_data(void) {}
OXIDE_EXPORT void webview_print(void) {}
OXIDE_EXPORT long long webview_save_pdf(const char* path) { return -1; }
OXIDE_EXPORT long long webview_screenshot(const char* path) { return -1; }
OXIDE_EXPORT void webview_on_navigation_start(void* callback) {}
OXIDE_EXPORT void webview_on_navigation_complete(void* callback) {}
OXIDE_EXPORT void webview_on_navigation_error(void* callback) {}
OXIDE_EXPORT void webview_on_title_change(void* callback) {}
OXIDE_EXPORT void webview_on_load_progress(void* callback) {}
OXIDE_EXPORT void webview_on_close_request(void* callback) {}
OXIDE_EXPORT void webview_on_new_window(void* callback) {}
OXIDE_EXPORT void webview_on_download(void* callback) {}
OXIDE_EXPORT void webview_on_console_message(void* callback) {}

#endif

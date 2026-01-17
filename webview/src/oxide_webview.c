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

@interface WebviewDelegate : NSObject <WKNavigationDelegate, NSWindowDelegate>
@end

@implementation WebviewDelegate

- (void)webView:(WKWebView *)wv didFinishNavigation:(WKNavigation *)navigation {
    // Update current URL
    if (current_url) free(current_url);
    current_url = strdup([[wv.URL absoluteString] UTF8String]);

    // Update current title
    if (current_title) free(current_title);
    current_title = strdup([wv.title UTF8String] ?: "");

    // Execute injected JS if any
    if (injected_js) {
        [wv evaluateJavaScript:[NSString stringWithUTF8String:injected_js] completionHandler:nil];
    }
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

        WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
        config.preferences.javaScriptEnabled = YES;

        webview = [[WKWebView alloc] initWithFrame:frame configuration:config];
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
        NSURL* nsurl = [NSURL URLWithString:[NSString stringWithUTF8String:url]];
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

OXIDE_EXPORT void webview_run(void) {
    if (!app) return;
    @autoreleasepool {
        [app run];
    }
}

OXIDE_EXPORT void webview_destroy(void) {
    @autoreleasepool {
        if (webview) {
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

OXIDE_EXPORT void webview_inject(const char* js) {
    if (injected_js) free(injected_js);
    injected_js = strdup(js);
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

OXIDE_EXPORT void webview_stop(void) {
    if (!webview) return;
    @autoreleasepool {
        [webview stopLoading];
    }
}

OXIDE_EXPORT const char* webview_get_url(void) {
    return current_url ? current_url : "";
}

OXIDE_EXPORT const char* webview_get_title(void) {
    return current_title ? current_title : "";
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

OXIDE_EXPORT void webview_set_user_agent(const char* userAgent) {
    if (!webview) return;
    @autoreleasepool {
        webview.customUserAgent = [NSString stringWithUTF8String:userAgent];
    }
}

OXIDE_EXPORT void webview_set_background_color(long long r, long long g, long long b, long long a) {
    if (!webview) return;
    @autoreleasepool {
        if (a < 255) {
            // Make webview background transparent
            [webview setValue:@NO forKey:@"drawsBackground"];
        }
        NSColor* color = [NSColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/255.0];
        [window setBackgroundColor:color];
    }
}

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

OXIDE_EXPORT void webview_inject(const char* js) {
    if (injected_js) g_free(injected_js);
    injected_js = g_strdup(js);
}

OXIDE_EXPORT void webview_bind(const char* name) {
    // Not fully implemented for Linux - would require WebKit message handlers
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

OXIDE_EXPORT void webview_set_devtools(long long enabled) {
    if (!webview) return;
    WebKitSettings* settings = webkit_web_view_get_settings(webview);
    webkit_settings_set_enable_developer_extras(settings, enabled ? TRUE : FALSE);
}

OXIDE_EXPORT void webview_set_user_agent(const char* userAgent) {
    if (!webview) return;
    WebKitSettings* settings = webkit_web_view_get_settings(webview);
    webkit_settings_set_user_agent(settings, userAgent);
}

OXIDE_EXPORT void webview_set_background_color(long long r, long long g, long long b, long long a) {
    if (!webview) return;
    GdkRGBA color = { r/255.0, g/255.0, b/255.0, a/255.0 };
    webkit_web_view_set_background_color(webview, &color);
}

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
OXIDE_EXPORT void webview_run(void) {}
OXIDE_EXPORT void webview_destroy(void) {}
OXIDE_EXPORT void webview_set_title(const char* title) {}
OXIDE_EXPORT void webview_set_size(long long width, long long height) {}
OXIDE_EXPORT void webview_set_resizable(long long resizable) {}
OXIDE_EXPORT void webview_set_visible(long long visible) {}
OXIDE_EXPORT void webview_set_fullscreen(long long fullscreen) {}
OXIDE_EXPORT const char* webview_eval(const char* js) { return ""; }
OXIDE_EXPORT void webview_inject(const char* js) {}
OXIDE_EXPORT void webview_bind(const char* name) {}
OXIDE_EXPORT void webview_go_back(void) {}
OXIDE_EXPORT void webview_go_forward(void) {}
OXIDE_EXPORT void webview_reload(void) {}
OXIDE_EXPORT void webview_stop(void) {}
OXIDE_EXPORT const char* webview_get_url(void) { return ""; }
OXIDE_EXPORT const char* webview_get_title(void) { return ""; }
OXIDE_EXPORT void webview_set_devtools(long long enabled) {}
OXIDE_EXPORT void webview_set_user_agent(const char* userAgent) {}
OXIDE_EXPORT void webview_set_background_color(long long r, long long g, long long b, long long a) {}

#endif

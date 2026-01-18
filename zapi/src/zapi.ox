# =============================================================================
#  Zapi - Lightweight Web Framework for Oxide
#  Build APIs and web applications with simple, readable syntax.
#
#  Usage:
#    use zapi
#
#    app = new Zapp()
#    app.get("/", func(req, res)
#        res.text("Hello, World!")
#    endfunc)
#    app.run(3000)
# =============================================================================

# -----------------------------------------------------------------------------
# HTTP Status Codes
# -----------------------------------------------------------------------------

HTTP_OK = 200
HTTP_CREATED = 201
HTTP_ACCEPTED = 202
HTTP_NO_CONTENT = 204
HTTP_MOVED_PERMANENTLY = 301
HTTP_FOUND = 302
HTTP_NOT_MODIFIED = 304
HTTP_BAD_REQUEST = 400
HTTP_UNAUTHORIZED = 401
HTTP_FORBIDDEN = 403
HTTP_NOT_FOUND = 404
HTTP_METHOD_NOT_ALLOWED = 405
HTTP_CONFLICT = 409
HTTP_UNPROCESSABLE_ENTITY = 422
HTTP_TOO_MANY_REQUESTS = 429
HTTP_INTERNAL_SERVER_ERROR = 500
HTTP_NOT_IMPLEMENTED = 501
HTTP_BAD_GATEWAY = 502
HTTP_SERVICE_UNAVAILABLE = 503

# -----------------------------------------------------------------------------
# Content Types
# -----------------------------------------------------------------------------

CONTENT_TYPE_TEXT = "text/plain"
CONTENT_TYPE_HTML = "text/html"
CONTENT_TYPE_JSON = "application/json"
CONTENT_TYPE_XML = "application/xml"
CONTENT_TYPE_FORM = "application/x-www-form-urlencoded"

# -----------------------------------------------------------------------------
# Request Class
# -----------------------------------------------------------------------------

class Request
    func init()
        self.path = ""
        self.method = "GET"
        self.headers = {}
        self.query = {}
        self.params = {}
        self.body = None
        self.ip = ""
        self.protocol = "HTTP/1.1"
        self.host = ""
        self.cookies = {}
        self.rawBody = ""
    endfunc

    # Get a header value (case-insensitive)
    func header(name)
        # Check exact match first
        if self.headers[name] != None
            return self.headers[name]
        endif
        # Check lowercase
        lowerName = lower(name)
        for key in keys(self.headers)
            if lower(key) == lowerName
                return self.headers[key]
            endif
        endfor
        return None
    endfunc

    # Check if request accepts JSON
    func acceptsJson()
        accept = self.header("Accept")
        if accept == None
            return False
        endif
        return contains(accept, "application/json") or contains(accept, "*/*")
    endfunc

    # Check if request is AJAX
    func isAjax()
        xhr = self.header("X-Requested-With")
        return xhr == "XMLHttpRequest"
    endfunc

    # Get a cookie value
    func cookie(name)
        if self.cookies[name] != None
            return self.cookies[name]
        endif
        return None
    endfunc
endclass

# -----------------------------------------------------------------------------
# Response Class
# -----------------------------------------------------------------------------

class Response
    func init()
        self.statusCode = 200
        self.statusText = "OK"
        self.headers = {}
        self.body = ""
        self.sent = False
    endfunc

    # Set status code (chainable)
    func status(code)
        self.statusCode = code
        self.statusText = self._getStatusText(code)
        return self
    endfunc

    # Set a response header (chainable)
    func header(name, value)
        self.headers[name] = value
        return self
    endfunc

    # Send plain text response
    func text(content)
        self.headers["Content-Type"] = CONTENT_TYPE_TEXT
        self.body = str(content)
        self.sent = True
    endfunc

    # Send JSON response
    func json(data)
        self.headers["Content-Type"] = CONTENT_TYPE_JSON
        self.body = jsonEncode(data)
        self.sent = True
    endfunc

    # Send HTML response
    func html(content)
        self.headers["Content-Type"] = CONTENT_TYPE_HTML
        self.body = str(content)
        self.sent = True
    endfunc

    # Send redirect response
    func redirect(url, permanent)
        if permanent == None
            permanent = False
        endif
        if permanent
            self.statusCode = 301
        else
            self.statusCode = 302
        endif
        self.statusText = self._getStatusText(self.statusCode)
        self.headers["Location"] = url
        self.body = ""
        self.sent = True
    endfunc

    # Set a cookie
    func cookie(name, value, options)
        cookieStr = name + "=" + str(value)
        if options != None
            if options["maxAge"] != None
                cookieStr = cookieStr + "; Max-Age=" + str(options["maxAge"])
            endif
            if options["path"] != None
                cookieStr = cookieStr + "; Path=" + options["path"]
            else
                cookieStr = cookieStr + "; Path=/"
            endif
            if options["domain"] != None
                cookieStr = cookieStr + "; Domain=" + options["domain"]
            endif
            if options["secure"] == True
                cookieStr = cookieStr + "; Secure"
            endif
            if options["httpOnly"] == True
                cookieStr = cookieStr + "; HttpOnly"
            endif
            if options["sameSite"] != None
                cookieStr = cookieStr + "; SameSite=" + options["sameSite"]
            endif
        else
            cookieStr = cookieStr + "; Path=/"
        endif
        self.headers["Set-Cookie"] = cookieStr
        return self
    endfunc

    # Clear a cookie
    func clearCookie(name)
        self.headers["Set-Cookie"] = name + "=; Path=/; Max-Age=0"
        return self
    endfunc

    # Send file (for static file serving)
    func sendFile(filePath, contentType)
        content = readFile(filePath)
        if content == None
            self.status(404).text("File not found")
            return
        endif
        if contentType != None
            self.headers["Content-Type"] = contentType
        else
            self.headers["Content-Type"] = self._getMimeType(filePath)
        endif
        self.body = content
        self.sent = True
    endfunc

    # Get status text from code
    func _getStatusText(code)
        if code == 200
            return "OK"
        endif
        if code == 201
            return "Created"
        endif
        if code == 204
            return "No Content"
        endif
        if code == 301
            return "Moved Permanently"
        endif
        if code == 302
            return "Found"
        endif
        if code == 304
            return "Not Modified"
        endif
        if code == 400
            return "Bad Request"
        endif
        if code == 401
            return "Unauthorized"
        endif
        if code == 403
            return "Forbidden"
        endif
        if code == 404
            return "Not Found"
        endif
        if code == 405
            return "Method Not Allowed"
        endif
        if code == 500
            return "Internal Server Error"
        endif
        return "Unknown"
    endfunc

    # Get MIME type from file extension
    func _getMimeType(path)
        if endsWith(path, ".html") or endsWith(path, ".htm")
            return "text/html"
        endif
        if endsWith(path, ".css")
            return "text/css"
        endif
        if endsWith(path, ".js")
            return "application/javascript"
        endif
        if endsWith(path, ".json")
            return "application/json"
        endif
        if endsWith(path, ".png")
            return "image/png"
        endif
        if endsWith(path, ".jpg") or endsWith(path, ".jpeg")
            return "image/jpeg"
        endif
        if endsWith(path, ".gif")
            return "image/gif"
        endif
        if endsWith(path, ".svg")
            return "image/svg+xml"
        endif
        if endsWith(path, ".ico")
            return "image/x-icon"
        endif
        if endsWith(path, ".pdf")
            return "application/pdf"
        endif
        if endsWith(path, ".txt")
            return "text/plain"
        endif
        if endsWith(path, ".xml")
            return "application/xml"
        endif
        return "application/octet-stream"
    endfunc

    # Build HTTP response string
    func build()
        response = "HTTP/1.1 " + str(self.statusCode) + " " + self.statusText + "\r\n"
        for key in keys(self.headers)
            response = response + key + ": " + str(self.headers[key]) + "\r\n"
        endfor
        response = response + "Content-Length: " + str(len(self.body)) + "\r\n"
        response = response + "\r\n"
        response = response + self.body
        return response
    endfunc
endclass

# -----------------------------------------------------------------------------
# Route Class
# -----------------------------------------------------------------------------

class Route
    func init(method, path, handler)
        self.method = method
        self.path = path
        self.handler = handler
        self.paramNames = []
        self.pattern = self._buildPattern(path)
    endfunc

    # Build regex pattern from path with parameters
    func _buildPattern(path)
        pattern = path
        # Extract parameter names like :id, :userId
        parts = split(path, "/")
        for part in parts
            if startsWith(part, ":")
                paramName = slice(part, 1, len(part))
                append(self.paramNames, paramName)
                pattern = replace(pattern, part, "([^/]+)")
            endif
        endfor
        return "^" + pattern + "$"
    endfunc

    # Check if route matches the request
    func matches(method, path)
        if self.method != method and self.method != "ANY"
            return False
        endif
        # Simple path matching with parameters
        return self._matchPath(path)
    endfunc

    # Match path and extract parameters
    func _matchPath(requestPath)
        routeParts = split(self.path, "/")
        requestParts = split(requestPath, "/")

        if len(routeParts) != len(requestParts)
            return False
        endif

        for i in range(len(routeParts))
            routePart = routeParts[i]
            requestPart = requestParts[i]
            if startsWith(routePart, ":")
                # Parameter - always matches
                continue
            else
                if routePart != requestPart
                    return False
                endif
            endif
        endfor
        return True
    endfunc

    # Extract parameters from path
    func extractParams(requestPath)
        params = {}
        routeParts = split(self.path, "/")
        requestParts = split(requestPath, "/")

        for i in range(len(routeParts))
            routePart = routeParts[i]
            if startsWith(routePart, ":")
                paramName = slice(routePart, 1, len(routePart))
                params[paramName] = requestParts[i]
            endif
        endfor
        return params
    endfunc
endclass

# -----------------------------------------------------------------------------
# Route Group Class
# -----------------------------------------------------------------------------

class RouteGroup
    func init(app, prefix)
        self.app = app
        self.prefix = prefix
    endfunc

    func get(path, handler)
        self.app.get(self.prefix + path, handler)
        return self
    endfunc

    func post(path, handler)
        self.app.post(self.prefix + path, handler)
        return self
    endfunc

    func put(path, handler)
        self.app.put(self.prefix + path, handler)
        return self
    endfunc

    func delete(path, handler)
        self.app.delete(self.prefix + path, handler)
        return self
    endfunc

    func patch(path, handler)
        self.app.patch(self.prefix + path, handler)
        return self
    endfunc
endclass

# -----------------------------------------------------------------------------
# Zapp Class - Main Application
# -----------------------------------------------------------------------------

class Zapp
    func init()
        self.routes = []
        self.middlewares = []
        self.staticPaths = {}
        self.notFoundHandler = None
        self.errorHandler = None
        self.corsOptions = None
        self.port = 3000
        self.host = "127.0.0.1"
    endfunc

    # Register GET route
    func get(path, handler)
        route = new Route("GET", path, handler)
        append(self.routes, route)
        return self
    endfunc

    # Register POST route
    func post(path, handler)
        route = new Route("POST", path, handler)
        append(self.routes, route)
        return self
    endfunc

    # Register PUT route
    func put(path, handler)
        route = new Route("PUT", path, handler)
        append(self.routes, route)
        return self
    endfunc

    # Register DELETE route
    func delete(path, handler)
        route = new Route("DELETE", path, handler)
        append(self.routes, route)
        return self
    endfunc

    # Register PATCH route
    func patch(path, handler)
        route = new Route("PATCH", path, handler)
        append(self.routes, route)
        return self
    endfunc

    # Register route for any HTTP method
    func any(path, handler)
        route = new Route("ANY", path, handler)
        append(self.routes, route)
        return self
    endfunc

    # Add middleware
    func use(middleware)
        append(self.middlewares, middleware)
        return self
    endfunc

    # Serve static files
    func static(urlPath, dirPath)
        self.staticPaths[urlPath] = dirPath
        return self
    endfunc

    # Enable CORS
    func cors(options)
        if options == None
            options = {}
        endif
        if options["origin"] == None
            options["origin"] = "*"
        endif
        if options["methods"] == None
            options["methods"] = "GET, POST, PUT, DELETE, PATCH, OPTIONS"
        endif
        if options["headers"] == None
            options["headers"] = "Content-Type, Authorization"
        endif
        self.corsOptions = options

        # Add CORS middleware
        corsOpts = options
        self.use(func(req, res, next)
            res.header("Access-Control-Allow-Origin", corsOpts["origin"])
            res.header("Access-Control-Allow-Methods", corsOpts["methods"])
            res.header("Access-Control-Allow-Headers", corsOpts["headers"])
            if corsOpts["credentials"] == True
                res.header("Access-Control-Allow-Credentials", "true")
            endif
            # Handle preflight
            if req.method == "OPTIONS"
                res.status(204).text("")
                return
            endif
            next()
        endfunc)
        return self
    endfunc

    # Create route group
    func group(prefix)
        return new RouteGroup(self, prefix)
    endfunc

    # Set custom 404 handler
    func notFound(handler)
        self.notFoundHandler = handler
        return self
    endfunc

    # Set custom error handler
    func onError(handler)
        self.errorHandler = handler
        return self
    endfunc

    # Parse query string
    func _parseQuery(queryString)
        query = {}
        if queryString == "" or queryString == None
            return query
        endif
        pairs = split(queryString, "&")
        for pair in pairs
            if contains(pair, "=")
                kv = split(pair, "=")
                key = urlDecode(kv[0])
                value = urlDecode(kv[1])
                query[key] = value
            else
                query[urlDecode(pair)] = ""
            endif
        endfor
        return query
    endfunc

    # Parse cookies from header
    func _parseCookies(cookieHeader)
        cookies = {}
        if cookieHeader == "" or cookieHeader == None
            return cookies
        endif
        pairs = split(cookieHeader, "; ")
        for pair in pairs
            if contains(pair, "=")
                kv = split(pair, "=")
                cookies[kv[0]] = kv[1]
            endif
        endfor
        return cookies
    endfunc

    # Parse HTTP request
    func _parseRequest(rawRequest)
        req = new Request()

        lines = split(rawRequest, "\r\n")
        if len(lines) == 0
            return req
        endif

        # Parse request line
        requestLine = lines[0]
        parts = split(requestLine, " ")
        if len(parts) >= 2
            req.method = parts[0]
            fullPath = parts[1]

            # Separate path and query string
            if contains(fullPath, "?")
                pathParts = split(fullPath, "?")
                req.path = pathParts[0]
                req.query = self._parseQuery(pathParts[1])
            else
                req.path = fullPath
            endif
        endif
        if len(parts) >= 3
            req.protocol = parts[2]
        endif

        # Parse headers
        i = 1
        while i < len(lines) and lines[i] != ""
            line = lines[i]
            if contains(line, ": ")
                headerParts = split(line, ": ")
                headerName = headerParts[0]
                headerValue = slice(line, len(headerName) + 2, len(line))
                req.headers[headerName] = headerValue
            endif
            i = i + 1
        endwhile

        # Parse cookies
        cookieHeader = req.header("Cookie")
        if cookieHeader != None
            req.cookies = self._parseCookies(cookieHeader)
        endif

        # Get host
        req.host = req.header("Host")
        if req.host == None
            req.host = ""
        endif

        # Parse body (after empty line)
        if i < len(lines)
            bodyStart = i + 1
            if bodyStart < len(lines)
                bodyLines = []
                for j in range(bodyStart, len(lines))
                    append(bodyLines, lines[j])
                endfor
                req.rawBody = join(bodyLines, "\r\n")

                # Try to parse as JSON
                contentType = req.header("Content-Type")
                if contentType != None and contains(contentType, "application/json")
                    req.body = jsonDecode(req.rawBody)
                else
                    req.body = req.rawBody
                endif
            endif
        endif

        return req
    endfunc

    # Check for static file match
    func _checkStatic(path)
        for urlPath in keys(self.staticPaths)
            if startsWith(path, urlPath)
                dirPath = self.staticPaths[urlPath]
                filePath = dirPath + slice(path, len(urlPath), len(path))
                if fileExists(filePath)
                    return filePath
                endif
            endif
        endfor
        return None
    endfunc

    # Handle a request
    func _handleRequest(rawRequest, clientIp)
        req = self._parseRequest(rawRequest)
        req.ip = clientIp
        res = new Response()

        # Check for static file
        staticFile = self._checkStatic(req.path)
        if staticFile != None
            res.sendFile(staticFile, None)
            return res.build()
        endif

        # Run middlewares
        middlewareIndex = 0
        middlewares = self.middlewares

        func runNextMiddleware()
            if middlewareIndex < len(middlewares)
                middleware = middlewares[middlewareIndex]
                middlewareIndex = middlewareIndex + 1
                middleware(req, res, runNextMiddleware)
            endif
        endfunc

        if len(self.middlewares) > 0
            runNextMiddleware()
            if res.sent
                return res.build()
            endif
        endif

        # Find matching route
        matchedRoute = None
        for route in self.routes
            if route.matches(req.method, req.path)
                matchedRoute = route
                break
            endif
        endfor

        if matchedRoute != None
            # Extract parameters
            req.params = matchedRoute.extractParams(req.path)

            # Call handler
            try
                matchedRoute.handler(req, res)
            catch err
                if self.errorHandler != None
                    self.errorHandler(err, req, res)
                else
                    res.status(500).json({"error": "Internal Server Error"})
                endif
            endtry
        else
            # No route found
            if self.notFoundHandler != None
                self.notFoundHandler(req, res)
            else
                res.status(404).json({"error": "Not Found", "path": req.path})
            endif
        endif

        return res.build()
    endfunc

    # Start the server
    func run(port, host)
        if port != None
            self.port = port
        endif
        if host != None
            self.host = host
        endif

        print "Zapi server starting..."
        print "Listening on http://" + self.host + ":" + str(self.port)

        # Create TCP server
        server = tcpListen(self.host, self.port)
        if server == None
            print "Error: Failed to start server on port " + str(self.port)
            return
        endif

        print "Server running! Press Ctrl+C to stop."

        while True
            # Accept client connection
            client = tcpAccept(server)
            if client == None
                continue
            endif

            # Read request
            rawRequest = tcpRead(client, 65536)
            if rawRequest == None or rawRequest == ""
                tcpClose(client)
                continue
            endif

            # Get client IP
            clientIp = tcpGetPeerAddress(client)
            if clientIp == None
                clientIp = "unknown"
            endif

            # Handle request and send response
            response = self._handleRequest(rawRequest, clientIp)
            tcpWrite(client, response)
            tcpClose(client)
        endwhile
    endfunc

    # Start server with default host
    func listen(port)
        self.run(port, "127.0.0.1")
    endfunc
endclass

# -----------------------------------------------------------------------------
# ZapiUtils Class - Utility functions as static methods
# -----------------------------------------------------------------------------

class ZapiUtils
    # URL decode a string
    static func urlDecode(str)
        result = ""
        i = 0
        while i < len(str)
            c = str[i]
            if c == "+"
                result = result + " "
            elif c == "%" and i + 2 < len(str)
                hex = slice(str, i + 1, i + 3)
                charCode = parseInt(hex, 16)
                result = result + chr(charCode)
                i = i + 2
            else
                result = result + c
            endif
            i = i + 1
        endwhile
        return result
    endfunc

    # URL encode a string
    static func urlEncode(str)
        result = ""
        for c in str
            code = ord(c)
            if (code >= 65 and code <= 90) or (code >= 97 and code <= 122) or (code >= 48 and code <= 57) or c == "-" or c == "_" or c == "." or c == "~"
                result = result + c
            elif c == " "
                result = result + "+"
            else
                result = result + "%" + ZapiUtils.toHex(code)
            endif
        endfor
        return result
    endfunc

    # JSON encode helper (if not built-in)
    static func jsonEncode(data)
        if type(data) == "string"
            return "\"" + ZapiUtils.escapeJsonString(data) + "\""
        endif
        if type(data) == "number"
            return str(data)
        endif
        if type(data) == "boolean"
            if data
                return "true"
            else
                return "false"
            endif
        endif
        if data == None
            return "null"
        endif
        if type(data) == "list"
            items = []
            for item in data
                append(items, ZapiUtils.jsonEncode(item))
            endfor
            return "[" + join(items, ", ") + "]"
        endif
        if type(data) == "dict"
            pairs = []
            for key in keys(data)
                pair = "\"" + ZapiUtils.escapeJsonString(str(key)) + "\": " + ZapiUtils.jsonEncode(data[key])
                append(pairs, pair)
            endfor
            return "{" + join(pairs, ", ") + "}"
        endif
        return "null"
    endfunc

    # Escape JSON string
    static func escapeJsonString(str)
        result = ""
        for c in str
            if c == "\""
                result = result + "\\\""
            elif c == "\\"
                result = result + "\\\\"
            elif c == "\n"
                result = result + "\\n"
            elif c == "\r"
                result = result + "\\r"
            elif c == "\t"
                result = result + "\\t"
            else
                result = result + c
            endif
        endfor
        return result
    endfunc

    # JSON decode helper (if not built-in)
    static func jsonDecode(str)
        # Use built-in JSON parsing if available
        return parseJson(str)
    endfunc

    # Check if string starts with prefix
    static func startsWith(str, prefix)
        if len(str) < len(prefix)
            return False
        endif
        return slice(str, 0, len(prefix)) == prefix
    endfunc

    # Check if string ends with suffix
    static func endsWith(str, suffix)
        if len(str) < len(suffix)
            return False
        endif
        return slice(str, len(str) - len(suffix), len(str)) == suffix
    endfunc

    # Check if string contains substring
    static func contains(str, substr)
        return indexOf(str, substr) >= 0
    endfunc

    # Convert to hex string
    static func toHex(num)
        hexChars = "0123456789ABCDEF"
        if num < 16
            return "0" + hexChars[num]
        endif
        return hexChars[num / 16] + hexChars[num % 16]
    endfunc
endclass

# -----------------------------------------------------------------------------
# Module Functions (Convenience wrappers that delegate to class static methods)
# -----------------------------------------------------------------------------

# URL decode a string
func urlDecode(str)
    return ZapiUtils.urlDecode(str)
endfunc

# URL encode a string
func urlEncode(str)
    return ZapiUtils.urlEncode(str)
endfunc

# JSON encode helper (if not built-in)
func jsonEncode(data)
    return ZapiUtils.jsonEncode(data)
endfunc

# Escape JSON string
func escapeJsonString(str)
    return ZapiUtils.escapeJsonString(str)
endfunc

# JSON decode helper (if not built-in)
func jsonDecode(str)
    return ZapiUtils.jsonDecode(str)
endfunc

# Check if string starts with prefix
func startsWith(str, prefix)
    return ZapiUtils.startsWith(str, prefix)
endfunc

# Check if string ends with suffix
func endsWith(str, suffix)
    return ZapiUtils.endsWith(str, suffix)
endfunc

# Check if string contains substring
func contains(str, substr)
    return ZapiUtils.contains(str, substr)
endfunc

# Convert to hex string
func toHex(num)
    return ZapiUtils.toHex(num)
endfunc

print "Zapi module loaded (v0.0.2)"

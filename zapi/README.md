# Zapi - Web Framework for Oxide

A lightweight, easy-to-read web framework for building APIs and web applications in Oxide. Inspired by Flask but with simpler, more readable syntax.

## Overview

Zapi provides a clean, intuitive API for building web servers without the complexity of decorators. Routes are registered using simple method calls, making code easy to read and maintain.

## Installation

```bash
oxide install zapi
```

## Quick Start

```oxide
use zapi

# Create a new app
app = new App()

# Define routes using simple method calls
app.get("/", func(req, res)
    res.text("Hello, World!")
endfunc)

app.get("/users/:id", func(req, res)
    userId = req.params["id"]
    res.json({"id": userId, "name": "John Doe"})
endfunc)

# Start the server
app.run(3000)
```

## Usage Examples

### Basic Routes

```oxide
use zapi

app = new App()

# GET request
app.get("/hello", func(req, res)
    res.text("Hello!")
endfunc)

# POST request
app.post("/users", func(req, res)
    data = req.body
    res.json({"created": True, "user": data})
endfunc)

# PUT request
app.put("/users/:id", func(req, res)
    res.json({"updated": True})
endfunc)

# DELETE request
app.delete("/users/:id", func(req, res)
    res.json({"deleted": True})
endfunc)

app.run(8080)
```

### Route Parameters

```oxide
use zapi

app = new App()

# Single parameter
app.get("/users/:id", func(req, res)
    res.text("User ID: " + req.params["id"])
endfunc)

# Multiple parameters
app.get("/posts/:postId/comments/:commentId", func(req, res)
    postId = req.params["postId"]
    commentId = req.params["commentId"]
    res.json({"post": postId, "comment": commentId})
endfunc)

app.run(3000)
```

### Query Strings

```oxide
use zapi

app = new App()

# Access query parameters
# URL: /search?q=oxide&limit=10
app.get("/search", func(req, res)
    query = req.query["q"]
    limit = req.query["limit"]
    res.json({"query": query, "limit": limit})
endfunc)

app.run(3000)
```

### JSON Handling

```oxide
use zapi

app = new App()

# Receive JSON body
app.post("/api/data", func(req, res)
    data = req.body  # Automatically parsed JSON
    print "Received: " + str(data)

    res.json({
        "success": True,
        "received": data
    })
endfunc)

app.run(3000)
```

### HTML Responses

```oxide
use zapi

app = new App()

app.get("/", func(req, res)
    html = "
    <!DOCTYPE html>
    <html>
    <head><title>Zapi App</title></head>
    <body>
        <h1>Welcome to Zapi!</h1>
        <p>A simple web framework for Oxide.</p>
    </body>
    </html>
    "
    res.html(html)
endfunc)

app.run(3000)
```

### Redirects

```oxide
use zapi

app = new App()

app.get("/old-page", func(req, res)
    res.redirect("/new-page")
endfunc)

app.get("/new-page", func(req, res)
    res.text("This is the new page!")
endfunc)

app.run(3000)
```

### Status Codes

```oxide
use zapi

app = new App()

app.get("/not-found", func(req, res)
    res.status(404).text("Page not found")
endfunc)

app.post("/created", func(req, res)
    res.status(201).json({"id": 123})
endfunc)

app.get("/error", func(req, res)
    res.status(500).json({"error": "Internal server error"})
endfunc)

app.run(3000)
```

### Middleware

```oxide
use zapi

app = new App()

# Global middleware - runs for all routes
app.use(func(req, res, next)
    print "Request: " + req.method + " " + req.path
    next()  # Continue to next middleware/route
endfunc)

# Authentication middleware
app.use(func(req, res, next)
    token = req.headers["Authorization"]
    if token == None
        res.status(401).json({"error": "Unauthorized"})
        return
    endif
    next()
endfunc)

app.get("/protected", func(req, res)
    res.json({"data": "secret"})
endfunc)

app.run(3000)
```

### Static Files

```oxide
use zapi

app = new App()

# Serve static files from a directory
app.static("/public", "./static")

# Now files in ./static are accessible at /public/*
# e.g., ./static/style.css -> /public/style.css

app.run(3000)
```

### CORS Support

```oxide
use zapi

app = new App()

# Enable CORS for all routes
app.cors({
    "origin": "*",
    "methods": "GET, POST, PUT, DELETE",
    "headers": "Content-Type, Authorization"
})

app.get("/api/data", func(req, res)
    res.json({"data": "accessible from any origin"})
endfunc)

app.run(3000)
```

### Error Handling

```oxide
use zapi

app = new App()

# Custom 404 handler
app.notFound(func(req, res)
    res.status(404).html("<h1>404 - Page Not Found</h1>")
endfunc)

# Custom error handler
app.onError(func(err, req, res)
    print "Error: " + str(err)
    res.status(500).json({"error": "Something went wrong"})
endfunc)

app.run(3000)
```

### Grouping Routes

```oxide
use zapi

app = new App()

# Create a route group with prefix
api = app.group("/api/v1")

api.get("/users", func(req, res)
    res.json({"users": []})
endfunc)

api.get("/posts", func(req, res)
    res.json({"posts": []})
endfunc)

# Routes are: /api/v1/users, /api/v1/posts

app.run(3000)
```

## API Reference

### App Class

| Method | Description |
|--------|-------------|
| `new App()` | Create a new application instance |
| `app.get(path, handler)` | Register GET route |
| `app.post(path, handler)` | Register POST route |
| `app.put(path, handler)` | Register PUT route |
| `app.delete(path, handler)` | Register DELETE route |
| `app.patch(path, handler)` | Register PATCH route |
| `app.use(middleware)` | Add global middleware |
| `app.static(urlPath, dirPath)` | Serve static files |
| `app.cors(options)` | Enable CORS |
| `app.group(prefix)` | Create route group |
| `app.notFound(handler)` | Custom 404 handler |
| `app.onError(handler)` | Custom error handler |
| `app.run(port)` | Start the server |

### Request Object

| Property | Description |
|----------|-------------|
| `req.path` | Request path (e.g., "/users/123") |
| `req.method` | HTTP method (GET, POST, etc.) |
| `req.headers` | Request headers dictionary |
| `req.query` | Query string parameters |
| `req.params` | Route parameters (e.g., :id) |
| `req.body` | Parsed request body |
| `req.ip` | Client IP address |

### Response Object

| Method | Description |
|--------|-------------|
| `res.text(content)` | Send plain text response |
| `res.json(data)` | Send JSON response |
| `res.html(content)` | Send HTML response |
| `res.redirect(url)` | Redirect to URL |
| `res.status(code)` | Set status code (chainable) |
| `res.header(name, value)` | Set response header |
| `res.cookie(name, value, opts)` | Set cookie |

## Comparison with Flask

| Flask | Zapi |
|-------|------|
| `@app.route("/", methods=["GET"])` | `app.get("/", handler)` |
| `@app.route("/users/<id>")` | `app.get("/users/:id", handler)` |
| `request.args.get("q")` | `req.query["q"]` |
| `request.json` | `req.body` |
| `jsonify(data)` | `res.json(data)` |
| `return render_template()` | `res.html(content)` |

## Why Zapi?

- **No decorators**: Routes are registered with simple method calls
- **Readable syntax**: Code reads like plain English
- **Familiar patterns**: Similar concepts to Flask/Express
- **Lightweight**: Minimal overhead, fast startup
- **Built for Oxide**: Designed specifically for the Oxide ecosystem

## License

MIT License

## Author

Oxide Team

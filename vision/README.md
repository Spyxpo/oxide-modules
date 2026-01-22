# Vision Module for Oxide

A comprehensive computer vision module for Oxide, providing webcam capture, image/video processing, and visual analysis capabilities similar to OpenCV.

## Overview

The Vision module enables Oxide programs to:

- **Capture from Webcam**: Access and control webcam devices for real-time video capture
- **Read/Write Images**: Load and save images in various formats (JPEG, PNG, BMP, TIFF, etc.)
- **Process Videos**: Read and write video files with codec support
- **Apply Filters**: Blur, sharpen, edge detection, morphological operations
- **Transform Images**: Resize, rotate, flip, crop, and perspective transformations
- **Draw Graphics**: Lines, rectangles, circles, text, and polygons
- **Detect Features**: Contours, corners, edges, and basic motion detection
- **Color Operations**: Color space conversions, histogram operations

## Installation

```bash
oxide install vision
```

## Requirements

### macOS
- macOS 10.13 or later
- OpenCV 4.x (`brew install opencv`)
- Xcode Command Line Tools

### Linux
- OpenCV 4.x (`sudo apt install libopencv-dev`)
- V4L2 (usually pre-installed)

### Windows
- Windows 10 or later
- OpenCV 4.x (download from opencv.org)
- Visual Studio Build Tools

## Quick Start

### Capture from Webcam

```oxide
use vision

# Open the default camera (device 0)
cam = Camera.open(0)

if cam != None
    # Capture a single frame
    frame = cam.read()

    if frame != None
        # Save the captured frame
        frame.save("snapshot.jpg")
        print "Captured image:", frame.width, "x", frame.height
    endif

    # Release the camera
    cam.release()
endif
```

### Read and Process an Image

```oxide
use vision

# Read an image file
img = Image.read("photo.jpg")

if img != None
    # Convert to grayscale
    gray = img.toGrayscale()

    # Apply Gaussian blur
    blurred = gray.gaussianBlur(5, 1.5)

    # Detect edges using Canny
    edges = blurred.canny(50, 150)

    # Save the result
    edges.save("edges.jpg")
endif
```

### Video Processing

```oxide
use vision

# Open a video file
video = VideoCapture.open("input.mp4")

if video != None
    print "Video:", video.width, "x", video.height, "@", video.fps, "fps"
    print "Total frames:", video.frameCount

    # Create output video writer
    writer = VideoWriter.create("output.avi", "MJPG", video.fps, video.width, video.height)

    # Process each frame
    while True
        frame = video.read()
        if frame == None
            break
        endif

        # Apply some processing
        processed = frame.toGrayscale().canny(100, 200)

        # Convert back to 3 channels for output
        # (simplified - in practice use proper conversion)
        writer.write(processed)
    endwhile

    video.release()
    writer.release()
endif
```

### Drawing on Images

```oxide
use vision

# Create a blank image
img = Image.zeros(640, 480, 3)

# Draw shapes
red = Color.red()
green = Color.green()
blue = Color.blue()

# Draw a rectangle
img.drawRectangle(50, 50, 200, 150, red, 2, None)

# Draw a filled circle
img.drawCircle(Point.create(320, 240), 50, green, -1, None)

# Draw text
img.drawText("Hello Oxide!", Point.create(100, 400), blue, None, 1.5, 2, None)

# Save the result
img.save("drawing.png")
```

### Real-time Video Processing

```oxide
use vision

# Open webcam
cam = Camera.open(0)
cam.setResolution(1280, 720)
cam.setFps(30)

# Create motion detector
motion = MotionDetector.create()
motion.setThreshold(25)
motion.setMinArea(1000)

while True
    frame = cam.read()
    if frame == None
        continue
    endif

    # Detect motion
    motions = motion.detect(frame)

    # Draw rectangles around motion areas
    for m in motions
        rect = Rect.create(m["x"], m["y"], m["width"], m["height"])
        frame.drawRect(rect, Color.green(), 2, None)
    endfor

    # Display or save frame (simplified)
    if len(motions) > 0
        print "Motion detected!"
    endif
endwhile

cam.release()
```

## Usage Examples

### Color Space Conversion

```oxide
use vision

img = Image.read("photo.jpg")

# Convert to different color spaces
gray = img.toGrayscale()
hsv = img.toHsv()
lab = img.toLab()
rgb = img.toRgb()

# Using color codes directly
yuv = img.convertColor(82)  # BGR2YUV
```

### Image Filtering

```oxide
use vision

img = Image.read("noisy.jpg")

# Various blur methods
box_blur = img.blur(5)
gaussian = img.gaussianBlur(5, 1.0)
median = img.medianBlur(5)
bilateral = img.bilateralFilter(9, 75, 75)

# Edge detection
edges_canny = img.canny(100, 200)
edges_sobel = img.sobel(1, 0, 3)
edges_laplacian = img.laplacian(3)
```

### Morphological Operations

```oxide
use vision

# Read binary image
binary = Image.read("binary.png")

# Basic operations
dilated = binary.dilate(3, 1)
eroded = binary.erode(3, 1)

# Advanced operations
opened = binary.open(5, 1)      # Remove small objects
closed = binary.close(5, 1)     # Fill small holes
gradient = binary.gradient(3, 1) # Outline extraction
```

### Thresholding

```oxide
use vision

img = Image.read("document.jpg")
gray = img.toGrayscale()

# Simple threshold
binary = gray.threshold(127, 255, THRESH_BINARY)

# Otsu's automatic threshold
otsu = gray.threshold(0, 255, THRESH_BINARY + THRESH_OTSU)

# Adaptive threshold
adaptive = gray.adaptiveThreshold(255, 0, THRESH_BINARY, 11, 2)
```

### Geometric Transformations

```oxide
use vision

img = Image.read("photo.jpg")

# Resize
resized = img.resize(800, 600, INTER_LINEAR)
scaled = img.resizeBy(0.5, None)  # Scale to 50%

# Rotate
rotated90 = img.rotate90()
rotated180 = img.rotate180()
rotated = img.rotate(45)  # Arbitrary angle

# Flip
h_flip = img.flipHorizontal()
v_flip = img.flipVertical()
both = img.flipBoth()

# Crop
region = img.cropRegion(100, 100, 300, 200)
rect = Rect.create(100, 100, 300, 200)
cropped = img.crop(rect)
```

### Working with ROIs (Regions of Interest)

```oxide
use vision

img = Image.read("scene.jpg")

# Define region
roi = Rect.create(100, 100, 200, 150)

# Check if point is in region
point = Point.create(150, 125)
if roi.contains(point)
    print "Point is inside ROI"
endif

# Extract and process region
region = img.crop(roi)
processed = region.gaussianBlur(5, None).canny(50, 150)
```

### Histogram Operations

```oxide
use vision

img = Image.read("dark_photo.jpg")

# Calculate histogram
gray = img.toGrayscale()
hist = gray.calcHist(256)

# Equalize histogram for better contrast
equalized = gray.equalizeHist()
equalized.save("enhanced.jpg")
```

### Contour Detection

```oxide
use vision

img = Image.read("shapes.jpg")
gray = img.toGrayscale()
binary = gray.threshold(127, 255, THRESH_BINARY)

# Find contours
contours = binary.findContours(None, None)

# Draw contours on original image
for contour in contours
    print "Contour area:", contour["area"]
endfor
```

### Color Tracking

```oxide
use vision

cam = Camera.open(0)
tracker = ColorTracker.create()
tracker.setBlueRange()  # Track blue objects

while True
    frame = cam.read()
    if frame == None
        continue
    endif

    # Track blue objects
    objects = tracker.track(frame)

    # Draw tracking results
    for obj in objects
        rect = Rect.create(obj["x"], obj["y"], obj["width"], obj["height"])
        frame.drawRect(rect, Color.cyan(), 2, None)
    endfor
endwhile

cam.release()
```

### Image Arithmetic

```oxide
use vision

img1 = Image.read("image1.jpg")
img2 = Image.read("image2.jpg")

# Blend two images
blended = img1.blend(img2, 0.5)

# Add/subtract
brightened = img1.add(50)
darkened = img1.subtract(50)

# Multiply (contrast)
contrasted = img1.multiply(1.5)

# Invert
inverted = img1.invert()
```

### Channel Operations

```oxide
use vision

img = Image.read("color.jpg")

# Split into channels
channels = img.split()
b_channel = channels[0]
g_channel = channels[1]
r_channel = channels[2]

# Process individual channels
r_enhanced = r_channel.multiply(1.2)

# Merge back
result = Image.merge([b_channel, g_channel, r_enhanced])
```

## API Reference

### Image Class - Static Methods

| Method | Description |
|--------|-------------|
| `Image.create(width, height, channels, fill)` | Create image with fill value |
| `Image.zeros(width, height, channels)` | Create black image |
| `Image.ones(width, height, channels)` | Create image filled with ones |
| `Image.read(path)` | Read image from file |
| `Image.readGrayscale(path)` | Read as grayscale |
| `Image.readColor(path)` | Read as color (BGR) |
| `Image.decode(buffer, flags)` | Decode from memory buffer |
| `Image.merge(channels)` | Merge channels into single image |

### Image Class - Instance Methods

| Method | Description |
|--------|-------------|
| `save(path)` | Save image to file |
| `saveWithQuality(path, quality)` | Save with JPEG quality |
| `clone()` | Create a copy |
| `size()` | Get Size object |
| `shape()` | Get [height, width, channels] |
| `empty()` | Check if empty |
| `getPixel(x, y)` | Get pixel value |
| `setPixel(x, y, value)` | Set pixel value |

### Image Class - Color Conversion

| Method | Description |
|--------|-------------|
| `toGrayscale()` | Convert to grayscale |
| `toRgb()` | Convert BGR to RGB |
| `toBgr()` | Convert RGB to BGR |
| `toHsv()` | Convert to HSV |
| `toHls()` | Convert to HLS |
| `toLab()` | Convert to LAB |
| `convertColor(code)` | Convert using OpenCV code |

### Image Class - Geometric Transforms

| Method | Description |
|--------|-------------|
| `resize(width, height, interpolation)` | Resize image |
| `resizeBy(scale, interpolation)` | Scale image |
| `rotate(angle)` | Rotate by angle |
| `rotate90()` / `rotate180()` / `rotate270()` | Rotate by fixed angles |
| `flip(code)` | Flip image |
| `flipHorizontal()` / `flipVertical()` | Flip shortcuts |
| `crop(rect)` | Crop to rectangle |
| `cropRegion(x, y, w, h)` | Crop to region |

### Image Class - Filters

| Method | Description |
|--------|-------------|
| `blur(ksize)` | Box blur |
| `gaussianBlur(ksize, sigma)` | Gaussian blur |
| `medianBlur(ksize)` | Median blur |
| `bilateralFilter(d, sigmaColor, sigmaSpace)` | Bilateral filter |
| `canny(threshold1, threshold2)` | Canny edge detection |
| `sobel(dx, dy, ksize)` | Sobel derivatives |
| `laplacian(ksize)` | Laplacian |

### Image Class - Morphology

| Method | Description |
|--------|-------------|
| `dilate(ksize, iterations)` | Dilation |
| `erode(ksize, iterations)` | Erosion |
| `open(ksize, iterations)` | Opening |
| `close(ksize, iterations)` | Closing |
| `gradient(ksize, iterations)` | Morphological gradient |
| `tophat(ksize, iterations)` | Top hat |
| `blackhat(ksize, iterations)` | Black hat |

### Image Class - Thresholding

| Method | Description |
|--------|-------------|
| `threshold(thresh, maxval, type)` | Simple threshold |
| `adaptiveThreshold(maxval, method, type, blockSize, c)` | Adaptive threshold |

### Image Class - Drawing

| Method | Description |
|--------|-------------|
| `drawLine(p1, p2, color, thickness, lineType)` | Draw line |
| `drawRect(rect, color, thickness, lineType)` | Draw rectangle |
| `drawRectangle(x1, y1, x2, y2, color, thickness, lineType)` | Draw rectangle by coords |
| `drawCircle(center, radius, color, thickness, lineType)` | Draw circle |
| `drawEllipse(center, axes, angle, start, end, color, thickness, lineType)` | Draw ellipse |
| `drawText(text, position, color, font, scale, thickness, lineType)` | Draw text |
| `drawPolylines(points, isClosed, color, thickness, lineType)` | Draw polylines |
| `fillPoly(points, color)` | Fill polygon |

### Camera Class

| Method | Description |
|--------|-------------|
| `Camera.open(deviceId)` | Open camera by ID |
| `Camera.openUrl(url)` | Open stream URL |
| `isOpened()` | Check if opened |
| `read()` | Read frame |
| `grab()` | Grab frame (no decode) |
| `retrieve()` | Retrieve grabbed frame |
| `release()` | Release camera |
| `setResolution(width, height)` | Set resolution |
| `setFps(fps)` | Set frame rate |
| `setBrightness(value)` | Set brightness |
| `setContrast(value)` | Set contrast |
| `setSaturation(value)` | Set saturation |
| `setExposure(value)` | Set exposure |

### VideoCapture Class

| Method | Description |
|--------|-------------|
| `VideoCapture.open(path)` | Open video file |
| `isOpened()` | Check if opened |
| `read()` | Read next frame |
| `seek(frameNumber)` | Seek to frame |
| `seekMs(milliseconds)` | Seek to time |
| `getDuration()` | Get duration in seconds |
| `release()` | Release resources |

### VideoWriter Class

| Method | Description |
|--------|-------------|
| `VideoWriter.create(path, fourcc, fps, width, height)` | Create video writer |
| `VideoWriter.createMp4(path, fps, width, height)` | Create MP4 writer |
| `VideoWriter.createAvi(path, fps, width, height)` | Create AVI writer |
| `isOpened()` | Check if opened |
| `write(image)` | Write frame |
| `release()` | Release resources |

### Helper Classes

| Class | Description |
|-------|-------------|
| `Color` | RGB color with predefined colors |
| `Point` | 2D point with x, y coordinates |
| `Rect` | Rectangle with x, y, width, height |
| `Size` | Dimensions with width, height |

### Detection Classes

| Class | Description |
|-------|-------------|
| `MotionDetector` | Detect motion between frames |
| `ColorTracker` | Track objects by color |
| `FaceDetector` | Detect faces (requires cascade file) |
| `QRCodeReader` | Read QR codes (placeholder) |
| `TextReader` | OCR text reading (placeholder) |

### Constants

```oxide
# Color spaces
COLOR_BGR, COLOR_RGB, COLOR_GRAY, COLOR_HSV, COLOR_HLS, COLOR_LAB

# Interpolation
INTER_NEAREST, INTER_LINEAR, INTER_CUBIC, INTER_AREA, INTER_LANCZOS4

# Threshold types
THRESH_BINARY, THRESH_BINARY_INV, THRESH_TRUNC, THRESH_TOZERO, THRESH_OTSU

# Morphology
MORPH_ERODE, MORPH_DILATE, MORPH_OPEN, MORPH_CLOSE, MORPH_GRADIENT

# Line types
LINE_4, LINE_8, LINE_AA

# Font faces
FONT_HERSHEY_SIMPLEX, FONT_HERSHEY_PLAIN, FONT_HERSHEY_COMPLEX

# Video codecs
FOURCC_MJPG, FOURCC_XVID, FOURCC_H264, FOURCC_MP4V
```

## Building the Native Library

### macOS

```bash
# Install OpenCV
brew install opencv pkg-config

# Build the library
cd oxide-modules/vision
clang++ -shared -fPIC -std=c++11 -o liboxide_vision.dylib src/oxide_vision.c \
    $(pkg-config --cflags --libs opencv4) \
    -framework AVFoundation -framework CoreVideo -framework CoreMedia
```

### Linux

```bash
# Install OpenCV
sudo apt install libopencv-dev pkg-config

# Build the library
cd oxide-modules/vision
g++ -shared -fPIC -std=c++11 -o liboxide_vision.so src/oxide_vision.c \
    $(pkg-config --cflags --libs opencv4) -lv4l2
```

### Windows

```batch
REM Set OpenCV path
set OPENCV_DIR=C:\opencv\build

REM Build the library
cl /LD /EHsc /Fe:oxide_vision.dll src/oxide_vision.c ^
    /I"%OPENCV_DIR%\include" ^
    /link /LIBPATH:"%OPENCV_DIR%\x64\vc16\lib" opencv_world460.lib
```

## Troubleshooting

### Camera not found
- Ensure your camera is connected and recognized by the OS
- Try different device IDs (0, 1, 2, etc.)
- Check camera permissions in system settings

### Image read fails
- Verify the file path is correct
- Check file format is supported (JPEG, PNG, BMP, TIFF, WebP)
- Ensure file is not corrupted

### Video codec issues
- Install codec packs if needed
- Try different FOURCC codes
- Use MJPG for maximum compatibility

### Build errors
- Ensure OpenCV 4.x is installed
- Check pkg-config can find opencv4
- Verify compiler supports C++11

## License

MIT License

## Author

Oxide Team

# Changelog

All notable changes to the Vision module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2025-01-22

### Added

#### Core Classes
- `Image` class for image representation and manipulation
  - Static factory methods: `create()`, `zeros()`, `ones()`, `read()`, `readGrayscale()`, `readColor()`, `readUnchanged()`, `decode()`, `merge()`
  - I/O methods: `save()`, `saveWithQuality()`, `encode()`, `clone()`
  - Property methods: `size()`, `shape()`, `empty()`, `getPixel()`, `setPixel()`

- `Camera` class for webcam capture
  - Static methods: `open()`, `openUrl()`, `openStream()`
  - Capture methods: `read()`, `grab()`, `retrieve()`, `release()`, `isOpened()`
  - Configuration: `setResolution()`, `setFps()`, `setBrightness()`, `setContrast()`, `setSaturation()`, `setExposure()`, `setAutoFocus()`, `setFocus()`

- `VideoCapture` class for video file reading
  - Static methods: `open()`
  - Playback methods: `read()`, `grab()`, `retrieve()`, `seek()`, `seekMs()`, `getDuration()`, `release()`

- `VideoWriter` class for video file writing
  - Static methods: `create()`, `createMp4()`, `createAvi()`
  - Write methods: `write()`, `release()`, `isOpened()`

- Helper classes:
  - `Color` - RGB/RGBA color representation with predefined colors
  - `Point` - 2D point with arithmetic operations
  - `Rect` - Rectangle with intersection/union operations
  - `Size` - Dimension representation

#### Image Processing
- Color space conversions: `toGrayscale()`, `toRgb()`, `toBgr()`, `toHsv()`, `toHls()`, `toLab()`, `convertColor()`

- Geometric transformations:
  - `resize()`, `resizeBy()` - Image scaling
  - `rotate()`, `rotate90()`, `rotate180()`, `rotate270()` - Rotation
  - `flip()`, `flipHorizontal()`, `flipVertical()`, `flipBoth()` - Flipping
  - `crop()`, `cropRegion()` - Cropping
  - `warpAffine()`, `warpPerspective()` - Affine and perspective transforms

- Filtering:
  - `blur()` - Box blur
  - `gaussianBlur()` - Gaussian smoothing
  - `medianBlur()` - Median filtering
  - `bilateralFilter()` - Edge-preserving smoothing

- Edge detection:
  - `canny()` - Canny edge detector
  - `sobel()` - Sobel derivatives
  - `laplacian()` - Laplacian operator
  - `detectEdges()` - Automatic edge detection

- Morphological operations:
  - `dilate()`, `erode()` - Basic operations
  - `open()`, `close()` - Opening and closing
  - `gradient()`, `tophat()`, `blackhat()` - Advanced operations
  - `morphologyEx()` - General morphology

- Thresholding:
  - `threshold()` - Simple thresholding with Otsu support
  - `adaptiveThreshold()` - Adaptive thresholding

- Histogram operations:
  - `calcHist()` - Calculate histogram
  - `equalizeHist()` - Histogram equalization

#### Drawing Functions
- `drawLine()` - Draw lines between points
- `drawRect()`, `drawRectangle()` - Draw rectangles
- `drawCircle()` - Draw circles
- `drawEllipse()` - Draw ellipses
- `drawPolylines()` - Draw connected lines
- `drawText()` - Render text
- `fillPoly()` - Fill polygons

#### Image Arithmetic
- `add()` - Add images or scalar
- `subtract()` - Subtract images or scalar
- `multiply()` - Multiply by scalar
- `blend()` - Alpha blending
- `invert()` - Invert colors

#### Channel Operations
- `split()` - Split into separate channels
- `merge()` - Merge channels into single image

#### Feature Detection
- `findContours()` - Detect contours in binary images
- `cornerHarris()` - Harris corner detection
- `goodFeaturesToTrack()` - Shi-Tomasi corner detection

#### Detection Classes
- `MotionDetector` - Frame-to-frame motion detection
  - Methods: `detect()`, `setThreshold()`, `setMinArea()`, `reset()`

- `ColorTracker` - Color-based object tracking
  - Methods: `track()`, `setRange()`, `setRedRange()`, `setGreenRange()`, `setBlueRange()`, `setYellowRange()`

- `FaceDetector` - Face detection placeholder
  - Methods: `detect()` (requires cascade file)

- `QRCodeReader` - QR code detection placeholder
  - Methods: `detect()`, `decode()`, `detectAndDecode()`

- `TextReader` - OCR placeholder
  - Methods: `read()`, `readLines()`

#### Constants
- Color space constants: `COLOR_BGR`, `COLOR_RGB`, `COLOR_GRAY`, `COLOR_HSV`, `COLOR_HLS`, `COLOR_LAB`, `COLOR_YUV`, `COLOR_BGRA`, `COLOR_RGBA`
- Interpolation methods: `INTER_NEAREST`, `INTER_LINEAR`, `INTER_CUBIC`, `INTER_AREA`, `INTER_LANCZOS4`
- Border types: `BORDER_CONSTANT`, `BORDER_REPLICATE`, `BORDER_REFLECT`, `BORDER_WRAP`, `BORDER_REFLECT_101`
- Threshold types: `THRESH_BINARY`, `THRESH_BINARY_INV`, `THRESH_TRUNC`, `THRESH_TOZERO`, `THRESH_TOZERO_INV`, `THRESH_OTSU`, `THRESH_TRIANGLE`
- Morphology operations: `MORPH_ERODE`, `MORPH_DILATE`, `MORPH_OPEN`, `MORPH_CLOSE`, `MORPH_GRADIENT`, `MORPH_TOPHAT`, `MORPH_BLACKHAT`
- Morphology shapes: `MORPH_RECT`, `MORPH_CROSS`, `MORPH_ELLIPSE`
- Line types: `LINE_4`, `LINE_8`, `LINE_AA`
- Font faces: `FONT_HERSHEY_SIMPLEX`, `FONT_HERSHEY_PLAIN`, `FONT_HERSHEY_DUPLEX`, `FONT_HERSHEY_COMPLEX`, `FONT_HERSHEY_TRIPLEX`, `FONT_HERSHEY_SCRIPT_SIMPLEX`, `FONT_HERSHEY_SCRIPT_COMPLEX`
- Video codecs: `FOURCC_MJPG`, `FOURCC_XVID`, `FOURCC_H264`, `FOURCC_MP4V`, `FOURCC_AVC1`

#### Module-Level Functions
- `imread()`, `imreadGray()`, `imwrite()` - Image I/O shortcuts
- `imdecode()`, `imencode()` - Buffer I/O
- `cvtColor()`, `resize()`, `blur()`, `gaussianBlur()`, `canny()` - Processing shortcuts
- `threshold()`, `dilate()`, `erode()` - Morphology shortcuts
- `getRotationMatrix2D()`, `getPerspectiveTransform()` - Transform utilities
- `listCameras()`, `getVersion()` - System utilities

#### Native Library
- Full OpenCV 4.x integration via FFI
- Cross-platform support (macOS, Linux, Windows)
- Camera capture using platform-specific APIs
- Image codecs for JPEG, PNG, BMP, TIFF, WebP
- Video codecs via OpenCV VideoCapture/VideoWriter

#### Platform Support
- macOS 10.13+ with AVFoundation
- Linux with V4L2
- Windows 10+ with DirectShow

### Notes
- This is the initial release of the Vision module
- Some detection features (Face, QR, OCR) are placeholders for future implementation
- GUI window display requires future integration with display systems

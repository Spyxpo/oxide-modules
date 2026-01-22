# =============================================================================
# Vision Module for Oxide
# =============================================================================
# A comprehensive computer vision module providing webcam capture, image/video
# processing, and visual analysis capabilities similar to OpenCV.
#
# Features:
#   - Webcam capture and streaming
#   - Image reading, writing, and manipulation
#   - Video file reading and writing
#   - Color space conversions
#   - Image filters and transformations
#   - Basic object detection
#   - Drawing primitives
#
# Usage:
#   use vision
#
#   # Capture from webcam
#   cam = Camera.open(0)
#   frame = cam.read()
#   cam.release()
#
#   # Read and process image
#   img = Image.read("photo.jpg")
#   gray = img.toGrayscale()
#   gray.save("photo_gray.jpg")
#
# Author: Oxide Team
# License: MIT
# =============================================================================

# Link the native library (platform-specific path resolved at runtime)
link "./modules/vision/liboxide_vision.dylib"

# =============================================================================
# Constants
# =============================================================================

# Color space constants
COLOR_BGR = 0
COLOR_RGB = 1
COLOR_GRAY = 2
COLOR_HSV = 3
COLOR_HLS = 4
COLOR_LAB = 5
COLOR_YUV = 6
COLOR_BGRA = 7
COLOR_RGBA = 8

# Interpolation methods
INTER_NEAREST = 0
INTER_LINEAR = 1
INTER_CUBIC = 2
INTER_AREA = 3
INTER_LANCZOS4 = 4

# Border types
BORDER_CONSTANT = 0
BORDER_REPLICATE = 1
BORDER_REFLECT = 2
BORDER_WRAP = 3
BORDER_REFLECT_101 = 4

# Threshold types
THRESH_BINARY = 0
THRESH_BINARY_INV = 1
THRESH_TRUNC = 2
THRESH_TOZERO = 3
THRESH_TOZERO_INV = 4
THRESH_OTSU = 8
THRESH_TRIANGLE = 16

# Morphology operations
MORPH_ERODE = 0
MORPH_DILATE = 1
MORPH_OPEN = 2
MORPH_CLOSE = 3
MORPH_GRADIENT = 4
MORPH_TOPHAT = 5
MORPH_BLACKHAT = 6

# Morphology shapes
MORPH_RECT = 0
MORPH_CROSS = 1
MORPH_ELLIPSE = 2

# Line types for drawing
LINE_4 = 4
LINE_8 = 8
LINE_AA = 16

# Font faces
FONT_HERSHEY_SIMPLEX = 0
FONT_HERSHEY_PLAIN = 1
FONT_HERSHEY_DUPLEX = 2
FONT_HERSHEY_COMPLEX = 3
FONT_HERSHEY_TRIPLEX = 4
FONT_HERSHEY_SCRIPT_SIMPLEX = 5
FONT_HERSHEY_SCRIPT_COMPLEX = 6

# Video codec constants
FOURCC_MJPG = "MJPG"
FOURCC_XVID = "XVID"
FOURCC_H264 = "H264"
FOURCC_MP4V = "MP4V"
FOURCC_AVC1 = "AVC1"

# =============================================================================
# Native Function Declarations (FFI)
# =============================================================================

# Camera/Webcam functions
native func _camera_open(device_id) from "vision_camera_open"
native func _camera_open_url(url) from "vision_camera_open_url"
native func _camera_read(handle) from "vision_camera_read"
native func _camera_release(handle) from "vision_camera_release"
native func _camera_is_opened(handle) from "vision_camera_is_opened"
native func _camera_set_property(handle, prop_id, value) from "vision_camera_set_property"
native func _camera_get_property(handle, prop_id) from "vision_camera_get_property"
native func _camera_grab(handle) from "vision_camera_grab"
native func _camera_retrieve(handle) from "vision_camera_retrieve"

# Image I/O functions
native func _image_read(path) from "vision_image_read"
native func _image_read_flags(path, flags) from "vision_image_read_flags"
native func _image_write(path, data, width, height, channels) from "vision_image_write"
native func _image_write_params(path, data, width, height, channels, params) from "vision_image_write_params"
native func _image_decode(buffer, flags) from "vision_image_decode"
native func _image_encode(ext, data, width, height, channels) from "vision_image_encode"

# Video I/O functions
native func _video_open(path) from "vision_video_open"
native func _video_create(path, fourcc, fps, width, height) from "vision_video_create"
native func _video_read(handle) from "vision_video_read"
native func _video_write(handle, data, width, height, channels) from "vision_video_write"
native func _video_release(handle) from "vision_video_release"
native func _video_get_property(handle, prop_id) from "vision_video_get_property"
native func _video_set_property(handle, prop_id, value) from "vision_video_set_property"
native func _video_grab(handle) from "vision_video_grab"
native func _video_retrieve(handle) from "vision_video_retrieve"

# Image processing functions
native func _cvt_color(data, width, height, channels, code) from "vision_cvt_color"
native func _resize(data, width, height, channels, new_width, new_height, interpolation) from "vision_resize"
native func _rotate(data, width, height, channels, angle) from "vision_rotate"
native func _flip(data, width, height, channels, flip_code) from "vision_flip"
native func _crop(data, width, height, channels, x, y, w, h) from "vision_crop"
native func _blur(data, width, height, channels, ksize) from "vision_blur"
native func _gaussian_blur(data, width, height, channels, ksize, sigma) from "vision_gaussian_blur"
native func _median_blur(data, width, height, channels, ksize) from "vision_median_blur"
native func _bilateral_filter(data, width, height, channels, d, sigma_color, sigma_space) from "vision_bilateral_filter"
native func _canny(data, width, height, threshold1, threshold2) from "vision_canny"
native func _sobel(data, width, height, channels, dx, dy, ksize) from "vision_sobel"
native func _laplacian(data, width, height, channels, ksize) from "vision_laplacian"
native func _threshold(data, width, height, thresh, maxval, type) from "vision_threshold"
native func _adaptive_threshold(data, width, height, maxval, method, type, block_size, c) from "vision_adaptive_threshold"
native func _dilate(data, width, height, channels, ksize, iterations) from "vision_dilate"
native func _erode(data, width, height, channels, ksize, iterations) from "vision_erode"
native func _morphology_ex(data, width, height, channels, op, ksize, iterations) from "vision_morphology_ex"

# Drawing functions
native func _draw_line(data, width, height, channels, x1, y1, x2, y2, r, g, b, thickness, line_type) from "vision_draw_line"
native func _draw_rectangle(data, width, height, channels, x1, y1, x2, y2, r, g, b, thickness, line_type) from "vision_draw_rectangle"
native func _draw_circle(data, width, height, channels, cx, cy, radius, r, g, b, thickness, line_type) from "vision_draw_circle"
native func _draw_ellipse(data, width, height, channels, cx, cy, ax, ay, angle, start, end, r, g, b, thickness, line_type) from "vision_draw_ellipse"
native func _draw_polylines(data, width, height, channels, points, is_closed, r, g, b, thickness, line_type) from "vision_draw_polylines"
native func _draw_text(data, width, height, channels, text, x, y, font, scale, r, g, b, thickness, line_type) from "vision_draw_text"
native func _fill_poly(data, width, height, channels, points, r, g, b) from "vision_fill_poly"

# Feature detection functions
native func _find_contours(data, width, height, mode, method) from "vision_find_contours"
native func _detect_edges(data, width, height, channels) from "vision_detect_edges"
native func _corner_harris(data, width, height, block_size, ksize, k) from "vision_corner_harris"
native func _good_features_to_track(data, width, height, max_corners, quality, min_dist) from "vision_good_features_to_track"

# Histogram functions
native func _calc_hist(data, width, height, channels, bins) from "vision_calc_hist"
native func _equalize_hist(data, width, height) from "vision_equalize_hist"

# Transform functions
native func _warp_affine(data, width, height, channels, matrix, new_width, new_height) from "vision_warp_affine"
native func _warp_perspective(data, width, height, channels, matrix, new_width, new_height) from "vision_warp_perspective"
native func _get_rotation_matrix_2d(cx, cy, angle, scale) from "vision_get_rotation_matrix_2d"
native func _get_perspective_transform(src_points, dst_points) from "vision_get_perspective_transform"

# Utility functions
native func _get_version() from "vision_get_version"
native func _list_cameras() from "vision_list_cameras"

# =============================================================================
# Color Class
# =============================================================================

class Color
    func init(r, g, b, a)
        if a == None
            a = 255
        endif
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    endfunc

    static func create(r, g, b, a)
        return new Color(r, g, b, a)
    endfunc

    static func fromHex(hex)
        # Remove # if present
        if hex[0] == "#"
            hex = hex[1:]
        endif
        r = parseInt(hex[0:2], 16)
        g = parseInt(hex[2:4], 16)
        b = parseInt(hex[4:6], 16)
        a = 255
        if len(hex) == 8
            a = parseInt(hex[6:8], 16)
        endif
        return new Color(r, g, b, a)
    endfunc

    func toHex()
        return "#" + _padHex(self.r) + _padHex(self.g) + _padHex(self.b)
    endfunc

    func toList()
        return [self.r, self.g, self.b, self.a]
    endfunc

    func toBgr()
        return [self.b, self.g, self.r]
    endfunc

    # Predefined colors
    static func black()
        return new Color(0, 0, 0, 255)
    endfunc

    static func white()
        return new Color(255, 255, 255, 255)
    endfunc

    static func red()
        return new Color(255, 0, 0, 255)
    endfunc

    static func green()
        return new Color(0, 255, 0, 255)
    endfunc

    static func blue()
        return new Color(0, 0, 255, 255)
    endfunc

    static func yellow()
        return new Color(255, 255, 0, 255)
    endfunc

    static func cyan()
        return new Color(0, 255, 255, 255)
    endfunc

    static func magenta()
        return new Color(255, 0, 255, 255)
    endfunc

    static func orange()
        return new Color(255, 165, 0, 255)
    endfunc

    static func purple()
        return new Color(128, 0, 128, 255)
    endfunc
endclass

# =============================================================================
# Point Class
# =============================================================================

class Point
    func init(x, y)
        self.x = x
        self.y = y
    endfunc

    static func create(x, y)
        return new Point(x, y)
    endfunc

    func toList()
        return [self.x, self.y]
    endfunc

    func distance(other)
        dx = self.x - other.x
        dy = self.y - other.y
        return sqrt(dx * dx + dy * dy)
    endfunc

    func add(other)
        return new Point(self.x + other.x, self.y + other.y)
    endfunc

    func subtract(other)
        return new Point(self.x - other.x, self.y - other.y)
    endfunc

    func multiply(scalar)
        return new Point(self.x * scalar, self.y * scalar)
    endfunc
endclass

# =============================================================================
# Rect Class
# =============================================================================

class Rect
    func init(x, y, width, height)
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    endfunc

    static func create(x, y, width, height)
        return new Rect(x, y, width, height)
    endfunc

    static func fromPoints(p1, p2)
        x = min(p1.x, p2.x)
        y = min(p1.y, p2.y)
        w = abs(p2.x - p1.x)
        h = abs(p2.y - p1.y)
        return new Rect(x, y, w, h)
    endfunc

    func area()
        return self.width * self.height
    endfunc

    func center()
        return new Point(self.x + self.width / 2, self.y + self.height / 2)
    endfunc

    func topLeft()
        return new Point(self.x, self.y)
    endfunc

    func bottomRight()
        return new Point(self.x + self.width, self.y + self.height)
    endfunc

    func contains(point)
        return point.x >= self.x and point.x < self.x + self.width and point.y >= self.y and point.y < self.y + self.height
    endfunc

    func intersects(other)
        return not (self.x + self.width <= other.x or other.x + other.width <= self.x or self.y + self.height <= other.y or other.y + other.height <= self.y)
    endfunc

    func intersection(other)
        x = max(self.x, other.x)
        y = max(self.y, other.y)
        w = min(self.x + self.width, other.x + other.width) - x
        h = min(self.y + self.height, other.y + other.height) - y
        if w <= 0 or h <= 0
            return None
        endif
        return new Rect(x, y, w, h)
    endfunc

    func union(other)
        x = min(self.x, other.x)
        y = min(self.y, other.y)
        w = max(self.x + self.width, other.x + other.width) - x
        h = max(self.y + self.height, other.y + other.height) - y
        return new Rect(x, y, w, h)
    endfunc

    func toList()
        return [self.x, self.y, self.width, self.height]
    endfunc
endclass

# =============================================================================
# Size Class
# =============================================================================

class Size
    func init(width, height)
        self.width = width
        self.height = height
    endfunc

    static func create(width, height)
        return new Size(width, height)
    endfunc

    func area()
        return self.width * self.height
    endfunc

    func aspectRatio()
        return self.width / self.height
    endfunc

    func toList()
        return [self.width, self.height]
    endfunc
endclass

# =============================================================================
# Image Class
# =============================================================================

class Image
    func init(data, width, height, channels)
        self.data = data
        self.width = width
        self.height = height
        self.channels = channels
    endfunc

    # Static factory methods
    static func create(width, height, channels, fill_value)
        if fill_value == None
            fill_value = 0
        endif
        size = width * height * channels
        data = []
        for i = 0 to size - 1
            append(data, fill_value)
        endfor
        return new Image(data, width, height, channels)
    endfunc

    static func zeros(width, height, channels)
        return Image.create(width, height, channels, 0)
    endfunc

    static func ones(width, height, channels)
        return Image.create(width, height, channels, 1)
    endfunc

    static func read(path)
        result = _image_read(path)
        if result == None
            return None
        endif
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    static func readFlags(path, flags)
        result = _image_read_flags(path, flags)
        if result == None
            return None
        endif
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    static func readGrayscale(path)
        return Image.readFlags(path, 0)
    endfunc

    static func readColor(path)
        return Image.readFlags(path, 1)
    endfunc

    static func readUnchanged(path)
        return Image.readFlags(path, -1)
    endfunc

    static func decode(buffer, flags)
        if flags == None
            flags = 1
        endif
        result = _image_decode(buffer, flags)
        if result == None
            return None
        endif
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    # Instance methods
    func save(path)
        return _image_write(path, self.data, self.width, self.height, self.channels)
    endfunc

    func saveWithQuality(path, quality)
        params = [1, quality]  # 1 = JPEG quality flag
        return _image_write_params(path, self.data, self.width, self.height, self.channels, params)
    endfunc

    func encode(ext)
        return _image_encode(ext, self.data, self.width, self.height, self.channels)
    endfunc

    func clone()
        new_data = []
        for val in self.data
            append(new_data, val)
        endfor
        return new Image(new_data, self.width, self.height, self.channels)
    endfunc

    func size()
        return new Size(self.width, self.height)
    endfunc

    func shape()
        return [self.height, self.width, self.channels]
    endfunc

    func empty()
        return self.data == None or len(self.data) == 0
    endfunc

    func getPixel(x, y)
        if x < 0 or x >= self.width or y < 0 or y >= self.height
            return None
        endif
        idx = (y * self.width + x) * self.channels
        if self.channels == 1
            return self.data[idx]
        endif
        pixel = []
        for i = 0 to self.channels - 1
            append(pixel, self.data[idx + i])
        endfor
        return pixel
    endfunc

    func setPixel(x, y, value)
        if x < 0 or x >= self.width or y < 0 or y >= self.height
            return False
        endif
        idx = (y * self.width + x) * self.channels
        if self.channels == 1
            self.data[idx] = value
        else
            for i = 0 to self.channels - 1
                self.data[idx + i] = value[i]
            endfor
        endif
        return True
    endfunc

    # Color conversion
    func toGrayscale()
        if self.channels == 1
            return self.clone()
        endif
        result = _cvt_color(self.data, self.width, self.height, self.channels, 6)  # BGR2GRAY
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func toRgb()
        if self.channels == 3
            result = _cvt_color(self.data, self.width, self.height, self.channels, 4)  # BGR2RGB
            return new Image(result["data"], result["width"], result["height"], result["channels"])
        endif
        return self.clone()
    endfunc

    func toBgr()
        if self.channels == 3
            result = _cvt_color(self.data, self.width, self.height, self.channels, 4)  # RGB2BGR
            return new Image(result["data"], result["width"], result["height"], result["channels"])
        endif
        return self.clone()
    endfunc

    func toHsv()
        result = _cvt_color(self.data, self.width, self.height, self.channels, 40)  # BGR2HSV
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func toHls()
        result = _cvt_color(self.data, self.width, self.height, self.channels, 52)  # BGR2HLS
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func toLab()
        result = _cvt_color(self.data, self.width, self.height, self.channels, 44)  # BGR2LAB
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func convertColor(code)
        result = _cvt_color(self.data, self.width, self.height, self.channels, code)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    # Geometric transformations
    func resize(new_width, new_height, interpolation)
        if interpolation == None
            interpolation = INTER_LINEAR
        endif
        result = _resize(self.data, self.width, self.height, self.channels, new_width, new_height, interpolation)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func resizeBy(scale, interpolation)
        new_width = int(self.width * scale)
        new_height = int(self.height * scale)
        return self.resize(new_width, new_height, interpolation)
    endfunc

    func rotate(angle)
        result = _rotate(self.data, self.width, self.height, self.channels, angle)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func rotate90()
        return self.rotate(90)
    endfunc

    func rotate180()
        return self.rotate(180)
    endfunc

    func rotate270()
        return self.rotate(270)
    endfunc

    func flip(flip_code)
        # flip_code: 0 = vertical, 1 = horizontal, -1 = both
        result = _flip(self.data, self.width, self.height, self.channels, flip_code)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func flipHorizontal()
        return self.flip(1)
    endfunc

    func flipVertical()
        return self.flip(0)
    endfunc

    func flipBoth()
        return self.flip(-1)
    endfunc

    func crop(rect)
        result = _crop(self.data, self.width, self.height, self.channels, rect.x, rect.y, rect.width, rect.height)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func cropRegion(x, y, w, h)
        return self.crop(new Rect(x, y, w, h))
    endfunc

    # Filters
    func blur(ksize)
        if ksize == None
            ksize = 5
        endif
        result = _blur(self.data, self.width, self.height, self.channels, ksize)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func gaussianBlur(ksize, sigma)
        if ksize == None
            ksize = 5
        endif
        if sigma == None
            sigma = 0
        endif
        result = _gaussian_blur(self.data, self.width, self.height, self.channels, ksize, sigma)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func medianBlur(ksize)
        if ksize == None
            ksize = 5
        endif
        result = _median_blur(self.data, self.width, self.height, self.channels, ksize)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func bilateralFilter(d, sigma_color, sigma_space)
        if d == None
            d = 9
        endif
        if sigma_color == None
            sigma_color = 75
        endif
        if sigma_space == None
            sigma_space = 75
        endif
        result = _bilateral_filter(self.data, self.width, self.height, self.channels, d, sigma_color, sigma_space)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    # Edge detection
    func canny(threshold1, threshold2)
        if threshold1 == None
            threshold1 = 100
        endif
        if threshold2 == None
            threshold2 = 200
        endif
        gray = self
        if self.channels > 1
            gray = self.toGrayscale()
        endif
        result = _canny(gray.data, gray.width, gray.height, threshold1, threshold2)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func sobel(dx, dy, ksize)
        if dx == None
            dx = 1
        endif
        if dy == None
            dy = 0
        endif
        if ksize == None
            ksize = 3
        endif
        result = _sobel(self.data, self.width, self.height, self.channels, dx, dy, ksize)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func laplacian(ksize)
        if ksize == None
            ksize = 3
        endif
        result = _laplacian(self.data, self.width, self.height, self.channels, ksize)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    # Thresholding
    func threshold(thresh, maxval, type)
        if thresh == None
            thresh = 127
        endif
        if maxval == None
            maxval = 255
        endif
        if type == None
            type = THRESH_BINARY
        endif
        gray = self
        if self.channels > 1
            gray = self.toGrayscale()
        endif
        result = _threshold(gray.data, gray.width, gray.height, thresh, maxval, type)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func adaptiveThreshold(maxval, method, type, block_size, c)
        if maxval == None
            maxval = 255
        endif
        if method == None
            method = 0  # ADAPTIVE_THRESH_MEAN_C
        endif
        if type == None
            type = THRESH_BINARY
        endif
        if block_size == None
            block_size = 11
        endif
        if c == None
            c = 2
        endif
        gray = self
        if self.channels > 1
            gray = self.toGrayscale()
        endif
        result = _adaptive_threshold(gray.data, gray.width, gray.height, maxval, method, type, block_size, c)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    # Morphological operations
    func dilate(ksize, iterations)
        if ksize == None
            ksize = 3
        endif
        if iterations == None
            iterations = 1
        endif
        result = _dilate(self.data, self.width, self.height, self.channels, ksize, iterations)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func erode(ksize, iterations)
        if ksize == None
            ksize = 3
        endif
        if iterations == None
            iterations = 1
        endif
        result = _erode(self.data, self.width, self.height, self.channels, ksize, iterations)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func morphologyEx(op, ksize, iterations)
        if ksize == None
            ksize = 3
        endif
        if iterations == None
            iterations = 1
        endif
        result = _morphology_ex(self.data, self.width, self.height, self.channels, op, ksize, iterations)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func open(ksize, iterations)
        return self.morphologyEx(MORPH_OPEN, ksize, iterations)
    endfunc

    func close(ksize, iterations)
        return self.morphologyEx(MORPH_CLOSE, ksize, iterations)
    endfunc

    func gradient(ksize, iterations)
        return self.morphologyEx(MORPH_GRADIENT, ksize, iterations)
    endfunc

    func tophat(ksize, iterations)
        return self.morphologyEx(MORPH_TOPHAT, ksize, iterations)
    endfunc

    func blackhat(ksize, iterations)
        return self.morphologyEx(MORPH_BLACKHAT, ksize, iterations)
    endfunc

    # Histogram operations
    func calcHist(bins)
        if bins == None
            bins = 256
        endif
        return _calc_hist(self.data, self.width, self.height, self.channels, bins)
    endfunc

    func equalizeHist()
        gray = self
        if self.channels > 1
            gray = self.toGrayscale()
        endif
        result = _equalize_hist(gray.data, gray.width, gray.height)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    # Drawing operations (modifies image in place and returns self for chaining)
    func drawLine(p1, p2, color, thickness, line_type)
        if thickness == None
            thickness = 1
        endif
        if line_type == None
            line_type = LINE_8
        endif
        _draw_line(self.data, self.width, self.height, self.channels, p1.x, p1.y, p2.x, p2.y, color.r, color.g, color.b, thickness, line_type)
        return self
    endfunc

    func drawRect(rect, color, thickness, line_type)
        if thickness == None
            thickness = 1
        endif
        if line_type == None
            line_type = LINE_8
        endif
        _draw_rectangle(self.data, self.width, self.height, self.channels, rect.x, rect.y, rect.x + rect.width, rect.y + rect.height, color.r, color.g, color.b, thickness, line_type)
        return self
    endfunc

    func drawRectangle(x1, y1, x2, y2, color, thickness, line_type)
        if thickness == None
            thickness = 1
        endif
        if line_type == None
            line_type = LINE_8
        endif
        _draw_rectangle(self.data, self.width, self.height, self.channels, x1, y1, x2, y2, color.r, color.g, color.b, thickness, line_type)
        return self
    endfunc

    func drawCircle(center, radius, color, thickness, line_type)
        if thickness == None
            thickness = 1
        endif
        if line_type == None
            line_type = LINE_8
        endif
        _draw_circle(self.data, self.width, self.height, self.channels, center.x, center.y, radius, color.r, color.g, color.b, thickness, line_type)
        return self
    endfunc

    func drawEllipse(center, axes, angle, start_angle, end_angle, color, thickness, line_type)
        if angle == None
            angle = 0
        endif
        if start_angle == None
            start_angle = 0
        endif
        if end_angle == None
            end_angle = 360
        endif
        if thickness == None
            thickness = 1
        endif
        if line_type == None
            line_type = LINE_8
        endif
        _draw_ellipse(self.data, self.width, self.height, self.channels, center.x, center.y, axes.width, axes.height, angle, start_angle, end_angle, color.r, color.g, color.b, thickness, line_type)
        return self
    endfunc

    func drawPolylines(points, is_closed, color, thickness, line_type)
        if is_closed == None
            is_closed = False
        endif
        if thickness == None
            thickness = 1
        endif
        if line_type == None
            line_type = LINE_8
        endif
        point_list = []
        for p in points
            append(point_list, [p.x, p.y])
        endfor
        _draw_polylines(self.data, self.width, self.height, self.channels, point_list, is_closed, color.r, color.g, color.b, thickness, line_type)
        return self
    endfunc

    func drawText(text, position, color, font, scale, thickness, line_type)
        if font == None
            font = FONT_HERSHEY_SIMPLEX
        endif
        if scale == None
            scale = 1.0
        endif
        if thickness == None
            thickness = 1
        endif
        if line_type == None
            line_type = LINE_8
        endif
        _draw_text(self.data, self.width, self.height, self.channels, text, position.x, position.y, font, scale, color.r, color.g, color.b, thickness, line_type)
        return self
    endfunc

    func fillPoly(points, color)
        point_list = []
        for p in points
            append(point_list, [p.x, p.y])
        endfor
        _fill_poly(self.data, self.width, self.height, self.channels, point_list, color.r, color.g, color.b)
        return self
    endfunc

    # Feature detection
    func findContours(mode, method)
        if mode == None
            mode = 1  # RETR_LIST
        endif
        if method == None
            method = 2  # CHAIN_APPROX_SIMPLE
        endif
        gray = self
        if self.channels > 1
            gray = self.toGrayscale()
        endif
        return _find_contours(gray.data, gray.width, gray.height, mode, method)
    endfunc

    func detectEdges()
        result = _detect_edges(self.data, self.width, self.height, self.channels)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func cornerHarris(block_size, ksize, k)
        if block_size == None
            block_size = 2
        endif
        if ksize == None
            ksize = 3
        endif
        if k == None
            k = 0.04
        endif
        gray = self
        if self.channels > 1
            gray = self.toGrayscale()
        endif
        return _corner_harris(gray.data, gray.width, gray.height, block_size, ksize, k)
    endfunc

    func goodFeaturesToTrack(max_corners, quality, min_dist)
        if max_corners == None
            max_corners = 100
        endif
        if quality == None
            quality = 0.01
        endif
        if min_dist == None
            min_dist = 10
        endif
        gray = self
        if self.channels > 1
            gray = self.toGrayscale()
        endif
        return _good_features_to_track(gray.data, gray.width, gray.height, max_corners, quality, min_dist)
    endfunc

    # Transform operations
    func warpAffine(matrix, new_size)
        if new_size == None
            new_size = new Size(self.width, self.height)
        endif
        result = _warp_affine(self.data, self.width, self.height, self.channels, matrix, new_size.width, new_size.height)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func warpPerspective(matrix, new_size)
        if new_size == None
            new_size = new Size(self.width, self.height)
        endif
        result = _warp_perspective(self.data, self.width, self.height, self.channels, matrix, new_size.width, new_size.height)
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    # Image arithmetic
    func add(other)
        if isinstance(other, Image)
            new_data = []
            for i = 0 to len(self.data) - 1
                val = self.data[i] + other.data[i]
                if val > 255
                    val = 255
                endif
                append(new_data, val)
            endfor
            return new Image(new_data, self.width, self.height, self.channels)
        else
            # Scalar addition
            new_data = []
            for val in self.data
                new_val = val + other
                if new_val > 255
                    new_val = 255
                endif
                if new_val < 0
                    new_val = 0
                endif
                append(new_data, new_val)
            endfor
            return new Image(new_data, self.width, self.height, self.channels)
        endif
    endfunc

    func subtract(other)
        if isinstance(other, Image)
            new_data = []
            for i = 0 to len(self.data) - 1
                val = self.data[i] - other.data[i]
                if val < 0
                    val = 0
                endif
                append(new_data, val)
            endfor
            return new Image(new_data, self.width, self.height, self.channels)
        else
            # Scalar subtraction
            new_data = []
            for val in self.data
                new_val = val - other
                if new_val < 0
                    new_val = 0
                endif
                append(new_data, new_val)
            endfor
            return new Image(new_data, self.width, self.height, self.channels)
        endif
    endfunc

    func multiply(scalar)
        new_data = []
        for val in self.data
            new_val = int(val * scalar)
            if new_val > 255
                new_val = 255
            endif
            if new_val < 0
                new_val = 0
            endif
            append(new_data, new_val)
        endfor
        return new Image(new_data, self.width, self.height, self.channels)
    endfunc

    func blend(other, alpha)
        if alpha == None
            alpha = 0.5
        endif
        new_data = []
        for i = 0 to len(self.data) - 1
            val = int(self.data[i] * alpha + other.data[i] * (1 - alpha))
            if val > 255
                val = 255
            endif
            if val < 0
                val = 0
            endif
            append(new_data, val)
        endfor
        return new Image(new_data, self.width, self.height, self.channels)
    endfunc

    func invert()
        new_data = []
        for val in self.data
            append(new_data, 255 - val)
        endfor
        return new Image(new_data, self.width, self.height, self.channels)
    endfunc

    # Channel operations
    func split()
        channels = []
        for c = 0 to self.channels - 1
            channel_data = []
            for i = 0 to self.width * self.height - 1
                append(channel_data, self.data[i * self.channels + c])
            endfor
            append(channels, new Image(channel_data, self.width, self.height, 1))
        endfor
        return channels
    endfunc

    static func merge(channels)
        if len(channels) == 0
            return None
        endif
        width = channels[0].width
        height = channels[0].height
        num_channels = len(channels)
        data = []
        for i = 0 to width * height - 1
            for c = 0 to num_channels - 1
                append(data, channels[c].data[i])
            endfor
        endfor
        return new Image(data, width, height, num_channels)
    endfunc
endclass

# =============================================================================
# Camera Class
# =============================================================================

class Camera
    func init(handle, device_id)
        self._handle = handle
        self.device_id = device_id
        self.width = 640
        self.height = 480
        self.fps = 30
    endfunc

    static func open(device_id)
        if device_id == None
            device_id = 0
        endif
        handle = _camera_open(device_id)
        if handle == None
            return None
        endif
        cam = new Camera(handle, device_id)
        # Try to get actual dimensions
        cam.width = int(_camera_get_property(handle, 3))  # CAP_PROP_FRAME_WIDTH
        cam.height = int(_camera_get_property(handle, 4))  # CAP_PROP_FRAME_HEIGHT
        cam.fps = _camera_get_property(handle, 5)  # CAP_PROP_FPS
        return cam
    endfunc

    static func openUrl(url)
        handle = _camera_open_url(url)
        if handle == None
            return None
        endif
        cam = new Camera(handle, -1)
        cam.width = int(_camera_get_property(handle, 3))
        cam.height = int(_camera_get_property(handle, 4))
        cam.fps = _camera_get_property(handle, 5)
        return cam
    endfunc

    static func openStream(url)
        return Camera.openUrl(url)
    endfunc

    func isOpened()
        return _camera_is_opened(self._handle)
    endfunc

    func read()
        result = _camera_read(self._handle)
        if result == None
            return None
        endif
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func grab()
        return _camera_grab(self._handle)
    endfunc

    func retrieve()
        result = _camera_retrieve(self._handle)
        if result == None
            return None
        endif
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func release()
        _camera_release(self._handle)
    endfunc

    func setResolution(width, height)
        self.width = width
        self.height = height
        _camera_set_property(self._handle, 3, width)  # CAP_PROP_FRAME_WIDTH
        _camera_set_property(self._handle, 4, height)  # CAP_PROP_FRAME_HEIGHT
        return self
    endfunc

    func setFps(fps)
        self.fps = fps
        _camera_set_property(self._handle, 5, fps)  # CAP_PROP_FPS
        return self
    endfunc

    func setBrightness(value)
        _camera_set_property(self._handle, 10, value)  # CAP_PROP_BRIGHTNESS
        return self
    endfunc

    func setContrast(value)
        _camera_set_property(self._handle, 11, value)  # CAP_PROP_CONTRAST
        return self
    endfunc

    func setSaturation(value)
        _camera_set_property(self._handle, 12, value)  # CAP_PROP_SATURATION
        return self
    endfunc

    func setExposure(value)
        _camera_set_property(self._handle, 15, value)  # CAP_PROP_EXPOSURE
        return self
    endfunc

    func setAutoFocus(enabled)
        _camera_set_property(self._handle, 39, enabled)  # CAP_PROP_AUTOFOCUS
        return self
    endfunc

    func setFocus(value)
        _camera_set_property(self._handle, 28, value)  # CAP_PROP_FOCUS
        return self
    endfunc

    func getProperty(prop_id)
        return _camera_get_property(self._handle, prop_id)
    endfunc

    func setProperty(prop_id, value)
        _camera_set_property(self._handle, prop_id, value)
        return self
    endfunc
endclass

# =============================================================================
# VideoCapture Class (alias for reading video files)
# =============================================================================

class VideoCapture
    func init(handle, path)
        self._handle = handle
        self.path = path
        self.width = 0
        self.height = 0
        self.fps = 0
        self.frameCount = 0
        self.currentFrame = 0
    endfunc

    static func open(path)
        handle = _video_open(path)
        if handle == None
            return None
        endif
        vc = new VideoCapture(handle, path)
        vc.width = int(_video_get_property(handle, 3))  # CAP_PROP_FRAME_WIDTH
        vc.height = int(_video_get_property(handle, 4))  # CAP_PROP_FRAME_HEIGHT
        vc.fps = _video_get_property(handle, 5)  # CAP_PROP_FPS
        vc.frameCount = int(_video_get_property(handle, 7))  # CAP_PROP_FRAME_COUNT
        return vc
    endfunc

    func isOpened()
        return self._handle != None
    endfunc

    func read()
        result = _video_read(self._handle)
        if result == None
            return None
        endif
        self.currentFrame = self.currentFrame + 1
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func grab()
        return _video_grab(self._handle)
    endfunc

    func retrieve()
        result = _video_retrieve(self._handle)
        if result == None
            return None
        endif
        return new Image(result["data"], result["width"], result["height"], result["channels"])
    endfunc

    func release()
        _video_release(self._handle)
    endfunc

    func seek(frame_number)
        _video_set_property(self._handle, 1, frame_number)  # CAP_PROP_POS_FRAMES
        self.currentFrame = frame_number
        return self
    endfunc

    func seekMs(ms)
        _video_set_property(self._handle, 0, ms)  # CAP_PROP_POS_MSEC
        return self
    endfunc

    func getDuration()
        if self.fps > 0
            return self.frameCount / self.fps
        endif
        return 0
    endfunc

    func getProperty(prop_id)
        return _video_get_property(self._handle, prop_id)
    endfunc

    func setProperty(prop_id, value)
        _video_set_property(self._handle, prop_id, value)
        return self
    endfunc
endclass

# =============================================================================
# VideoWriter Class
# =============================================================================

class VideoWriter
    func init(handle, path, fourcc, fps, width, height)
        self._handle = handle
        self.path = path
        self.fourcc = fourcc
        self.fps = fps
        self.width = width
        self.height = height
        self.frameCount = 0
    endfunc

    static func create(path, fourcc, fps, width, height)
        if fourcc == None
            fourcc = FOURCC_MJPG
        endif
        if fps == None
            fps = 30
        endif
        handle = _video_create(path, fourcc, fps, width, height)
        if handle == None
            return None
        endif
        return new VideoWriter(handle, path, fourcc, fps, width, height)
    endfunc

    static func createMp4(path, fps, width, height)
        return VideoWriter.create(path, FOURCC_MP4V, fps, width, height)
    endfunc

    static func createAvi(path, fps, width, height)
        return VideoWriter.create(path, FOURCC_MJPG, fps, width, height)
    endfunc

    func isOpened()
        return self._handle != None
    endfunc

    func write(image)
        result = _video_write(self._handle, image.data, image.width, image.height, image.channels)
        if result
            self.frameCount = self.frameCount + 1
        endif
        return result
    endfunc

    func release()
        _video_release(self._handle)
    endfunc
endclass

# =============================================================================
# Window Class (for displaying images)
# =============================================================================

class Window
    func init(name)
        self.name = name
        self._created = False
    endfunc

    static func create(name)
        return new Window(name)
    endfunc

    func show(image)
        # Note: Display functionality requires GUI support
        # This is a placeholder for future GUI integration
        print "Window.show() requires GUI support (coming soon)"
        return self
    endfunc

    func waitKey(delay)
        if delay == None
            delay = 0
        endif
        # Placeholder for key waiting
        return -1
    endfunc

    func destroy()
        self._created = False
        return self
    endfunc

    static func destroyAll()
        # Placeholder
    endfunc
endclass

# =============================================================================
# Utility Functions
# =============================================================================

func _padHex(value)
    hex = toHex(value)
    if len(hex) == 1
        hex = "0" + hex
    endif
    return hex
endfunc

# Module-level convenience functions

func imread(path)
    return Image.read(path)
endfunc

func imreadGray(path)
    return Image.readGrayscale(path)
endfunc

func imwrite(path, image)
    return image.save(path)
endfunc

func imdecode(buffer, flags)
    return Image.decode(buffer, flags)
endfunc

func imencode(ext, image)
    return image.encode(ext)
endfunc

func cvtColor(image, code)
    return image.convertColor(code)
endfunc

func resize(image, width, height, interpolation)
    return image.resize(width, height, interpolation)
endfunc

func blur(image, ksize)
    return image.blur(ksize)
endfunc

func gaussianBlur(image, ksize, sigma)
    return image.gaussianBlur(ksize, sigma)
endfunc

func canny(image, threshold1, threshold2)
    return image.canny(threshold1, threshold2)
endfunc

func threshold(image, thresh, maxval, type)
    return image.threshold(thresh, maxval, type)
endfunc

func dilate(image, ksize, iterations)
    return image.dilate(ksize, iterations)
endfunc

func erode(image, ksize, iterations)
    return image.erode(ksize, iterations)
endfunc

func getRotationMatrix2D(center, angle, scale)
    if scale == None
        scale = 1.0
    endif
    return _get_rotation_matrix_2d(center.x, center.y, angle, scale)
endfunc

func getPerspectiveTransform(src_points, dst_points)
    src_list = []
    dst_list = []
    for p in src_points
        append(src_list, [p.x, p.y])
    endfor
    for p in dst_points
        append(dst_list, [p.x, p.y])
    endfor
    return _get_perspective_transform(src_list, dst_list)
endfunc

func listCameras()
    return _list_cameras()
endfunc

func getVersion()
    return _get_version()
endfunc

# =============================================================================
# Face Detection Class (Basic Haar Cascade)
# =============================================================================

class FaceDetector
    func init(cascade_path)
        self.cascade_path = cascade_path
        self._loaded = False
    endfunc

    static func create(cascade_path)
        if cascade_path == None
            cascade_path = "haarcascade_frontalface_default.xml"
        endif
        return new FaceDetector(cascade_path)
    endfunc

    func detect(image, scale_factor, min_neighbors, min_size)
        if scale_factor == None
            scale_factor = 1.1
        endif
        if min_neighbors == None
            min_neighbors = 3
        endif
        if min_size == None
            min_size = new Size(30, 30)
        endif
        # This would call native face detection
        # Placeholder for actual implementation
        return []
    endfunc
endclass

# =============================================================================
# Motion Detection Class
# =============================================================================

class MotionDetector
    func init()
        self._prev_frame = None
        self._threshold = 25
        self._min_area = 500
    endfunc

    static func create()
        return new MotionDetector()
    endfunc

    func setThreshold(threshold)
        self._threshold = threshold
        return self
    endfunc

    func setMinArea(min_area)
        self._min_area = min_area
        return self
    endfunc

    func detect(frame)
        gray = frame.toGrayscale().gaussianBlur(21, None)

        if self._prev_frame == None
            self._prev_frame = gray
            return []
        endif

        # Compute difference
        diff = gray.subtract(self._prev_frame)
        thresh = diff.threshold(self._threshold, 255, THRESH_BINARY)
        dilated = thresh.dilate(None, 2)

        # Find contours (simplified - actual implementation in native)
        contours = dilated.findContours(None, None)

        # Update previous frame
        self._prev_frame = gray

        # Filter contours by area
        motions = []
        for contour in contours
            area = contour["area"]
            if area >= self._min_area
                append(motions, contour)
            endif
        endfor

        return motions
    endfunc

    func reset()
        self._prev_frame = None
        return self
    endfunc
endclass

# =============================================================================
# Color Tracker Class
# =============================================================================

class ColorTracker
    func init()
        self._lower = [0, 0, 0]
        self._upper = [255, 255, 255]
    endfunc

    static func create()
        return new ColorTracker()
    endfunc

    func setRange(lower_hsv, upper_hsv)
        self._lower = lower_hsv
        self._upper = upper_hsv
        return self
    endfunc

    func setRedRange()
        # Red wraps around in HSV, so we'd need two ranges
        self._lower = [0, 100, 100]
        self._upper = [10, 255, 255]
        return self
    endfunc

    func setGreenRange()
        self._lower = [35, 100, 100]
        self._upper = [85, 255, 255]
        return self
    endfunc

    func setBlueRange()
        self._lower = [100, 100, 100]
        self._upper = [130, 255, 255]
        return self
    endfunc

    func setYellowRange()
        self._lower = [20, 100, 100]
        self._upper = [35, 255, 255]
        return self
    endfunc

    func track(frame)
        hsv = frame.toHsv()
        # Create mask based on color range
        # Simplified - actual implementation would use native inRange
        mask = hsv  # Placeholder
        contours = mask.findContours(None, None)
        return contours
    endfunc
endclass

# =============================================================================
# QR Code / Barcode Reader (Placeholder)
# =============================================================================

class QRCodeReader
    func init()
        self._decoder = None
    endfunc

    static func create()
        return new QRCodeReader()
    endfunc

    func detect(image)
        # Placeholder for QR code detection
        # Would return bounding box of detected QR codes
        return []
    endfunc

    func decode(image)
        # Placeholder for QR code decoding
        # Would return decoded text
        return None
    endfunc

    func detectAndDecode(image)
        # Combined detection and decoding
        return {"text": None, "points": []}
    endfunc
endclass

# =============================================================================
# Optical Character Recognition (Placeholder)
# =============================================================================

class TextReader
    func init()
        self._lang = "eng"
    endfunc

    static func create(lang)
        if lang == None
            lang = "eng"
        endif
        reader = new TextReader()
        reader._lang = lang
        return reader
    endfunc

    func read(image)
        # Placeholder for OCR
        # Would return detected text
        return ""
    endfunc

    func readLines(image)
        # Would return list of text lines with positions
        return []
    endfunc
endclass

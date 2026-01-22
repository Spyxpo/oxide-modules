/**
 * =============================================================================
 * Oxide Vision Module - Native C Implementation
 * =============================================================================
 *
 * A comprehensive computer vision library providing webcam capture, image/video
 * processing, and visual analysis capabilities using OpenCV.
 *
 * Dependencies:
 *   - OpenCV 4.x (opencv4)
 *   - Platform-specific camera APIs:
 *     - macOS: AVFoundation
 *     - Linux: V4L2
 *     - Windows: DirectShow
 *
 * Build Commands:
 *   macOS:
 *     clang -shared -fPIC -o liboxide_vision.dylib oxide_vision.c \
 *           $(pkg-config --cflags --libs opencv4) \
 *           -framework AVFoundation -framework CoreVideo -framework CoreMedia
 *
 *   Linux:
 *     gcc -shared -fPIC -o liboxide_vision.so oxide_vision.c \
 *         $(pkg-config --cflags --libs opencv4) -lv4l2
 *
 *   Windows:
 *     cl /LD /Fe:oxide_vision.dll oxide_vision.c \
 *        /I"C:\opencv\include" /link /LIBPATH:"C:\opencv\lib" opencv_world4.lib
 *
 * Author: Oxide Team
 * License: MIT
 * =============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

#ifdef __APPLE__
    #include <opencv2/opencv.hpp>
    #include <opencv2/core.hpp>
    #include <opencv2/imgcodecs.hpp>
    #include <opencv2/imgproc.hpp>
    #include <opencv2/videoio.hpp>
    #include <opencv2/highgui.hpp>
#elif defined(_WIN32)
    #include <opencv2/opencv.hpp>
    #include <opencv2/core.hpp>
    #include <opencv2/imgcodecs.hpp>
    #include <opencv2/imgproc.hpp>
    #include <opencv2/videoio.hpp>
    #include <opencv2/highgui.hpp>
#else
    #include <opencv2/opencv.hpp>
    #include <opencv2/core.hpp>
    #include <opencv2/imgcodecs.hpp>
    #include <opencv2/imgproc.hpp>
    #include <opencv2/videoio.hpp>
    #include <opencv2/highgui.hpp>
#endif

/* -----------------------------------------------------------------------------
 * Type Definitions
 * -------------------------------------------------------------------------- */

typedef struct {
    uint8_t* data;
    int width;
    int height;
    int channels;
    size_t size;
} ImageData;

typedef struct {
    cv::VideoCapture* capture;
    int device_id;
    bool is_camera;
} CaptureHandle;

typedef struct {
    cv::VideoWriter* writer;
    int fourcc;
    double fps;
    int width;
    int height;
} WriterHandle;

/* -----------------------------------------------------------------------------
 * Helper Functions
 * -------------------------------------------------------------------------- */

static ImageData* mat_to_image_data(const cv::Mat& mat) {
    if (mat.empty()) {
        return NULL;
    }

    ImageData* img = (ImageData*)malloc(sizeof(ImageData));
    if (!img) return NULL;

    img->width = mat.cols;
    img->height = mat.rows;
    img->channels = mat.channels();
    img->size = mat.total() * mat.elemSize();

    img->data = (uint8_t*)malloc(img->size);
    if (!img->data) {
        free(img);
        return NULL;
    }

    memcpy(img->data, mat.data, img->size);
    return img;
}

static cv::Mat image_data_to_mat(const uint8_t* data, int width, int height, int channels) {
    int type = (channels == 1) ? CV_8UC1 :
               (channels == 3) ? CV_8UC3 :
               (channels == 4) ? CV_8UC4 : CV_8UC3;

    cv::Mat mat(height, width, type);
    memcpy(mat.data, data, width * height * channels);
    return mat;
}

static void free_image_data(ImageData* img) {
    if (img) {
        if (img->data) {
            free(img->data);
        }
        free(img);
    }
}

static int fourcc_from_string(const char* codec) {
    if (strlen(codec) != 4) {
        return cv::VideoWriter::fourcc('M', 'J', 'P', 'G');
    }
    return cv::VideoWriter::fourcc(codec[0], codec[1], codec[2], codec[3]);
}

/* -----------------------------------------------------------------------------
 * Camera/Webcam Functions
 * -------------------------------------------------------------------------- */

extern "C" {

/**
 * Open a camera device by ID
 * @param device_id Camera device index (usually 0 for default camera)
 * @return Handle to the camera capture, or NULL on failure
 */
void* vision_camera_open(int device_id) {
    CaptureHandle* handle = (CaptureHandle*)malloc(sizeof(CaptureHandle));
    if (!handle) return NULL;

    handle->capture = new cv::VideoCapture(device_id);
    if (!handle->capture->isOpened()) {
        delete handle->capture;
        free(handle);
        return NULL;
    }

    handle->device_id = device_id;
    handle->is_camera = true;
    return handle;
}

/**
 * Open a video stream by URL (RTSP, HTTP, etc.)
 * @param url Stream URL
 * @return Handle to the capture, or NULL on failure
 */
void* vision_camera_open_url(const char* url) {
    CaptureHandle* handle = (CaptureHandle*)malloc(sizeof(CaptureHandle));
    if (!handle) return NULL;

    handle->capture = new cv::VideoCapture(url);
    if (!handle->capture->isOpened()) {
        delete handle->capture;
        free(handle);
        return NULL;
    }

    handle->device_id = -1;
    handle->is_camera = false;
    return handle;
}

/**
 * Read a frame from the camera
 * @param handle Camera handle
 * @return ImageData structure with frame data, or NULL on failure
 */
ImageData* vision_camera_read(void* handle) {
    if (!handle) return NULL;

    CaptureHandle* cap = (CaptureHandle*)handle;
    cv::Mat frame;

    if (!cap->capture->read(frame)) {
        return NULL;
    }

    return mat_to_image_data(frame);
}

/**
 * Release camera resources
 * @param handle Camera handle
 */
void vision_camera_release(void* handle) {
    if (!handle) return;

    CaptureHandle* cap = (CaptureHandle*)handle;
    if (cap->capture) {
        cap->capture->release();
        delete cap->capture;
    }
    free(cap);
}

/**
 * Check if camera is opened
 * @param handle Camera handle
 * @return true if opened, false otherwise
 */
bool vision_camera_is_opened(void* handle) {
    if (!handle) return false;
    CaptureHandle* cap = (CaptureHandle*)handle;
    return cap->capture && cap->capture->isOpened();
}

/**
 * Set camera property
 * @param handle Camera handle
 * @param prop_id Property ID (OpenCV VideoCaptureProperties)
 * @param value Property value
 * @return true on success
 */
bool vision_camera_set_property(void* handle, int prop_id, double value) {
    if (!handle) return false;
    CaptureHandle* cap = (CaptureHandle*)handle;
    return cap->capture->set(prop_id, value);
}

/**
 * Get camera property
 * @param handle Camera handle
 * @param prop_id Property ID
 * @return Property value
 */
double vision_camera_get_property(void* handle, int prop_id) {
    if (!handle) return 0;
    CaptureHandle* cap = (CaptureHandle*)handle;
    return cap->capture->get(prop_id);
}

/**
 * Grab a frame (without decoding)
 * @param handle Camera handle
 * @return true on success
 */
bool vision_camera_grab(void* handle) {
    if (!handle) return false;
    CaptureHandle* cap = (CaptureHandle*)handle;
    return cap->capture->grab();
}

/**
 * Retrieve a previously grabbed frame
 * @param handle Camera handle
 * @return ImageData or NULL
 */
ImageData* vision_camera_retrieve(void* handle) {
    if (!handle) return NULL;
    CaptureHandle* cap = (CaptureHandle*)handle;
    cv::Mat frame;
    if (!cap->capture->retrieve(frame)) {
        return NULL;
    }
    return mat_to_image_data(frame);
}

/* -----------------------------------------------------------------------------
 * Image I/O Functions
 * -------------------------------------------------------------------------- */

/**
 * Read an image from file
 * @param path File path
 * @return ImageData or NULL
 */
ImageData* vision_image_read(const char* path) {
    cv::Mat img = cv::imread(path, cv::IMREAD_COLOR);
    if (img.empty()) {
        return NULL;
    }
    return mat_to_image_data(img);
}

/**
 * Read an image with flags
 * @param path File path
 * @param flags Read flags (IMREAD_GRAYSCALE=0, IMREAD_COLOR=1, IMREAD_UNCHANGED=-1)
 * @return ImageData or NULL
 */
ImageData* vision_image_read_flags(const char* path, int flags) {
    cv::Mat img = cv::imread(path, flags);
    if (img.empty()) {
        return NULL;
    }
    return mat_to_image_data(img);
}

/**
 * Write an image to file
 * @param path Output file path
 * @param data Image data
 * @param width Image width
 * @param height Image height
 * @param channels Number of channels
 * @return true on success
 */
bool vision_image_write(const char* path, const uint8_t* data, int width, int height, int channels) {
    cv::Mat img = image_data_to_mat(data, width, height, channels);
    return cv::imwrite(path, img);
}

/**
 * Write an image with parameters (e.g., JPEG quality)
 * @param path Output file path
 * @param data Image data
 * @param width Image width
 * @param height Image height
 * @param channels Number of channels
 * @param params Array of parameter pairs
 * @param param_count Number of parameter pairs
 * @return true on success
 */
bool vision_image_write_params(const char* path, const uint8_t* data, int width, int height,
                                int channels, const int* params, int param_count) {
    cv::Mat img = image_data_to_mat(data, width, height, channels);
    std::vector<int> compression_params;
    for (int i = 0; i < param_count * 2; i++) {
        compression_params.push_back(params[i]);
    }
    return cv::imwrite(path, img, compression_params);
}

/**
 * Decode image from memory buffer
 * @param buffer Encoded image data
 * @param buffer_size Buffer size
 * @param flags Read flags
 * @return ImageData or NULL
 */
ImageData* vision_image_decode(const uint8_t* buffer, size_t buffer_size, int flags) {
    std::vector<uint8_t> buf(buffer, buffer + buffer_size);
    cv::Mat img = cv::imdecode(buf, flags);
    if (img.empty()) {
        return NULL;
    }
    return mat_to_image_data(img);
}

/**
 * Encode image to memory buffer
 * @param ext File extension (e.g., ".jpg", ".png")
 * @param data Image data
 * @param width Image width
 * @param height Image height
 * @param channels Number of channels
 * @param out_buffer Output buffer (allocated by function)
 * @param out_size Output buffer size
 * @return true on success
 */
bool vision_image_encode(const char* ext, const uint8_t* data, int width, int height,
                          int channels, uint8_t** out_buffer, size_t* out_size) {
    cv::Mat img = image_data_to_mat(data, width, height, channels);
    std::vector<uint8_t> buf;

    if (!cv::imencode(ext, img, buf)) {
        return false;
    }

    *out_size = buf.size();
    *out_buffer = (uint8_t*)malloc(*out_size);
    if (!*out_buffer) {
        return false;
    }

    memcpy(*out_buffer, buf.data(), *out_size);
    return true;
}

/* -----------------------------------------------------------------------------
 * Video I/O Functions
 * -------------------------------------------------------------------------- */

/**
 * Open a video file for reading
 * @param path Video file path
 * @return Handle or NULL
 */
void* vision_video_open(const char* path) {
    CaptureHandle* handle = (CaptureHandle*)malloc(sizeof(CaptureHandle));
    if (!handle) return NULL;

    handle->capture = new cv::VideoCapture(path);
    if (!handle->capture->isOpened()) {
        delete handle->capture;
        free(handle);
        return NULL;
    }

    handle->device_id = -1;
    handle->is_camera = false;
    return handle;
}

/**
 * Create a video file for writing
 * @param path Output file path
 * @param fourcc Four-character codec code (e.g., "MJPG")
 * @param fps Frames per second
 * @param width Frame width
 * @param height Frame height
 * @return Handle or NULL
 */
void* vision_video_create(const char* path, const char* fourcc, double fps, int width, int height) {
    WriterHandle* handle = (WriterHandle*)malloc(sizeof(WriterHandle));
    if (!handle) return NULL;

    int codec = fourcc_from_string(fourcc);
    handle->writer = new cv::VideoWriter(path, codec, fps, cv::Size(width, height));

    if (!handle->writer->isOpened()) {
        delete handle->writer;
        free(handle);
        return NULL;
    }

    handle->fourcc = codec;
    handle->fps = fps;
    handle->width = width;
    handle->height = height;
    return handle;
}

/**
 * Read a frame from video
 * @param handle Video capture handle
 * @return ImageData or NULL
 */
ImageData* vision_video_read(void* handle) {
    return vision_camera_read(handle);
}

/**
 * Write a frame to video
 * @param handle Video writer handle
 * @param data Frame data
 * @param width Frame width
 * @param height Frame height
 * @param channels Number of channels
 * @return true on success
 */
bool vision_video_write(void* handle, const uint8_t* data, int width, int height, int channels) {
    if (!handle) return false;

    WriterHandle* writer = (WriterHandle*)handle;
    cv::Mat frame = image_data_to_mat(data, width, height, channels);
    writer->writer->write(frame);
    return true;
}

/**
 * Release video resources
 * @param handle Video handle (capture or writer)
 */
void vision_video_release(void* handle) {
    vision_camera_release(handle);
}

/**
 * Get video property
 */
double vision_video_get_property(void* handle, int prop_id) {
    return vision_camera_get_property(handle, prop_id);
}

/**
 * Set video property
 */
bool vision_video_set_property(void* handle, int prop_id, double value) {
    return vision_camera_set_property(handle, prop_id, value);
}

/**
 * Grab video frame
 */
bool vision_video_grab(void* handle) {
    return vision_camera_grab(handle);
}

/**
 * Retrieve video frame
 */
ImageData* vision_video_retrieve(void* handle) {
    return vision_camera_retrieve(handle);
}

/* -----------------------------------------------------------------------------
 * Image Processing Functions
 * -------------------------------------------------------------------------- */

/**
 * Convert color space
 * @param data Image data
 * @param width Image width
 * @param height Image height
 * @param channels Number of channels
 * @param code Conversion code (OpenCV ColorConversionCodes)
 * @return ImageData or NULL
 */
ImageData* vision_cvt_color(const uint8_t* data, int width, int height, int channels, int code) {
    cv::Mat src = image_data_to_mat(data, width, height, channels);
    cv::Mat dst;
    cv::cvtColor(src, dst, code);
    return mat_to_image_data(dst);
}

/**
 * Resize image
 * @param data Image data
 * @param width Current width
 * @param height Current height
 * @param channels Number of channels
 * @param new_width Target width
 * @param new_height Target height
 * @param interpolation Interpolation method
 * @return ImageData or NULL
 */
ImageData* vision_resize(const uint8_t* data, int width, int height, int channels,
                          int new_width, int new_height, int interpolation) {
    cv::Mat src = image_data_to_mat(data, width, height, channels);
    cv::Mat dst;
    cv::resize(src, dst, cv::Size(new_width, new_height), 0, 0, interpolation);
    return mat_to_image_data(dst);
}

/**
 * Rotate image
 * @param data Image data
 * @param width Image width
 * @param height Image height
 * @param channels Number of channels
 * @param angle Rotation angle (90, 180, 270)
 * @return ImageData or NULL
 */
ImageData* vision_rotate(const uint8_t* data, int width, int height, int channels, int angle) {
    cv::Mat src = image_data_to_mat(data, width, height, channels);
    cv::Mat dst;

    int rotateCode;
    switch (angle) {
        case 90:
            rotateCode = cv::ROTATE_90_CLOCKWISE;
            break;
        case 180:
            rotateCode = cv::ROTATE_180;
            break;
        case 270:
            rotateCode = cv::ROTATE_90_COUNTERCLOCKWISE;
            break;
        default:
            // For arbitrary angles, use warpAffine
            cv::Point2f center(width / 2.0f, height / 2.0f);
            cv::Mat rotation = cv::getRotationMatrix2D(center, -angle, 1.0);
            cv::warpAffine(src, dst, rotation, src.size());
            return mat_to_image_data(dst);
    }

    cv::rotate(src, dst, rotateCode);
    return mat_to_image_data(dst);
}

/**
 * Flip image
 * @param data Image data
 * @param width Image width
 * @param height Image height
 * @param channels Number of channels
 * @param flip_code Flip code (0=vertical, 1=horizontal, -1=both)
 * @return ImageData or NULL
 */
ImageData* vision_flip(const uint8_t* data, int width, int height, int channels, int flip_code) {
    cv::Mat src = image_data_to_mat(data, width, height, channels);
    cv::Mat dst;
    cv::flip(src, dst, flip_code);
    return mat_to_image_data(dst);
}

/**
 * Crop image
 * @param data Image data
 * @param width Image width
 * @param height Image height
 * @param channels Number of channels
 * @param x Crop X position
 * @param y Crop Y position
 * @param w Crop width
 * @param h Crop height
 * @return ImageData or NULL
 */
ImageData* vision_crop(const uint8_t* data, int width, int height, int channels,
                        int x, int y, int w, int h) {
    cv::Mat src = image_data_to_mat(data, width, height, channels);
    cv::Rect roi(x, y, w, h);
    cv::Mat dst = src(roi).clone();
    return mat_to_image_data(dst);
}

/**
 * Box blur filter
 */
ImageData* vision_blur(const uint8_t* data, int width, int height, int channels, int ksize) {
    cv::Mat src = image_data_to_mat(data, width, height, channels);
    cv::Mat dst;
    cv::blur(src, dst, cv::Size(ksize, ksize));
    return mat_to_image_data(dst);
}

/**
 * Gaussian blur filter
 */
ImageData* vision_gaussian_blur(const uint8_t* data, int width, int height, int channels,
                                 int ksize, double sigma) {
    cv::Mat src = image_data_to_mat(data, width, height, channels);
    cv::Mat dst;
    cv::GaussianBlur(src, dst, cv::Size(ksize, ksize), sigma);
    return mat_to_image_data(dst);
}

/**
 * Median blur filter
 */
ImageData* vision_median_blur(const uint8_t* data, int width, int height, int channels, int ksize) {
    cv::Mat src = image_data_to_mat(data, width, height, channels);
    cv::Mat dst;
    cv::medianBlur(src, dst, ksize);
    return mat_to_image_data(dst);
}

/**
 * Bilateral filter
 */
ImageData* vision_bilateral_filter(const uint8_t* data, int width, int height, int channels,
                                    int d, double sigma_color, double sigma_space) {
    cv::Mat src = image_data_to_mat(data, width, height, channels);
    cv::Mat dst;
    cv::bilateralFilter(src, dst, d, sigma_color, sigma_space);
    return mat_to_image_data(dst);
}

/**
 * Canny edge detection
 */
ImageData* vision_canny(const uint8_t* data, int width, int height,
                         double threshold1, double threshold2) {
    cv::Mat src = image_data_to_mat(data, width, height, 1);
    cv::Mat dst;
    cv::Canny(src, dst, threshold1, threshold2);
    return mat_to_image_data(dst);
}

/**
 * Sobel edge detection
 */
ImageData* vision_sobel(const uint8_t* data, int width, int height, int channels,
                         int dx, int dy, int ksize) {
    cv::Mat src = image_data_to_mat(data, width, height, channels);
    cv::Mat dst;
    cv::Sobel(src, dst, CV_8U, dx, dy, ksize);
    return mat_to_image_data(dst);
}

/**
 * Laplacian edge detection
 */
ImageData* vision_laplacian(const uint8_t* data, int width, int height, int channels, int ksize) {
    cv::Mat src = image_data_to_mat(data, width, height, channels);
    cv::Mat dst;
    cv::Laplacian(src, dst, CV_8U, ksize);
    return mat_to_image_data(dst);
}

/**
 * Threshold operation
 */
ImageData* vision_threshold(const uint8_t* data, int width, int height,
                             double thresh, double maxval, int type) {
    cv::Mat src = image_data_to_mat(data, width, height, 1);
    cv::Mat dst;
    cv::threshold(src, dst, thresh, maxval, type);
    return mat_to_image_data(dst);
}

/**
 * Adaptive threshold
 */
ImageData* vision_adaptive_threshold(const uint8_t* data, int width, int height,
                                      double maxval, int method, int type,
                                      int block_size, double c) {
    cv::Mat src = image_data_to_mat(data, width, height, 1);
    cv::Mat dst;
    cv::adaptiveThreshold(src, dst, maxval, method, type, block_size, c);
    return mat_to_image_data(dst);
}

/**
 * Dilation morphological operation
 */
ImageData* vision_dilate(const uint8_t* data, int width, int height, int channels,
                          int ksize, int iterations) {
    cv::Mat src = image_data_to_mat(data, width, height, channels);
    cv::Mat dst;
    cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(ksize, ksize));
    cv::dilate(src, dst, kernel, cv::Point(-1, -1), iterations);
    return mat_to_image_data(dst);
}

/**
 * Erosion morphological operation
 */
ImageData* vision_erode(const uint8_t* data, int width, int height, int channels,
                         int ksize, int iterations) {
    cv::Mat src = image_data_to_mat(data, width, height, channels);
    cv::Mat dst;
    cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(ksize, ksize));
    cv::erode(src, dst, kernel, cv::Point(-1, -1), iterations);
    return mat_to_image_data(dst);
}

/**
 * General morphological operation
 */
ImageData* vision_morphology_ex(const uint8_t* data, int width, int height, int channels,
                                 int op, int ksize, int iterations) {
    cv::Mat src = image_data_to_mat(data, width, height, channels);
    cv::Mat dst;
    cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(ksize, ksize));
    cv::morphologyEx(src, dst, op, kernel, cv::Point(-1, -1), iterations);
    return mat_to_image_data(dst);
}

/* -----------------------------------------------------------------------------
 * Drawing Functions
 * -------------------------------------------------------------------------- */

/**
 * Draw a line
 */
void vision_draw_line(uint8_t* data, int width, int height, int channels,
                       int x1, int y1, int x2, int y2,
                       int r, int g, int b, int thickness, int line_type) {
    cv::Mat img = image_data_to_mat(data, width, height, channels);
    cv::line(img, cv::Point(x1, y1), cv::Point(x2, y2), cv::Scalar(b, g, r), thickness, line_type);
    memcpy(data, img.data, img.total() * img.elemSize());
}

/**
 * Draw a rectangle
 */
void vision_draw_rectangle(uint8_t* data, int width, int height, int channels,
                            int x1, int y1, int x2, int y2,
                            int r, int g, int b, int thickness, int line_type) {
    cv::Mat img = image_data_to_mat(data, width, height, channels);
    cv::rectangle(img, cv::Point(x1, y1), cv::Point(x2, y2), cv::Scalar(b, g, r), thickness, line_type);
    memcpy(data, img.data, img.total() * img.elemSize());
}

/**
 * Draw a circle
 */
void vision_draw_circle(uint8_t* data, int width, int height, int channels,
                         int cx, int cy, int radius,
                         int r, int g, int b, int thickness, int line_type) {
    cv::Mat img = image_data_to_mat(data, width, height, channels);
    cv::circle(img, cv::Point(cx, cy), radius, cv::Scalar(b, g, r), thickness, line_type);
    memcpy(data, img.data, img.total() * img.elemSize());
}

/**
 * Draw an ellipse
 */
void vision_draw_ellipse(uint8_t* data, int width, int height, int channels,
                          int cx, int cy, int ax, int ay,
                          double angle, double start_angle, double end_angle,
                          int r, int g, int b, int thickness, int line_type) {
    cv::Mat img = image_data_to_mat(data, width, height, channels);
    cv::ellipse(img, cv::Point(cx, cy), cv::Size(ax, ay), angle, start_angle, end_angle,
                cv::Scalar(b, g, r), thickness, line_type);
    memcpy(data, img.data, img.total() * img.elemSize());
}

/**
 * Draw polylines
 */
void vision_draw_polylines(uint8_t* data, int width, int height, int channels,
                            const int* points, int num_points, bool is_closed,
                            int r, int g, int b, int thickness, int line_type) {
    cv::Mat img = image_data_to_mat(data, width, height, channels);

    std::vector<cv::Point> pts;
    for (int i = 0; i < num_points; i++) {
        pts.push_back(cv::Point(points[i * 2], points[i * 2 + 1]));
    }

    std::vector<std::vector<cv::Point>> ptsArray = {pts};
    cv::polylines(img, ptsArray, is_closed, cv::Scalar(b, g, r), thickness, line_type);
    memcpy(data, img.data, img.total() * img.elemSize());
}

/**
 * Draw text
 */
void vision_draw_text(uint8_t* data, int width, int height, int channels,
                       const char* text, int x, int y,
                       int font_face, double font_scale,
                       int r, int g, int b, int thickness, int line_type) {
    cv::Mat img = image_data_to_mat(data, width, height, channels);
    cv::putText(img, text, cv::Point(x, y), font_face, font_scale,
                cv::Scalar(b, g, r), thickness, line_type);
    memcpy(data, img.data, img.total() * img.elemSize());
}

/**
 * Fill polygon
 */
void vision_fill_poly(uint8_t* data, int width, int height, int channels,
                       const int* points, int num_points, int r, int g, int b) {
    cv::Mat img = image_data_to_mat(data, width, height, channels);

    std::vector<cv::Point> pts;
    for (int i = 0; i < num_points; i++) {
        pts.push_back(cv::Point(points[i * 2], points[i * 2 + 1]));
    }

    std::vector<std::vector<cv::Point>> ptsArray = {pts};
    cv::fillPoly(img, ptsArray, cv::Scalar(b, g, r));
    memcpy(data, img.data, img.total() * img.elemSize());
}

/* -----------------------------------------------------------------------------
 * Feature Detection Functions
 * -------------------------------------------------------------------------- */

/**
 * Find contours in binary image
 * @return Array of contour data (simplified format)
 */
int vision_find_contours(const uint8_t* data, int width, int height,
                          int mode, int method,
                          int** contours_out, int* num_contours) {
    cv::Mat src = image_data_to_mat(data, width, height, 1);
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;

    cv::findContours(src, contours, hierarchy, mode, method);

    *num_contours = contours.size();
    // Simplified: return count only, actual implementation would return contour data
    return contours.size();
}

/**
 * Harris corner detection
 */
ImageData* vision_corner_harris(const uint8_t* data, int width, int height,
                                 int block_size, int ksize, double k) {
    cv::Mat src = image_data_to_mat(data, width, height, 1);
    cv::Mat dst, dst_norm;

    src.convertTo(src, CV_32F);
    cv::cornerHarris(src, dst, block_size, ksize, k);
    cv::normalize(dst, dst_norm, 0, 255, cv::NORM_MINMAX, CV_32FC1, cv::Mat());

    cv::Mat dst_8u;
    dst_norm.convertTo(dst_8u, CV_8U);
    return mat_to_image_data(dst_8u);
}

/**
 * Good features to track (Shi-Tomasi corners)
 */
int vision_good_features_to_track(const uint8_t* data, int width, int height,
                                    int max_corners, double quality_level, double min_distance,
                                    int** corners_out) {
    cv::Mat src = image_data_to_mat(data, width, height, 1);
    std::vector<cv::Point2f> corners;

    cv::goodFeaturesToTrack(src, corners, max_corners, quality_level, min_distance);

    // Simplified: return count only
    return corners.size();
}

/* -----------------------------------------------------------------------------
 * Histogram Functions
 * -------------------------------------------------------------------------- */

/**
 * Calculate histogram
 */
int* vision_calc_hist(const uint8_t* data, int width, int height, int channels, int bins) {
    cv::Mat src = image_data_to_mat(data, width, height, channels);

    int* hist_data = (int*)malloc(bins * sizeof(int));
    if (!hist_data) return NULL;

    // Calculate histogram for first channel
    cv::Mat hist;
    int histSize[] = {bins};
    float range[] = {0, 256};
    const float* histRange[] = {range};
    int channels_arr[] = {0};

    cv::calcHist(&src, 1, channels_arr, cv::Mat(), hist, 1, histSize, histRange);

    for (int i = 0; i < bins; i++) {
        hist_data[i] = (int)hist.at<float>(i);
    }

    return hist_data;
}

/**
 * Equalize histogram
 */
ImageData* vision_equalize_hist(const uint8_t* data, int width, int height) {
    cv::Mat src = image_data_to_mat(data, width, height, 1);
    cv::Mat dst;
    cv::equalizeHist(src, dst);
    return mat_to_image_data(dst);
}

/* -----------------------------------------------------------------------------
 * Transform Functions
 * -------------------------------------------------------------------------- */

/**
 * Warp affine transformation
 */
ImageData* vision_warp_affine(const uint8_t* data, int width, int height, int channels,
                               const double* matrix, int new_width, int new_height) {
    cv::Mat src = image_data_to_mat(data, width, height, channels);
    cv::Mat dst;
    cv::Mat M = (cv::Mat_<double>(2, 3) << matrix[0], matrix[1], matrix[2],
                                            matrix[3], matrix[4], matrix[5]);
    cv::warpAffine(src, dst, M, cv::Size(new_width, new_height));
    return mat_to_image_data(dst);
}

/**
 * Warp perspective transformation
 */
ImageData* vision_warp_perspective(const uint8_t* data, int width, int height, int channels,
                                    const double* matrix, int new_width, int new_height) {
    cv::Mat src = image_data_to_mat(data, width, height, channels);
    cv::Mat dst;
    cv::Mat M = (cv::Mat_<double>(3, 3) << matrix[0], matrix[1], matrix[2],
                                            matrix[3], matrix[4], matrix[5],
                                            matrix[6], matrix[7], matrix[8]);
    cv::warpPerspective(src, dst, M, cv::Size(new_width, new_height));
    return mat_to_image_data(dst);
}

/**
 * Get rotation matrix for 2D rotation
 */
void vision_get_rotation_matrix_2d(double cx, double cy, double angle, double scale, double* matrix) {
    cv::Mat M = cv::getRotationMatrix2D(cv::Point2f(cx, cy), angle, scale);
    for (int i = 0; i < 6; i++) {
        matrix[i] = M.at<double>(i / 3, i % 3);
    }
}

/**
 * Get perspective transform matrix
 */
void vision_get_perspective_transform(const double* src_points, const double* dst_points, double* matrix) {
    std::vector<cv::Point2f> src(4), dst(4);
    for (int i = 0; i < 4; i++) {
        src[i] = cv::Point2f(src_points[i * 2], src_points[i * 2 + 1]);
        dst[i] = cv::Point2f(dst_points[i * 2], dst_points[i * 2 + 1]);
    }
    cv::Mat M = cv::getPerspectiveTransform(src, dst);
    for (int i = 0; i < 9; i++) {
        matrix[i] = M.at<double>(i / 3, i % 3);
    }
}

/* -----------------------------------------------------------------------------
 * Utility Functions
 * -------------------------------------------------------------------------- */

/**
 * Get OpenCV version
 */
const char* vision_get_version() {
    static char version[64];
    snprintf(version, sizeof(version), "%d.%d.%d", CV_MAJOR_VERSION, CV_MINOR_VERSION, CV_SUBMINOR_VERSION);
    return version;
}

/**
 * List available cameras
 */
int vision_list_cameras(int* camera_ids, int max_cameras) {
    int count = 0;
    for (int i = 0; i < max_cameras && i < 10; i++) {
        cv::VideoCapture cap(i);
        if (cap.isOpened()) {
            camera_ids[count++] = i;
            cap.release();
        }
    }
    return count;
}

} /* extern "C" */

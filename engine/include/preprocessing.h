#pragma once

#include <opencv2/opencv.hpp>
#include <vector>
#include <cstdint>

namespace ventus {

/**
 * Image preprocessing pipeline for scene classification.
 * Handles resizing, normalization, and format conversion
 * optimized for TensorFlow Lite inference.
 */
class Preprocessor {
public:
    struct Config {
        int target_width = 224;
        int target_height = 224;
        bool normalize = true;
        float mean[3] = {0.485f, 0.456f, 0.406f};  // ImageNet means
        float std[3] = {0.229f, 0.224f, 0.225f};   // ImageNet stds
    };

    explicit Preprocessor(const Config& config = Config{});

    /**
     * Decode image from raw bytes (JPEG/PNG).
     * @param data Raw image bytes
     * @param size Size of the byte array
     * @return Decoded BGR image
     */
    cv::Mat decode(const uint8_t* data, size_t size);

    /**
     * Preprocess image for model inference.
     * Applies resize, color conversion, and normalization.
     * @param image Input BGR image
     * @return Preprocessed float tensor (NHWC format)
     */
    std::vector<float> process(const cv::Mat& image);

    /**
     * Full pipeline: decode + preprocess.
     * @param data Raw image bytes
     * @param size Size of the byte array
     * @return Preprocessed float tensor
     */
    std::vector<float> decodeAndProcess(const uint8_t* data, size_t size);

    // Accessors
    int targetWidth() const { return config_.target_width; }
    int targetHeight() const { return config_.target_height; }

private:
    Config config_;
    
    cv::Mat resize(const cv::Mat& image);
    cv::Mat normalize(const cv::Mat& image);
};

}  // namespace ventus


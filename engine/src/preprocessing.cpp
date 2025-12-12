#include "preprocessing.h"
#include <stdexcept>

namespace ventus {

Preprocessor::Preprocessor(const Config& config) : config_(config) {}

cv::Mat Preprocessor::decode(const uint8_t* data, size_t size) {
    std::vector<uint8_t> buffer(data, data + size);
    cv::Mat image = cv::imdecode(buffer, cv::IMREAD_COLOR);
    
    if (image.empty()) {
        throw std::runtime_error("Failed to decode image");
    }
    
    return image;
}

cv::Mat Preprocessor::resize(const cv::Mat& image) {
    cv::Mat resized;
    cv::resize(image, resized, 
               cv::Size(config_.target_width, config_.target_height),
               0, 0, cv::INTER_LINEAR);
    return resized;
}

cv::Mat Preprocessor::normalize(const cv::Mat& image) {
    cv::Mat rgb;
    cv::cvtColor(image, rgb, cv::COLOR_BGR2RGB);
    
    cv::Mat float_img;
    rgb.convertTo(float_img, CV_32FC3, 1.0 / 255.0);
    
    if (config_.normalize) {
        std::vector<cv::Mat> channels(3);
        cv::split(float_img, channels);
        
        for (int i = 0; i < 3; ++i) {
            channels[i] = (channels[i] - config_.mean[i]) / config_.std[i];
        }
        
        cv::merge(channels, float_img);
    }
    
    return float_img;
}

std::vector<float> Preprocessor::process(const cv::Mat& image) {
    cv::Mat resized = resize(image);
    cv::Mat normalized = normalize(resized);
    
    // Convert to flat vector (NHWC format)
    std::vector<float> output(config_.target_width * config_.target_height * 3);
    
    int idx = 0;
    for (int y = 0; y < normalized.rows; ++y) {
        for (int x = 0; x < normalized.cols; ++x) {
            cv::Vec3f pixel = normalized.at<cv::Vec3f>(y, x);
            output[idx++] = pixel[0];  // R
            output[idx++] = pixel[1];  // G
            output[idx++] = pixel[2];  // B
        }
    }
    
    return output;
}

std::vector<float> Preprocessor::decodeAndProcess(const uint8_t* data, size_t size) {
    cv::Mat image = decode(data, size);
    return process(image);
}

}  // namespace ventus


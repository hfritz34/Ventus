#include <gtest/gtest.h>
#include "preprocessing.h"
#include <fstream>
#include <vector>

namespace ventus {
namespace testing {

class PreprocessorTest : public ::testing::Test {
protected:
    void SetUp() override {
        preprocessor_ = std::make_unique<Preprocessor>();
    }

    std::unique_ptr<Preprocessor> preprocessor_;
};

TEST_F(PreprocessorTest, TargetDimensionsAreCorrect) {
    EXPECT_EQ(preprocessor_->targetWidth(), 224);
    EXPECT_EQ(preprocessor_->targetHeight(), 224);
}

TEST_F(PreprocessorTest, ProcessReturnsCorrectSize) {
    // Create a dummy 640x480 image
    cv::Mat test_image(480, 640, CV_8UC3, cv::Scalar(128, 128, 128));
    
    auto result = preprocessor_->process(test_image);
    
    // Should be 224 * 224 * 3 = 150528 floats
    EXPECT_EQ(result.size(), 224 * 224 * 3);
}

TEST_F(PreprocessorTest, NormalizationAppliesCorrectly) {
    // Create a white image
    cv::Mat white_image(224, 224, CV_8UC3, cv::Scalar(255, 255, 255));
    
    auto result = preprocessor_->process(white_image);
    
    // After normalization, values should not be 1.0
    // (1.0 - mean) / std != 1.0 for ImageNet stats
    bool all_ones = true;
    for (float val : result) {
        if (std::abs(val - 1.0f) > 0.01f) {
            all_ones = false;
            break;
        }
    }
    EXPECT_FALSE(all_ones);
}

TEST_F(PreprocessorTest, HandlesVariousImageSizes) {
    std::vector<cv::Size> sizes = {
        {320, 240}, {640, 480}, {1920, 1080}, {100, 100}
    };
    
    for (const auto& size : sizes) {
        cv::Mat image(size.height, size.width, CV_8UC3, cv::Scalar(100, 150, 200));
        auto result = preprocessor_->process(image);
        EXPECT_EQ(result.size(), 224 * 224 * 3) 
            << "Failed for size " << size.width << "x" << size.height;
    }
}

TEST_F(PreprocessorTest, DecodeThrowsOnInvalidData) {
    std::vector<uint8_t> invalid_data = {0, 1, 2, 3, 4, 5};
    
    EXPECT_THROW(
        preprocessor_->decode(invalid_data.data(), invalid_data.size()),
        std::runtime_error
    );
}

}  // namespace testing
}  // namespace ventus


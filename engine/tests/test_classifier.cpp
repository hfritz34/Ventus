#include <gtest/gtest.h>
#include "scene_classifier.h"

namespace ventus {
namespace testing {

class SceneClassifierTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Tests that don't require model loading
    }
};

TEST_F(SceneClassifierTest, OutdoorLabelsArePopulated) {
    EXPECT_GT(kOutdoorLabels.size(), 30);
}

TEST_F(SceneClassifierTest, OutdoorLabelsContainExpectedCategories) {
    std::vector<std::string> expected = {"sky", "outdoor", "tree", "park", "beach"};
    
    for (const auto& label : expected) {
        auto it = std::find(kOutdoorLabels.begin(), kOutdoorLabels.end(), label);
        EXPECT_NE(it, kOutdoorLabels.end()) << "Missing label: " << label;
    }
}

TEST_F(SceneClassifierTest, ConfigDefaultsAreReasonable) {
    SceneClassifier::Config config;
    
    EXPECT_EQ(config.num_threads, 4);
    EXPECT_FALSE(config.use_gpu);
    EXPECT_FLOAT_EQ(config.outdoor_threshold, 0.6f);
    EXPECT_EQ(config.top_k, 5);
}

// Integration tests (require model file)
class SceneClassifierIntegrationTest : public ::testing::Test {
protected:
    void SetUp() override {
        config_.model_path = "models/scene_classifier.tflite";
        config_.num_threads = 2;
    }

    SceneClassifier::Config config_;
};

TEST_F(SceneClassifierIntegrationTest, DISABLED_LoadsModelSuccessfully) {
    // Disabled by default - enable when model file is available
    SceneClassifier classifier(config_);
    EXPECT_TRUE(classifier.isReady());
}

TEST_F(SceneClassifierIntegrationTest, DISABLED_ClassifiesOutdoorScene) {
    SceneClassifier classifier(config_);
    
    // Create synthetic "outdoor-like" input tensor
    std::vector<float> input(224 * 224 * 3, 0.5f);
    
    auto result = classifier.classify(input);
    
    EXPECT_FALSE(result.predictions.empty());
    EXPECT_GE(result.inference_time_ms, 0);
}

TEST_F(SceneClassifierIntegrationTest, DISABLED_ReturnsTopKPredictions) {
    SceneClassifier classifier(config_);
    std::vector<float> input(224 * 224 * 3, 0.5f);
    
    auto result = classifier.classify(input);
    
    EXPECT_LE(result.predictions.size(), static_cast<size_t>(config_.top_k));
}

}  // namespace testing
}  // namespace ventus


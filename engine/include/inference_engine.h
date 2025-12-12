#pragma once

#include "preprocessing.h"
#include "scene_classifier.h"
#include <memory>
#include <atomic>
#include <chrono>

namespace ventus {

/**
 * Face detection result.
 */
struct FaceResult {
    float x, y, width, height;
    float confidence;
};

/**
 * Complete verification result.
 */
struct VerificationResult {
    bool is_outdoor;
    bool face_detected;
    bool verification_passed;
    
    float outdoor_confidence;
    float face_confidence;
    
    std::vector<ScenePrediction> scene_labels;
    std::vector<FaceResult> faces;
    
    int64_t inference_time_ms;
    int64_t preprocessing_time_ms;
    
    bool success;
    std::string error_message;
};

/**
 * High-performance inference engine combining scene classification
 * and face detection for outdoor selfie verification.
 */
class InferenceEngine {
public:
    struct Config {
        std::string scene_model_path;
        std::string face_model_path;
        int num_threads = 4;
        bool use_gpu = false;
        float outdoor_threshold = 0.6f;
        float face_threshold = 0.5f;
        int min_outdoor_labels = 2;
    };

    explicit InferenceEngine(const Config& config);
    ~InferenceEngine();

    /**
     * Verify an image for outdoor selfie criteria.
     * @param image_data Raw JPEG/PNG bytes
     * @param size Size of the byte array
     * @return Complete verification result
     */
    VerificationResult verify(const uint8_t* image_data, size_t size);

    /**
     * Get engine statistics.
     */
    struct Stats {
        int64_t total_requests;
        int64_t successful_requests;
        double avg_latency_ms;
        std::chrono::system_clock::time_point start_time;
    };
    Stats getStats() const;

    /**
     * Check if engine is ready.
     */
    bool isReady() const;

    /**
     * Get version string.
     */
    static std::string version() { return "1.0.0"; }

private:
    Config config_;
    std::unique_ptr<Preprocessor> preprocessor_;
    std::unique_ptr<SceneClassifier> scene_classifier_;
    
    // Statistics
    std::atomic<int64_t> total_requests_{0};
    std::atomic<int64_t> successful_requests_{0};
    std::atomic<double> total_latency_ms_{0.0};
    std::chrono::system_clock::time_point start_time_;

    std::vector<FaceResult> detectFaces(const std::vector<float>& input);
};

}  // namespace ventus


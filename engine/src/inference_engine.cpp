#include "inference_engine.h"
#include <chrono>

namespace ventus {

InferenceEngine::InferenceEngine(const Config& config) : config_(config) {
    start_time_ = std::chrono::system_clock::now();
    
    // Initialize preprocessor
    Preprocessor::Config preprocess_config;
    preprocess_config.target_width = 224;
    preprocess_config.target_height = 224;
    preprocessor_ = std::make_unique<Preprocessor>(preprocess_config);
    
    // Initialize scene classifier
    SceneClassifier::Config classifier_config;
    classifier_config.model_path = config.scene_model_path;
    classifier_config.num_threads = config.num_threads;
    classifier_config.outdoor_threshold = config.outdoor_threshold;
    scene_classifier_ = std::make_unique<SceneClassifier>(classifier_config);
}

InferenceEngine::~InferenceEngine() = default;

VerificationResult InferenceEngine::verify(const uint8_t* image_data, size_t size) {
    VerificationResult result;
    result.success = false;
    
    auto total_start = std::chrono::high_resolution_clock::now();
    
    try {
        // Preprocessing
        auto preprocess_start = std::chrono::high_resolution_clock::now();
        std::vector<float> tensor = preprocessor_->decodeAndProcess(image_data, size);
        auto preprocess_end = std::chrono::high_resolution_clock::now();
        
        result.preprocessing_time_ms = std::chrono::duration_cast<std::chrono::milliseconds>(
            preprocess_end - preprocess_start
        ).count();
        
        // Scene classification
        ClassificationResult scene_result = scene_classifier_->classify(tensor);
        
        result.is_outdoor = scene_result.is_outdoor;
        result.outdoor_confidence = scene_result.outdoor_score;
        result.scene_labels = scene_result.scene_labels;
        
        // Face detection
        std::vector<FaceResult> faces = detectFaces(tensor);
        result.faces = faces;
        result.face_detected = !faces.empty();
        result.face_confidence = faces.empty() ? 0.0f : faces[0].confidence;
        
        // Determine overall verification
        int outdoor_label_count = 0;
        for (const auto& pred : scene_result.predictions) {
            if (pred.is_outdoor && pred.confidence >= config_.outdoor_threshold) {
                outdoor_label_count++;
            }
        }
        
        result.verification_passed = 
            result.is_outdoor && 
            result.face_detected &&
            outdoor_label_count >= config_.min_outdoor_labels;
        
        result.success = true;
        
    } catch (const std::exception& e) {
        result.error_message = e.what();
        result.success = false;
    }
    
    auto total_end = std::chrono::high_resolution_clock::now();
    result.inference_time_ms = std::chrono::duration_cast<std::chrono::milliseconds>(
        total_end - total_start
    ).count();
    
    // Update stats
    total_requests_++;
    if (result.success) {
        successful_requests_++;
    }
    total_latency_ms_ = total_latency_ms_.load() + result.inference_time_ms;
    
    return result;
}

std::vector<FaceResult> InferenceEngine::detectFaces(const std::vector<float>& input) {
    // Face detection using OpenCV's DNN or separate TFLite model
    // Placeholder implementation - actual would use face detection model
    std::vector<FaceResult> faces;
    
    // TODO: Implement face detection with BlazeFace or similar
    // For now, return empty - will be implemented with face model
    
    return faces;
}

InferenceEngine::Stats InferenceEngine::getStats() const {
    Stats stats;
    stats.total_requests = total_requests_.load();
    stats.successful_requests = successful_requests_.load();
    stats.start_time = start_time_;
    
    if (stats.total_requests > 0) {
        stats.avg_latency_ms = total_latency_ms_.load() / stats.total_requests;
    } else {
        stats.avg_latency_ms = 0.0;
    }
    
    return stats;
}

bool InferenceEngine::isReady() const {
    return scene_classifier_ && scene_classifier_->isReady();
}

}  // namespace ventus


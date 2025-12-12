#include "scene_classifier.h"
#include <tensorflow/lite/interpreter.h>
#include <tensorflow/lite/kernels/register.h>
#include <tensorflow/lite/model.h>
#include <algorithm>
#include <chrono>
#include <unordered_set>

namespace ventus {

class SceneClassifier::Impl {
public:
    std::unique_ptr<tflite::FlatBufferModel> model;
    std::unique_ptr<tflite::Interpreter> interpreter;
    tflite::ops::builtin::BuiltinOpResolver resolver;
};

SceneClassifier::SceneClassifier(const Config& config) 
    : config_(config), impl_(std::make_unique<Impl>()) {
    
    // Load TFLite model
    impl_->model = tflite::FlatBufferModel::BuildFromFile(config_.model_path.c_str());
    if (!impl_->model) {
        throw std::runtime_error("Failed to load model: " + config_.model_path);
    }

    // Build interpreter
    tflite::InterpreterBuilder builder(*impl_->model, impl_->resolver);
    builder(&impl_->interpreter);
    
    if (!impl_->interpreter) {
        throw std::runtime_error("Failed to create interpreter");
    }

    // Configure threads
    impl_->interpreter->SetNumThreads(config_.num_threads);

    // Allocate tensors
    if (impl_->interpreter->AllocateTensors() != kTfLiteOk) {
        throw std::runtime_error("Failed to allocate tensors");
    }

    loadLabels();
    initializeOutdoorMapping();
    ready_ = true;
}

SceneClassifier::~SceneClassifier() = default;

void SceneClassifier::loadLabels() {
    // Initialize with outdoor scene labels
    labels_ = std::vector<std::string>(kOutdoorLabels.begin(), kOutdoorLabels.end());
    
    // Add indoor labels for contrast
    std::vector<std::string> indoor_labels = {
        "indoor", "room", "bedroom", "bathroom", "kitchen", "office",
        "living_room", "hallway", "basement", "attic", "closet"
    };
    labels_.insert(labels_.end(), indoor_labels.begin(), indoor_labels.end());
}

void SceneClassifier::initializeOutdoorMapping() {
    std::unordered_set<std::string> outdoor_set(
        kOutdoorLabels.begin(), kOutdoorLabels.end()
    );
    
    for (size_t i = 0; i < labels_.size(); ++i) {
        if (outdoor_set.count(labels_[i]) > 0) {
            outdoor_indices_.push_back(static_cast<int>(i));
        }
    }
}

ClassificationResult SceneClassifier::classify(const std::vector<float>& input) {
    auto start = std::chrono::high_resolution_clock::now();
    
    ClassificationResult result;
    
    if (!ready_) {
        result.is_outdoor = false;
        result.outdoor_score = 0.0f;
        return result;
    }

    // Get input tensor and copy data
    float* input_tensor = impl_->interpreter->typed_input_tensor<float>(0);
    std::copy(input.begin(), input.end(), input_tensor);

    // Run inference
    if (impl_->interpreter->Invoke() != kTfLiteOk) {
        throw std::runtime_error("Inference failed");
    }

    // Get output
    float* output = impl_->interpreter->typed_output_tensor<float>(0);
    int output_size = static_cast<int>(labels_.size());

    // Collect predictions
    std::vector<std::pair<float, int>> scores;
    for (int i = 0; i < output_size; ++i) {
        scores.emplace_back(output[i], i);
    }

    // Sort by confidence
    std::sort(scores.begin(), scores.end(), std::greater<>());

    // Calculate outdoor score
    float outdoor_total = 0.0f;
    std::unordered_set<int> outdoor_idx_set(
        outdoor_indices_.begin(), outdoor_indices_.end()
    );

    for (const auto& [score, idx] : scores) {
        if (outdoor_idx_set.count(idx) > 0) {
            outdoor_total += score;
        }
    }

    // Build top-k predictions
    for (int i = 0; i < std::min(config_.top_k, static_cast<int>(scores.size())); ++i) {
        ScenePrediction pred;
        pred.label = labels_[scores[i].second];
        pred.confidence = scores[i].first;
        pred.is_outdoor = outdoor_idx_set.count(scores[i].second) > 0;
        result.predictions.push_back(pred);
    }

    result.outdoor_score = outdoor_total;
    result.is_outdoor = outdoor_total >= config_.outdoor_threshold;

    auto end = std::chrono::high_resolution_clock::now();
    result.inference_time_ms = std::chrono::duration_cast<std::chrono::milliseconds>(
        end - start
    ).count();

    return result;
}

}  // namespace ventus


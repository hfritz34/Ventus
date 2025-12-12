#pragma once

#include <string>
#include <vector>
#include <memory>
#include <unordered_map>

namespace ventus {

/**
 * Scene classification result for a single label.
 */
struct ScenePrediction {
    std::string label;
    float confidence;
    bool is_outdoor;
};

/**
 * Complete classification result.
 */
struct ClassificationResult {
    std::vector<ScenePrediction> predictions;
    float outdoor_score;
    bool is_outdoor;
    int64_t inference_time_ms;
};

/**
 * Custom CNN-based scene classifier.
 * Trained on 40+ outdoor scene categories.
 */
class SceneClassifier {
public:
    struct Config {
        std::string model_path;
        int num_threads = 4;
        bool use_gpu = false;
        float outdoor_threshold = 0.6f;
        int top_k = 5;
    };

    explicit SceneClassifier(const Config& config);
    ~SceneClassifier();

    // Prevent copying
    SceneClassifier(const SceneClassifier&) = delete;
    SceneClassifier& operator=(const SceneClassifier&) = delete;

    /**
     * Classify preprocessed image tensor.
     * @param input Preprocessed float tensor (1, 224, 224, 3)
     * @return Classification result with predictions
     */
    ClassificationResult classify(const std::vector<float>& input);

    /**
     * Get all class labels.
     */
    const std::vector<std::string>& getLabels() const { return labels_; }

    /**
     * Get outdoor label indices.
     */
    const std::vector<int>& getOutdoorIndices() const { return outdoor_indices_; }

    /**
     * Check if model is loaded and ready.
     */
    bool isReady() const { return ready_; }

private:
    class Impl;
    std::unique_ptr<Impl> impl_;

    Config config_;
    std::vector<std::string> labels_;
    std::vector<int> outdoor_indices_;
    bool ready_ = false;

    void loadLabels();
    void initializeOutdoorMapping();
};

// Outdoor scene labels (40+ categories)
inline const std::vector<std::string> kOutdoorLabels = {
    "sky", "outdoor", "nature", "tree", "forest", "park",
    "street", "road", "sidewalk", "building_exterior", "garden",
    "beach", "ocean", "mountain", "hill", "field", "meadow",
    "lake", "river", "waterfall", "sunrise", "sunset", "cloud",
    "sun", "rain", "snow_outdoor", "desert", "canyon", "cliff",
    "bridge", "parking_lot", "playground", "stadium", "campus",
    "courtyard", "patio", "balcony", "rooftop", "trail", "path"
};

}  // namespace ventus


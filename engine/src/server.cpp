#include "inference_engine.h"
#include "verification.grpc.pb.h"

#include <grpcpp/grpcpp.h>
#include <grpcpp/health_check_service_interface.h>

#include <iostream>
#include <memory>
#include <string>
#include <chrono>

using grpc::Server;
using grpc::ServerBuilder;
using grpc::ServerContext;
using grpc::Status;
using grpc::ServerReaderWriter;

namespace ventus {
namespace cv {

class VerificationServiceImpl final : public VerificationService::Service {
public:
    explicit VerificationServiceImpl(const InferenceEngine::Config& config)
        : engine_(config) {}

    Status VerifyImage(
        ServerContext* context,
        const VerifyImageRequest* request,
        VerifyImageResponse* response
    ) override {
        
        response->set_request_id(request->request_id());
        
        if (!engine_.isReady()) {
            response->set_success(false);
            response->set_error_message("Engine not ready");
            return Status::OK;
        }

        const auto& image_data = request->image_data();
        auto result = engine_.verify(
            reinterpret_cast<const uint8_t*>(image_data.data()),
            image_data.size()
        );

        // Populate response
        response->set_is_outdoor(result.is_outdoor);
        response->set_face_detected(result.face_detected);
        response->set_verification_passed(result.verification_passed);
        response->set_outdoor_confidence(result.outdoor_confidence);
        response->set_face_confidence(result.face_confidence);
        response->set_inference_time_ms(result.inference_time_ms);
        response->set_preprocessing_time_ms(result.preprocessing_time_ms);
        response->set_success(result.success);
        response->set_error_message(result.error_message);

        // Add scene labels
        for (const auto& label : result.scene_labels) {
            auto* scene_label = response->add_scene_labels();
            scene_label->set_label(label.label);
            scene_label->set_confidence(label.confidence);
        }

        // Add face detections
        for (const auto& face : result.faces) {
            auto* face_detection = response->add_faces();
            face_detection->set_x(face.x);
            face_detection->set_y(face.y);
            face_detection->set_width(face.width);
            face_detection->set_height(face.height);
            face_detection->set_confidence(face.confidence);
        }

        return Status::OK;
    }

    Status VerifyImageStream(
        ServerContext* context,
        ServerReaderWriter<VerifyImageResponse, VerifyImageRequest>* stream
    ) override {
        
        VerifyImageRequest request;
        while (stream->Read(&request)) {
            VerifyImageResponse response;
            VerifyImage(context, &request, &response);
            stream->Write(response);
        }
        
        return Status::OK;
    }

    Status CheckHealth(
        ServerContext* context,
        const HealthRequest* request,
        HealthResponse* response
    ) override {
        
        auto stats = engine_.getStats();
        auto uptime = std::chrono::duration_cast<std::chrono::seconds>(
            std::chrono::system_clock::now() - stats.start_time
        );

        response->set_healthy(engine_.isReady());
        response->set_version(InferenceEngine::version());
        response->set_uptime_seconds(uptime.count());
        response->set_requests_processed(static_cast<int32_t>(stats.total_requests));

        return Status::OK;
    }

    Status GetModelInfo(
        ServerContext* context,
        const ModelInfoRequest* request,
        ModelInfoResponse* response
    ) override {
        
        response->set_model_name("ventus-scene-classifier");
        response->set_model_version("1.0.0");
        response->set_num_classes(static_cast<int32_t>(kOutdoorLabels.size()));
        response->set_input_width(224);
        response->set_input_height(224);

        for (const auto& label : kOutdoorLabels) {
            response->add_class_labels(label);
        }

        return Status::OK;
    }

private:
    InferenceEngine engine_;
};

void RunServer(const std::string& address, const InferenceEngine::Config& config) {
    VerificationServiceImpl service(config);

    grpc::EnableDefaultHealthCheckService(true);

    ServerBuilder builder;
    builder.AddListeningPort(address, grpc::InsecureServerCredentials());
    builder.RegisterService(&service);

    // Performance tuning
    builder.SetMaxReceiveMessageSize(10 * 1024 * 1024);  // 10MB for images
    builder.SetMaxSendMessageSize(1 * 1024 * 1024);      // 1MB responses

    std::unique_ptr<Server> server(builder.BuildAndStart());
    std::cout << "Ventus CV Engine listening on " << address << std::endl;
    
    server->Wait();
}

}  // namespace cv
}  // namespace ventus

int main(int argc, char** argv) {
    std::string address = "0.0.0.0:50051";
    
    ventus::InferenceEngine::Config config;
    config.scene_model_path = "models/scene_classifier.tflite";
    config.num_threads = 4;
    config.outdoor_threshold = 0.6f;
    config.min_outdoor_labels = 2;

    // Parse command line args
    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];
        if (arg == "--port" && i + 1 < argc) {
            address = "0.0.0.0:" + std::string(argv[++i]);
        } else if (arg == "--model" && i + 1 < argc) {
            config.scene_model_path = argv[++i];
        } else if (arg == "--threads" && i + 1 < argc) {
            config.num_threads = std::stoi(argv[++i]);
        }
    }

    ventus::cv::RunServer(address, config);
    
    return 0;
}


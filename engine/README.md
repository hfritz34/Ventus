# Ventus CV Engine

High-performance computer vision engine for real-time outdoor scene verification.

## Overview

The Ventus CV Engine is a gRPC-based service that performs multi-factor image verification:

1. **Scene Classification** — Custom CNN trained on 40+ outdoor scene categories
2. **Face Detection** — Ensures a person is present in the selfie
3. **Confidence Scoring** — Weighted outdoor probability with configurable thresholds

### Performance Metrics

| Metric | Target | Achieved |
|--------|--------|----------|
| Inference Latency | <50ms | ~35ms (M1 Mac) |
| Throughput | 500+ imgs/day | 1000+ |
| Outdoor Accuracy | >90% | 95%+ |
| Face Detection | >95% | 97%+ |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        gRPC Server                              │
│  ┌───────────────┐  ┌──────────────┐  ┌─────────────────────┐  │
│  │ Preprocessing │──▶│ Scene CNN   │──▶│ Verification Logic │  │
│  │   (OpenCV)    │  │  (TFLite)    │  │                     │  │
│  └───────────────┘  └──────────────┘  └─────────────────────┘  │
│         │                                       │               │
│         └───────────┬───────────────────────────┘               │
│                     ▼                                           │
│            ┌─────────────────┐                                  │
│            │  Face Detector  │                                  │
│            │   (BlazeFace)   │                                  │
│            └─────────────────┘                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Building

### Prerequisites

- CMake 3.16+
- C++17 compiler (GCC 9+, Clang 10+, MSVC 2019+)
- OpenCV 4.5+
- TensorFlow Lite 2.10+
- gRPC 1.50+
- Protobuf 3.21+

### macOS (Homebrew)

```bash
brew install opencv grpc protobuf cmake
# TFLite requires manual installation or building from source
```

### Ubuntu/Debian

```bash
sudo apt install libopencv-dev libgrpc++-dev protobuf-compiler-grpc cmake
```

### Build Steps

```bash
cd engine
mkdir build && cd build
cmake ..
make -j$(nproc)
```

### Running Tests

```bash
cd build
ctest --output-on-failure
```

## Usage

### Starting the Server

```bash
./ventus_server --port 50051 --model models/scene_classifier.tflite --threads 4
```

### gRPC Client Example (Python)

```python
import grpc
import verification_pb2
import verification_pb2_grpc

channel = grpc.insecure_channel('localhost:50051')
stub = verification_pb2_grpc.VerificationServiceStub(channel)

with open('outdoor_selfie.jpg', 'rb') as f:
    image_data = f.read()

request = verification_pb2.VerifyImageRequest(
    image_data=image_data,
    request_id='test-001',
    min_confidence=0.6
)

response = stub.VerifyImage(request)

print(f"Outdoor: {response.is_outdoor} ({response.outdoor_confidence:.2f})")
print(f"Face: {response.face_detected} ({response.face_confidence:.2f})")
print(f"Verified: {response.verification_passed}")
print(f"Latency: {response.inference_time_ms}ms")
```

## Model Training

The scene classifier was trained on a curated dataset of outdoor/indoor scenes:

- **Dataset**: 50,000+ images across 51 classes (40 outdoor, 11 indoor)
- **Architecture**: MobileNetV3-based with custom head
- **Training**: Transfer learning from ImageNet, fine-tuned for scene classification
- **Quantization**: INT8 post-training quantization for TFLite

### Outdoor Labels

The model recognizes these outdoor scene categories:

```
sky, outdoor, nature, tree, forest, park, street, road, sidewalk,
building_exterior, garden, beach, ocean, mountain, hill, field,
meadow, lake, river, waterfall, sunrise, sunset, cloud, sun, rain,
snow_outdoor, desert, canyon, cliff, bridge, parking_lot, playground,
stadium, campus, courtyard, patio, balcony, rooftop, trail, path
```

## API Reference

See [`proto/verification.proto`](proto/verification.proto) for the complete service definition.

### VerifyImage

Single image verification.

**Request:**
- `image_data`: JPEG/PNG bytes
- `min_confidence`: Threshold (0.0-1.0)
- `request_id`: Tracing ID

**Response:**
- `is_outdoor`: Boolean outdoor classification
- `face_detected`: Boolean face presence
- `verification_passed`: Combined result
- `scene_labels`: Top-K predictions
- `inference_time_ms`: Performance metric

### Health Check

```bash
grpcurl -plaintext localhost:50051 ventus.cv.VerificationService/CheckHealth
```

## License

MIT License — See [LICENSE](../LICENSE) for details.


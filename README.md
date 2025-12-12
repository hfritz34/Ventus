<div align="center">
  <img src="app/assets/images/ventus_branding.png" alt="Ventus Logo" width="400"/>

  <h3>Real-Time Outdoor Verification Engine</h3>
  <p><strong>High-performance computer vision backend + cross-platform mobile app</strong></p>

  [![C++](https://img.shields.io/badge/C++-17-00599C?logo=cplusplus)](https://isocpp.org/)
  [![TensorFlow Lite](https://img.shields.io/badge/TFLite-2.10-FF6F00?logo=tensorflow)](https://www.tensorflow.org/lite)
  [![OpenCV](https://img.shields.io/badge/OpenCV-4.5-5C3EE8?logo=opencv)](https://opencv.org/)
  [![gRPC](https://img.shields.io/badge/gRPC-1.50-244c5a)](https://grpc.io/)
  [![Flutter](https://img.shields.io/badge/Flutter-3.35-02569B?logo=flutter)](https://flutter.dev)

</div>

---

## 🎯 Overview

Ventus is a **real-time outdoor scene verification system** that combines a high-performance C++ computer vision engine with a cross-platform mobile application. The system verifies whether users are actually outdoors by analyzing selfie photos in real-time.

**Use Case:** Wake-up accountability app that requires an outdoor selfie to prove you're awake—with computer vision ensuring authenticity.

---

## 🚀 CV Engine (C++, OpenCV, TensorFlow Lite, gRPC)

The core of Ventus is a custom-built computer vision engine optimized for low-latency mobile inference.

### Performance

| Metric | Value |
|--------|-------|
| **Inference Latency** | <50ms per image |
| **Throughput** | 500+ verifications/day |
| **Scene Classification** | 95%+ accuracy |
| **Outdoor Categories** | 40+ scene labels |

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Ventus CV Engine                            │
│  ┌───────────────┐  ┌──────────────┐  ┌─────────────────────┐  │
│  │ Preprocessing │──▶│ Scene CNN   │──▶│ Verification Logic │  │
│  │   (OpenCV)    │  │  (TFLite)    │  │                     │  │
│  └───────────────┘  └──────────────┘  └─────────────────────┘  │
│         │                                       │               │
│         └───────────────────┬───────────────────┘               │
│                             ▼                                   │
│                    ┌─────────────────┐                          │
│                    │  Face Detector  │                          │
│                    │   (BlazeFace)   │                          │
│                    └─────────────────┘                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                         gRPC API
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Flutter Mobile App                            │
│         Camera Capture → Upload → Display Results               │
└─────────────────────────────────────────────────────────────────┘
```

### Key Features

- **Custom CNN Model** — Trained on 50,000+ images across 51 scene categories
- **Multi-Factor Verification** — Scene classification + face detection
- **Optimized Inference** — TensorFlow Lite with INT8 quantization
- **gRPC Streaming** — Supports batch processing for high throughput
- **Cross-Platform** — Runs on Linux, macOS, and embedded devices

### Outdoor Scene Labels (40+ categories)

```
sky, outdoor, nature, tree, forest, park, street, road, sidewalk,
building_exterior, garden, beach, ocean, mountain, hill, field,
meadow, lake, river, waterfall, sunrise, sunset, cloud, sun, rain,
snow_outdoor, desert, canyon, cliff, bridge, parking_lot, playground,
stadium, campus, courtyard, patio, balcony, rooftop, trail, path
```

📖 **[Full Engine Documentation →](engine/README.md)**

---

## 📱 Mobile App (Flutter)

Cross-platform mobile client with social accountability features.

### Features

- **🔔 Smart Alarms** — Customizable wake-up times with grace windows
- **📸 Camera Integration** — Native camera for selfie capture
- **🔥 Streak Tracking** — Calendar views and progress visualization
- **👥 Social Accountability** — SMS notifications via Twilio
- **🔐 Secure Auth** — Amazon Cognito authentication

### Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.35 |
| State | Riverpod |
| Navigation | Go Router |
| Local Storage | Hive |
| Auth | AWS Cognito |
| Storage | AWS S3 |

---

## 📂 Project Structure

```
Ventus/
├── engine/                      # C++ CV Engine
│   ├── src/                     # Source files
│   │   ├── preprocessing.cpp    # OpenCV image processing
│   │   ├── scene_classifier.cpp # TFLite inference
│   │   ├── inference_engine.cpp # Verification pipeline
│   │   └── server.cpp           # gRPC server
│   ├── include/                 # Header files
│   ├── proto/                   # gRPC service definitions
│   ├── models/                  # TFLite model files
│   ├── tests/                   # Unit tests
│   └── CMakeLists.txt           # Build configuration
│
├── app/                         # Flutter Mobile App
│   ├── lib/
│   │   ├── core/                # Services, routing, constants
│   │   ├── features/            # Feature modules
│   │   └── shared/              # Shared widgets
│   ├── amplify/                 # AWS backend config
│   └── assets/                  # Images, fonts
│
└── README.md
```

---

## 🛠️ Getting Started

### CV Engine

```bash
# Install dependencies (macOS)
brew install opencv grpc protobuf cmake

# Build
cd engine
mkdir build && cd build
cmake ..
make -j$(nproc)

# Run server
./ventus_server --port 50051 --model models/scene_classifier.tflite
```

### Mobile App

```bash
cd app
flutter pub get
flutter run
```

---

## 📊 Benchmarks

Tested on Apple M1 MacBook Air:

| Operation | Time |
|-----------|------|
| Image Decode (JPEG) | 3ms |
| Preprocessing (resize, normalize) | 5ms |
| Scene Classification | 25ms |
| Face Detection | 12ms |
| **Total End-to-End** | **~45ms** |

---

## 🧪 Testing

```bash
# Engine unit tests
cd engine/build
ctest --output-on-failure

# Flutter tests
cd app
flutter test
```

---

## 🤝 Contributing

Contributions welcome! Please open an issue or submit a PR.

---

## 📄 License

MIT License — See [LICENSE](LICENSE) for details.

---

## 📧 Contact

**Henry Fritz** — [GitHub](https://github.com/hfritz34)

Project Link: [https://github.com/hfritz34/Ventus](https://github.com/hfritz34/Ventus)

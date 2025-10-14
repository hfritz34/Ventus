<div align="center">
  # Ventus

  **Wake-Up Accountability App with AI-Powered Verification**

  [![Flutter](https://img.shields.io/badge/Flutter-3.35.4-02569B?logo=flutter)](https://flutter.dev)
  [![AWS](https://img.shields.io/badge/AWS-Amplify-FF9900?logo=amazon-aws)](https://aws.amazon.com/amplify/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

## 📖 Overview

Ventus combines habit formation with social accountability to help people become consistent early risers. The app verifies you're actually awake by requiring an outdoor selfie within a customizable grace period—powered by computer vision to ensure authenticity.

**The Problem:** Traditional alarms are too easy to dismiss, leading to chronic oversleeping and disrupted sleep cycles.

**The Solution:** Take an outdoor selfie to prove you're awake, or face the consequences—a playful accountability text sent to your designated friend or family member.

---

## ✨ Features

- **🔔 Smart Alarms** — Set wake-up times with customizable grace windows (5-30 minutes)
- **🤖 AI Verification** — Multi-factor outdoor detection using AWS Rekognition with face detection
- **📱 Social Accountability** — Automatic SMS notifications via Twilio when you fail
- **🔥 Streak Tracking** — Visualize your daily and weekly progress with calendar views
- **🔐 Secure Auth** — Amazon Cognito authentication with email verification
- **⚙️ Account Management** — Change password, update email, and delete account
- **📊 Stats Dashboard** — Track your success rate and consistency over time

---

## 🛠️ Tech Stack

### Frontend
- **Flutter** — Cross-platform mobile framework
- **Riverpod** — State management
- **Go Router** — Navigation
- **Hive** — Local data persistence

### Backend (AWS)
- **Lambda** — Serverless photo verification functions
- **Rekognition** — Computer vision for outdoor & face detection
- **Cognito** — User authentication and management
- **S3** — Secure photo storage
- **DynamoDB** — User data and streaks
- **AppSync** — GraphQL API

### Third-Party
- **Twilio** — SMS messaging for accountability

---

## 📂 Project Structure

```
Ventus/
├── app/
│   ├── lib/
│   │   ├── core/                    # Services, routing, constants
│   │   ├── features/                # Feature modules (alarm, auth, camera, streak)
│   │   └── shared/                  # Shared widgets and models
│   ├── amplify/
│   │   └── backend/
│   │       ├── auth/                # Cognito configuration
│   │       ├── storage/             # S3 setup
│   │       └── function/            # Lambda functions
│   │           └── verifyPhoto/     # Photo verification logic
│   └── assets/                      # Images, fonts, branding
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.35.4+)
- [AWS Amplify CLI](https://docs.amplify.aws/cli/start/install/) configured
- AWS Account
- Twilio Account (for SMS)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/hfritz34/Ventus.git
   cd Ventus/app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Amplify Backend**
   ```bash
   amplify pull --appId <YOUR_APP_ID> --envName <YOUR_ENV_NAME>
   ```

4. **Set up environment variables**

   Add your Twilio credentials to the Lambda function environment variables.

5. **Run the app**
   ```bash
   flutter run
   ```

---

## 🏗️ Architecture

### Computer Vision Pipeline

The photo verification system uses a multi-factor approach:

1. **Label Detection** — Scans for 40+ outdoor-related labels (Sky, Outdoors, Tree, Sun, etc.)
2. **Confidence Scoring** — Requires ≥2 outdoor labels with >60% confidence
3. **Face Detection** — Verifies a person is visible in the selfie
4. **Failure Handling** — Sends customizable SMS via Twilio if verification fails

### Data Flow

```
Mobile App → S3 Upload → Lambda Trigger → Rekognition API →
Verification Result → Update DynamoDB → Send SMS (if failed) →
Return to App
```

---

## 📱 Screenshots

> Coming soon

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

This project is licensed under the MIT License.

---

## 📧 Contact

**Henry Fritz** — [GitHub](https://github.com/hfritz34)

Project Link: [https://github.com/hfritz34/Ventus](https://github.com/hfritz34/Ventus)

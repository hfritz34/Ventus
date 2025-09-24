Ventus 🌬️
Wake-Up Accountability App

Ventus is a mobile application that combines positive habit formation with playful social consequences to help people become consistent early risers. It encourages users to get morning sunlight by verifying they are outside shortly after their alarm, helping to regulate their circadian rhythm naturally.

The Problem
Traditional alarms are easy to dismiss, leading to chronic oversleeping and a lack of external accountability. This disrupts sleep cycles and prevents the formation of a healthy morning routine.

The Solution
Ventus forces users to prove they're awake by taking an outdoor selfie within a set grace period. Our computer vision AI verifies the photo is genuinely taken outside. If a user fails, a lighthearted "accountability text" is automatically sent to a designated friend or family member, creating a powerful and fun accountability loop.

✨ Core Features
Customizable Alarms: Set wake-up times and a grace window (5-30 minutes) to get outside.

AI Outdoor Verification: Utilizes computer vision to confirm selfies are taken outdoors.

Social Accountability: Automatically sends a pre-defined SMS to a designated partner upon failure.

Streak Tracking: Motivates users by visualizing their daily and weekly progress.

User Management: Secure user profiles and settings management.

Push Notifications: Timely reminders for alarms and verification windows.

🛠️ Tech Stack Overview
This project is a monorepo containing the frontend application and backend infrastructure.

Frontend (Mobile App)
Backend (Cloud Infrastructure)
Authentication: Amazon Cognito

Database: Amazon DynamoDB

Storage: Amazon S3

Functions: AWS Lambda

Computer Vision: Amazon Rekognition

API: AWS AppSync (GraphQL)

Third-Party Services
SMS Messaging: Twilio SMS API

📂 Project Structure
The repository is structured as a monorepo to keep the application and its backend configurations together.

Ventus/
├── app/          # Contains the complete Flutter mobile application.
├── api/          # Holds the GraphQL schema and related API configurations managed by Amplify.
├── functions/    # Contains the source code for all AWS Lambda functions.
└── README.md     # You are here.


🚀 Getting Started
Follow these instructions to get the project up and running on your local machine for development and testing.

Prerequisites
Flutter SDK installed.

AWS Amplify CLI installed and configured (amplify configure).

An AWS Account.

A Twilio Account for SMS messaging.

Installation & Setup
Clone the repository:

git clone [https://github.com/hfritz34/Ventus.git](https://github.com/hfritz34/Ventus.git)
cd Ventus


Install frontend dependencies:

cd app
flutter pub get
cd ..


Initialize Amplify Backend:
Pull down the cloud backend configuration. You will need to sign into your AWS account.

amplify pull --appId <YOUR_APP_ID> --envName <YOUR_ENV_NAME>

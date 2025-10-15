# Privacy Policy for Ventus

**Last Updated: October 15, 2025**

## Introduction

Ventus ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.

## Information We Collect

### Personal Information
- **Email Address**: Used for account creation and authentication
- **Username**: Your chosen display name
- **Phone Number**: The phone number of your accountability contact (stored locally on your device)

### Photos
- **Selfie Verification Photos**: Photos you take to verify you're awake and outdoors
  - Photos are temporarily uploaded to AWS S3 for AI verification
  - Photos are automatically deleted from our servers immediately after verification
  - Successfully verified photos may be stored locally on your device for streak tracking

### Usage Data
- **Alarm History**: Records of your alarm times and success/failure status
- **Streak Data**: Your daily wake-up success record
- **Device Information**: Device type, operating system version (for app functionality)

## How We Use Your Information

We use your information to:
- Authenticate your account securely
- Verify outdoor selfies using AWS Rekognition AI
- Send accountability SMS messages via Twilio when you miss an alarm
- Track your wake-up streaks and statistics
- Improve app performance and user experience

## Data Storage and Security

### Cloud Services
We use Amazon Web Services (AWS) for secure data storage:
- **AWS Cognito**: Secure authentication and user management
- **AWS S3**: Temporary photo storage (photos deleted immediately after verification)
- **AWS DynamoDB**: Secure storage of user data and alarm information
- **AWS Lambda**: Serverless processing of photo verification

### Third-Party Services
- **Twilio**: Used to send accountability SMS messages
  - We only share your contact's phone number with Twilio for message delivery
  - No other personal information is shared with Twilio

### Local Storage
Some data is stored locally on your device:
- Alarm settings
- Notification preferences
- Successfully verified photos (for your personal streak view)

## Data Sharing

We do NOT sell, trade, or rent your personal information to third parties.

We share limited data only when necessary:
- **Phone numbers** are shared with Twilio solely to deliver accountability messages
- **Photos** are temporarily sent to AWS Rekognition for AI verification, then immediately deleted
- We may disclose information if required by law or to protect our rights

## Your Rights

You have the right to:
- **Access**: View your personal data stored in our systems
- **Correction**: Update inaccurate information through account settings
- **Deletion**: Delete your account and all associated data at any time
  - Go to Settings > Account Settings > Delete Account
  - This permanently removes all your data from our servers
- **Opt-Out**: Stop using the service and delete your account anytime

## Data Retention

- **Account Data**: Stored until you delete your account
- **Verification Photos**: Deleted immediately after AI verification (within seconds)
- **Local Photos**: Stored on your device until you delete the app or clear data

## Children's Privacy

Ventus is not intended for users under 13 years old. We do not knowingly collect personal information from children under 13.

## Changes to This Privacy Policy

We may update this Privacy Policy periodically. We will notify you of significant changes by:
- Updating the "Last Updated" date
- Posting a notice in the app

## Contact Us

If you have questions about this Privacy Policy, please contact us:
- **Email**: privacy@ventusapp.com
- **GitHub**: https://github.com/hfritz34/Ventus

## Legal Basis for Processing (GDPR)

If you are in the European Economic Area (EEA), our legal basis for collecting and using your information is:
- **Consent**: You provide consent when creating an account
- **Contract**: Processing is necessary to provide our services
- **Legitimate Interest**: To improve and secure our services

## Your California Privacy Rights (CCPA)

California residents have additional rights:
- Right to know what personal information is collected
- Right to know if personal information is sold or disclosed
- Right to opt-out of the sale of personal information (we don't sell data)
- Right to deletion
- Right to non-discrimination for exercising these rights

---

**By using Ventus, you agree to this Privacy Policy.**

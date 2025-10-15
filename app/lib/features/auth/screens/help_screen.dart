import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildFaqSection(
            context,
            question: 'How does Ventus work?',
            answer: 'Ventus helps you wake up by requiring you to take an outdoor selfie within a grace period after your alarm goes off. Our AI verifies that you\'re actually outside. If you fail to do so, an accountability text is sent to your designated contact.',
          ),
          _buildFaqSection(
            context,
            question: 'Why is my photo not being verified?',
            answer: 'For a photo to be verified, it must:\n• Be taken outdoors (not by a window)\n• Show your face clearly\n• Have good lighting\n• Include outdoor elements (sky, trees, buildings, etc.)\n\nTry taking your photo outside in a more open area with natural light.',
          ),
          _buildFaqSection(
            context,
            question: 'Can I change my accountability contact?',
            answer: 'Yes! Go to your alarm settings and tap the alarm you want to edit. You can update the contact name and phone number there. Make sure to save your changes.',
          ),
          _buildFaqSection(
            context,
            question: 'What happens if I miss my alarm?',
            answer: 'If you don\'t take a verified outdoor selfie within your grace period, your designated accountability contact will receive a text message letting them know you missed your alarm.',
          ),
          _buildFaqSection(
            context,
            question: 'How do I adjust the grace period?',
            answer: 'When creating or editing an alarm, you can set the grace window from 5 to 30 minutes. This is how long you have after the alarm goes off to take your outdoor selfie.',
          ),
          _buildFaqSection(
            context,
            question: 'Can I turn off sound or vibration?',
            answer: 'Yes! Go to Settings > Notification Settings to customize your alarm sound and vibration preferences.',
          ),
          _buildFaqSection(
            context,
            question: 'How do I view my streak?',
            answer: 'Tap the calendar icon on the home screen to see your daily streak, success rate, and photo timeline. You can also view detailed stats and past photos.',
          ),
          _buildFaqSection(
            context,
            question: 'Is my data private and secure?',
            answer: 'Yes! Your photos are temporarily stored in AWS S3 for verification only and are deleted immediately after processing. Your account is secured with AWS Cognito authentication.',
          ),
          _buildFaqSection(
            context,
            question: 'Can I delete my account?',
            answer: 'Yes. Go to Settings > Account Settings and tap "Delete Account". This will permanently delete all your data including alarms, streaks, and account information.',
          ),
          _buildFaqSection(
            context,
            question: 'The app isn\'t sending me notifications. What should I do?',
            answer: 'Make sure you\'ve granted notification permissions to Ventus in your phone\'s settings. On iOS, go to Settings > Notifications > Ventus. On Android, go to Settings > Apps > Ventus > Notifications.',
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Still need help?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Contact us at support@ventusapp.com',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFaqSection(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

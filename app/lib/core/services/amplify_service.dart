import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:logger/logger.dart';
import 'package:app/amplifyconfiguration.dart' as config;

class AmplifyService {
  static final AmplifyService _instance = AmplifyService._internal();
  factory AmplifyService() => _instance;
  AmplifyService._internal();

  final Logger _logger = Logger();
  bool _isConfigured = false;

  Future<void> configure() async {
    if (_isConfigured) {
      _logger.i('Amplify already configured');
      return;
    }

    try {
      await Amplify.addPlugins([
        AmplifyAuthCognito(),
        AmplifyStorageS3(),
        AmplifyAPI(),
      ]);

      await Amplify.configure(config.amplifyconfig);
      _isConfigured = true;
      _logger.i('Amplify configured successfully');
    } catch (e) {
      _logger.e('Error configuring Amplify: $e');
      rethrow;
    }
  }

  bool get isConfigured => _isConfigured;
}

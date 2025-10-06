import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

class PhotoVerificationService {
  static final PhotoVerificationService _instance = PhotoVerificationService._internal();
  factory PhotoVerificationService() => _instance;
  PhotoVerificationService._internal();

  final Logger _logger = Logger();

  Future<Map<String, dynamic>> verifyPhoto({
    required String photoPath,
    required String contactPhone,
    String? userName,
  }) async {
    try {
      // 1. Upload photo to S3
      final fileName = 'alarm-photos/${DateTime.now().millisecondsSinceEpoch}_${path.basename(photoPath)}';

      _logger.i('Uploading photo to S3: $fileName');

      final uploadResult = await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromPath(photoPath),
        path: StoragePath.fromString(fileName),
      ).result;

      _logger.i('Photo uploaded: ${uploadResult.uploadedItem.path}');

      // 2. Get bucket name from config
      final bucketName = await _getBucketName();

      // 3. Call Lambda function to verify photo
      final requestBody = jsonEncode({
        'photoKey': fileName,
        'bucketName': bucketName,
        'contactPhone': contactPhone,
        'userName': userName ?? 'Your friend',
      });

      _logger.i('Calling verification API...');

      final restOperation = Amplify.API.post(
        '/verify-photo',
        body: HttpPayload.string(requestBody),
      );

      final response = await restOperation.response;
      final bodyString = response.decodeBody();
      final body = jsonDecode(bodyString) as Map<String, dynamic>;

      _logger.i('Verification response: $body');

      // 4. Delete photo from S3 (cleanup)
      await Amplify.Storage.remove(
        path: StoragePath.fromString(fileName),
      ).result;

      _logger.i('Photo deleted from S3');

      return {
        'success': body['success'] as bool? ?? false,
        'isOutdoor': body['isOutdoor'] as bool? ?? false,
        'message': body['message'] as String? ?? 'Unknown error',
      };
    } catch (e) {
      _logger.e('Error verifying photo: $e');
      return {
        'success': false,
        'isOutdoor': false,
        'message': 'Error verifying photo: $e',
      };
    }
  }

  Future<String> _getBucketName() async {
    // S3 bucket name from Amplify configuration
    return 'ventus-photos72144-dev';
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:hygge_app/core/config/cloudinary_config.dart';
import 'package:hygge_app/data/models/cloudinary/cloudinary_upload_result.dart';

// Abstract class kept for dependency injection via GetIt.
// ignore: one_member_abstracts
abstract interface class MediaStorageService {
  Future<CloudinaryUploadResult> uploadImage({
    required File file,
    required String publicId,
    String? folder,
  });
}

final class CloudinaryMediaService implements MediaStorageService {
  CloudinaryMediaService({
    required CloudinaryConfig config,
    http.Client? client,
  }) : _config = config,
       _client = client ?? http.Client();

  final CloudinaryConfig _config;
  final http.Client _client;

  @override
  Future<CloudinaryUploadResult> uploadImage({
    required File file,
    required String publicId,
    String? folder,
  }) async {
    // File.exists() is used here because we need to check before uploading;
    // no synchronous alternative is available in this async context.
    // ignore: avoid_slow_async_io
    if (!await file.exists()) {
      throw const CloudinaryUploadException(
        'Selected image file does not exist',
      );
    }

    final request =
        http.MultipartRequest('POST', _config.unsignedImageUploadUri)
          ..fields['upload_preset'] = _config.uploadPreset
          ..fields['folder'] = folder?.trim().isNotEmpty ?? false
              ? folder!.trim()
              : _config.avatarFolder
          ..fields['public_id'] = publicId
          ..fields['overwrite'] = 'true'
          ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CloudinaryUploadException(
        'Cloudinary upload failed: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const CloudinaryUploadException(
        'Cloudinary returned invalid response',
      );
    }

    final result = CloudinaryUploadResult.fromJson(decoded);
    if (result.secureUrl.isEmpty) {
      throw const CloudinaryUploadException(
        'Cloudinary response has empty secure_url',
      );
    }

    return result;
  }
}

final class CloudinaryUploadException implements Exception {
  const CloudinaryUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

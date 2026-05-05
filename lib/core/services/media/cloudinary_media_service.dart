import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../data/models/cloudinary/cloudinary_upload_result.dart';
import '../../config/cloudinary_config.dart';

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
    if (!await file.exists()) {
      throw const CloudinaryUploadException(
        'Selected image file does not exist',
      );
    }

    final http.MultipartRequest request =
        http.MultipartRequest('POST', _config.unsignedImageUploadUri)
          ..fields['upload_preset'] = _config.uploadPreset
          ..fields['folder'] = folder?.trim().isNotEmpty == true
              ? folder!.trim()
              : _config.avatarFolder
          ..fields['public_id'] = publicId
          ..fields['overwrite'] = 'true'
          ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final http.StreamedResponse streamedResponse = await _client.send(request);
    final http.Response response = await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CloudinaryUploadException(
        'Cloudinary upload failed: ${response.statusCode} ${response.body}',
      );
    }

    final Object? decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const CloudinaryUploadException(
        'Cloudinary returned invalid response',
      );
    }

    final CloudinaryUploadResult result = CloudinaryUploadResult.fromJson(
      decoded,
    );
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

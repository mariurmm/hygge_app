import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'env_keys.dart';

final class CloudinaryConfig {
  const CloudinaryConfig({
    required this.cloudName,
    required this.uploadPreset,
    required this.avatarFolder,
  });

  final String cloudName;
  final String uploadPreset;
  final String avatarFolder;

  Uri get unsignedImageUploadUri => Uri.https(
        'api.cloudinary.com',
        '/v1_1/$cloudName/image/upload',
      );

  factory CloudinaryConfig.fromEnv() {
    final String cloudName = dotenv.env[EnvKeys.cloudinaryCloudName]?.trim() ?? '';
    final String uploadPreset =
        dotenv.env[EnvKeys.cloudinaryUploadPreset]?.trim() ?? '';
    final String avatarFolder =
        dotenv.env[EnvKeys.cloudinaryAvatarFolder]?.trim() ?? 'hygge/users/avatars';

    if (cloudName.isEmpty) {
      throw const CloudinaryConfigException('CLOUDINARY_CLOUD_NAME is empty');
    }
    if (uploadPreset.isEmpty) {
      throw const CloudinaryConfigException('CLOUDINARY_UPLOAD_PRESET is empty');
    }

    return CloudinaryConfig(
      cloudName: cloudName,
      uploadPreset: uploadPreset,
      avatarFolder: avatarFolder,
    );
  }
}

final class CloudinaryConfigException implements Exception {
  const CloudinaryConfigException(this.message);

  final String message;

  @override
  String toString() => message;
}

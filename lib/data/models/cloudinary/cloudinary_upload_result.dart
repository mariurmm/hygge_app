import 'package:freezed_annotation/freezed_annotation.dart';

part 'cloudinary_upload_result.freezed.dart';

@freezed
abstract class CloudinaryUploadResult with _$CloudinaryUploadResult {
  const factory CloudinaryUploadResult({
    required String publicId,
    required String secureUrl,
    required String originalFilename,
    required int bytes,
    required int width,
    required int height,
    required String format,
  }) = _CloudinaryUploadResult;

  const CloudinaryUploadResult._();

  factory CloudinaryUploadResult.fromJson(Map<String, dynamic> json) {
    return CloudinaryUploadResult(
      publicId: json['public_id'] as String? ?? '',
      secureUrl: json['secure_url'] as String? ?? '',
      originalFilename: json['original_filename'] as String? ?? '',
      bytes: json['bytes'] as int? ?? 0,
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
      format: json['format'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'publicId': publicId,
    'secureUrl': secureUrl,
    'originalFilename': originalFilename,
    'bytes': bytes,
    'width': width,
    'height': height,
    'format': format,
  };
}

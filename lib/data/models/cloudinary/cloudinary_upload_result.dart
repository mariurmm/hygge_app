import 'package:equatable/equatable.dart';

final class CloudinaryUploadResult extends Equatable {
  const CloudinaryUploadResult({
    required this.publicId,
    required this.secureUrl,
    required this.originalFilename,
    required this.bytes,
    required this.width,
    required this.height,
    required this.format,
  });

  final String publicId;
  final String secureUrl;
  final String originalFilename;
  final int bytes;
  final int width;
  final int height;
  final String format;

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

  Map<String, dynamic> toJson() => <String, dynamic>{
    'publicId': publicId,
    'secureUrl': secureUrl,
    'originalFilename': originalFilename,
    'bytes': bytes,
    'width': width,
    'height': height,
    'format': format,
  };

  @override
  List<Object?> get props => <Object?>[publicId, secureUrl, originalFilename, bytes, width, height, format];
}

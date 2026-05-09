import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:hygge_app/data/models/localized_value.dart';

part 'post_model.freezed.dart';

@freezed
abstract class PostModel with _$PostModel {
  const factory PostModel({
    required String uuid,
    required String title,
    required String text,
    required String imageUrl,
  }) = _PostModel;

  const PostModel._();

  factory PostModel.fromJson(
    Map<String, dynamic> json, {
    String locale = LocalizedValue.defaultLocale,
  }) {
    return PostModel(
      uuid: json['uuid'] as String? ?? json['id'] as String? ?? '',
      title: LocalizedValue.read(json['title'], locale: locale),
      text: LocalizedValue.read(json['text'], locale: locale),
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  static const PostModel empty = PostModel(
    uuid: '',
    title: '',
    text: '',
    imageUrl: '',
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  Map<String, dynamic> toJson() {
    return {'uuid': uuid, 'title': title, 'text': text, 'imageUrl': imageUrl};
  }
}

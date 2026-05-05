import 'package:equatable/equatable.dart';

import 'package:hygge_app/data/models/localized_value.dart';

/// Модель поста.
class PostModel extends Equatable {
  const PostModel({
    required this.uuid,
    required this.title,
    required this.text,
    required this.imageUrl,
  });

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

  /// Уникальный идентификатор.
  final String uuid;

  /// Заголовок поста.
  final String title;

  /// Текст поста.
  final String text;

  /// Ссылка на изображение.
  final String imageUrl;

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

  @override
  List<Object?> get props => [uuid, title, text, imageUrl];
}

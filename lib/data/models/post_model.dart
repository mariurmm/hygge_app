import 'package:equatable/equatable.dart';

import 'localized_value.dart';

/// Модель поста.
class PostModel extends Equatable {
  /// Уникальный идентификатор.
  final String uuid;

  /// Заголовок поста.
  final String title;

  /// Текст поста.
  final String text;

  /// Ссылка на изображение.
  final String imageUrl;

  const PostModel({
    required this.uuid,
    required this.title,
    required this.text,
    required this.imageUrl,
  });

  static const PostModel empty = PostModel(
    uuid: '',
    title: '',
    text: '',
    imageUrl: '',
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

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

  Map<String, dynamic> toJson() {
    return {'uuid': uuid, 'title': title, 'text': text, 'imageUrl': imageUrl};
  }

  @override
  List<Object?> get props => [uuid, title, text, imageUrl];
}

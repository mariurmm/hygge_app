import 'package:equatable/equatable.dart';

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

  /// Пустая модель.
  static const PostModel empty = PostModel(
    uuid: '',
    title: '',
    text: '',
    imageUrl: '',
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      uuid: json['uuid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      text: json['text'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'title': title,
      'text': text,
      'imageUrl': imageUrl,
    };
  }

  @override
  List<Object?> get props => [uuid, title, text, imageUrl];
}

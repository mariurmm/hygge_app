import 'package:equatable/equatable.dart';

import 'localized_value.dart';
import 'program_category.dart';

class ProgramModel extends Equatable {
  final String uuid;
  final ProgramCategory category;
  final String ritual;
  final String title;
  final String text;
  final String imageUrl;
  final double price;
  final String masterId;
  final bool isBookable;

  const ProgramModel({
    required this.uuid,
    required this.category,
    this.ritual = '',
    required this.title,
    required this.text,
    this.imageUrl = '',
    required this.price,
    required this.masterId,
    this.isBookable = true,
  });

  static const ProgramModel empty = ProgramModel(
    uuid: '',
    category: ProgramCategory.yoga,
    ritual: '',
    title: '',
    text: '',
    imageUrl: '',
    price: 0,
    masterId: '',
    isBookable: false,
  );

  bool get isEmpty => this == empty;

  bool get isNotEmpty => this != empty;

  String get description => text;

  factory ProgramModel.fromJson(
    Map<String, dynamic> json, {
    String locale = LocalizedValue.defaultLocale,
  }) {
    return ProgramModel(
      uuid: _readString(json, ['uuid', 'id']),
      category: ProgramCategory.fromJson(json['category'] as String?),
      ritual: LocalizedValue.read(json['ritual'], locale: locale),
      title: LocalizedValue.read(json['title'], locale: locale),
      text: LocalizedValue.read(json['text'], locale: locale),
      imageUrl: _readString(json, ['imageUrl', 'coverUrl', 'image']),
      price: _parseDouble(json['price']),
      masterId: _readString(json, ['masterId', 'masterUuid']),
      isBookable: json['isBookable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'category': category.toJson(),
      'ritual': ritual,
      'title': title,
      'text': text,
      'imageUrl': imageUrl,
      'price': price,
      'masterId': masterId,
      'isBookable': isBookable,
    };
  }

  ProgramModel copyWith({
    String? uuid,
    ProgramCategory? category,
    String? ritual,
    String? title,
    String? text,
    String? imageUrl,
    double? price,
    String? masterId,
    bool? isBookable,
  }) {
    return ProgramModel(
      uuid: uuid ?? this.uuid,
      category: category ?? this.category,
      ritual: ritual ?? this.ritual,
      title: title ?? this.title,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      masterId: masterId ?? this.masterId,
      isBookable: isBookable ?? this.isBookable,
    );
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];

      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return '';
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  List<Object?> get props => [
        uuid,
        category,
        ritual,
        title,
        text,
        imageUrl,
        price,
        masterId,
        isBookable,
      ];
}
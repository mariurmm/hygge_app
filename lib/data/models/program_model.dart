import 'package:equatable/equatable.dart';

import '../../core/utils/parse_utils.dart';
import 'localized_value.dart';
import 'program_category.dart';

class ProgramModel extends Equatable {
  final String id;
  final ProgramCategory category;
  final String ritual;
  final String title;
  final String text;
  final String imageUrl;
  final double price;
  final String trainerId;
  final bool isBookable;

  const ProgramModel({
    required this.id,
    required this.category,
    this.ritual = '',
    required this.title,
    required this.text,
    this.imageUrl = '',
    required this.price,
    required this.trainerId,
    this.isBookable = true,
  });

  static const ProgramModel empty = ProgramModel(
    id: '',
    category: ProgramCategory.yoga,
    ritual: '',
    title: '',
    text: '',
    imageUrl: '',
    price: 0,
    trainerId: '',
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
      id: _readString(json, ['uuid', 'id']),
      category: ProgramCategory.fromJson(json['category'] as String?),
      ritual: LocalizedValue.read(json['ritual'], locale: locale),
      title: LocalizedValue.read(json['title'], locale: locale),
      text: LocalizedValue.read(json['text'], locale: locale),
      imageUrl: _readString(json, ['imageUrl', 'coverUrl', 'image']),
      price: ParseUtils.parseDouble(json['price']),
      trainerId: _readString(json, ['masterId', 'masterUuid']),
      isBookable: json['isBookable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': id,
      'category': category.toJson(),
      'ritual': ritual,
      'title': title,
      'text': text,
      'imageUrl': imageUrl,
      'price': price,
      'masterId': trainerId,
      'isBookable': isBookable,
    };
  }

  ProgramModel copyWith({
    String? id,
    ProgramCategory? category,
    String? ritual,
    String? title,
    String? text,
    String? imageUrl,
    double? price,
    String? trainerId,
    bool? isBookable,
  }) {
    return ProgramModel(
      id: id ?? this.id,
      category: category ?? this.category,
      ritual: ritual ?? this.ritual,
      title: title ?? this.title,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      trainerId: trainerId ?? this.trainerId,
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

  @override
  List<Object?> get props => [
    id,
    category,
    ritual,
    title,
    text,
    imageUrl,
    price,
    trainerId,
    isBookable,
  ];
}

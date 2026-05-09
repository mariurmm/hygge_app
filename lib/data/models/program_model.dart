import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:hygge_app/core/utils/parse_utils.dart';
import 'package:hygge_app/data/models/localized_value.dart';
import 'package:hygge_app/data/models/program_category.dart';

part 'program_model.freezed.dart';

@freezed
abstract class ProgramModel with _$ProgramModel {
  const factory ProgramModel({
    required String id,
    required ProgramCategory category,
    required String title,
    required String text,
    required double price,
    required String trainerId,
    @Default('') String ritual,
    @Default('') String imageUrl,
    @Default(true) bool isBookable,
  }) = _ProgramModel;

  const ProgramModel._();

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

  static const ProgramModel empty = ProgramModel(
    id: '',
    category: ProgramCategory.yoga,
    title: '',
    text: '',
    price: 0,
    trainerId: '',
    isBookable: false,
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;
  String get description => text;

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

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }
}

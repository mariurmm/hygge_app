import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_model.freezed.dart';

@freezed
abstract class PriceModel with _$PriceModel {
  const factory PriceModel({
    required double amount,
    required String currency,
  }) = _PriceModel;

  const PriceModel._();

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'KZT',
    );
  }

  static const PriceModel empty = PriceModel(amount: 0, currency: 'KZT');

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  Map<String, dynamic> toJson() => {'amount': amount, 'currency': currency};
}

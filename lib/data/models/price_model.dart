import 'package:equatable/equatable.dart';

class PriceModel extends Equatable {
  const PriceModel({required this.amount, required this.currency});

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'KZT',
    );
  }
  final double amount;
  final String currency;

  static const PriceModel empty = PriceModel(amount: 0, currency: 'KZT');

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  Map<String, dynamic> toJson() {
    return {'amount': amount, 'currency': currency};
  }

  @override
  List<Object?> get props => [amount, currency];
}

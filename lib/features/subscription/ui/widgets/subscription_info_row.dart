import 'package:flutter/material.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';

class SubscriptionInfoRow extends StatelessWidget {
  const SubscriptionInfoRow({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.scheduleCardLabel),
        Text(
          value,
          style: AppTextStyles.scheduleCardLabel.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';

class BookingDetailRow extends StatelessWidget {
  const BookingDetailRow({
    required this.icon,
    required this.label,
    super.key,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppTextStyles.scheduleCardLabel.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}

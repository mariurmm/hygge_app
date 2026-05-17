import 'package:flutter/material.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/data/models/class_model.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';

class BookingCancelDialog extends StatelessWidget {
  const BookingCancelDialog({
    required this.classModel,
    required this.loc,
    super.key,
  });

  final ClassModel classModel;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.darkBrown,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        loc.cancelDialogTitle,
        style: AppTextStyles.scheduleCalendarTitle,
      ),
      content: Text(
        loc.cancelDialogContent(classModel.title),
        style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            loc.cancelDialogBack,
            style: AppTextStyles.button.copyWith(color: Colors.white54),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            loc.cancelDialogConfirm,
            style: AppTextStyles.button.copyWith(color: AppColors.terracotta),
          ),
        ),
      ],
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/data/models/class_model.dart';
import 'package:hygge_app/features/booking/bloc/booking_bloc.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';

class BookingBookButton extends StatelessWidget {
  const BookingBookButton({
    required this.classModel,
    required this.bookingState,
    required this.loc,
    required this.onCancelTap,
    super.key,
  });

  final ClassModel classModel;
  final BookingState bookingState;
  final AppLocalizations loc;
  final VoidCallback onCancelTap;

  @override
  Widget build(BuildContext context) {
    final isLoading = bookingState.status == BookingUiStatus.loading;
    final isBooked = bookingState.existingBooking != null;

    if (!classModel.isIncludedInSubscription) {
      return _PrimaryButton(
        label: loc.bookViaAdmin,
        enabled: false,
        isLoading: false,
      );
    }

    if (isBooked) {
      final hoursUntilClass = classModel.startDate
          .difference(DateTime.now())
          .inHours;
      final canCancel = hoursUntilClass > 24;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PrimaryButton(
            label: loc.bookedButton,
            enabled: false,
            isLoading: isLoading,
          ),
          const SizedBox(height: 12),
          _CancelButton(
            label: loc.cancelBooking,
            isLoading: isLoading,
            enabled: canCancel,
            onTap: onCancelTap,
          ),
          if (!canCancel) ...[
            const SizedBox(height: 8),
            Text(
              loc.cancelTooLate,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white54,
              ),
            ),
          ],
        ],
      );
    }

    if (classModel.isFull) {
      return _PrimaryButton(
        label: loc.noSpots,
        enabled: false,
        isLoading: false,
      );
    }

    return _PrimaryButton(
      label: loc.bookButton,
      enabled: !isLoading,
      isLoading: isLoading,
      onPressed: () => context.read<BookingBloc>().add(
        BookingBookClassEvent(
          classModel: classModel,
          whatsAppMessage: classModel.isIncludedInSubscription
              ? loc.whatsAppNoSubscription(classModel.title)
              : loc.whatsAppExternalEvent(classModel.title),
        ),
      ),
    );
  }
}

// ─── Primary Button ──────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.enabled,
    required this.isLoading,
    this.onPressed,
  });

  final String label;
  final bool enabled;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.scheduleCardRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: enabled
                  ? AppColors.primary.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.1),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
              disabledForegroundColor: Colors.white54,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.scheduleCardRadius,
                ),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(label, style: AppTextStyles.button),
          ),
        ),
      ),
    );
  }
}

// ─── Cancel Button ───────────────────────────────────────────────────────────

class _CancelButton extends StatelessWidget {
  const _CancelButton({
    required this.label,
    required this.isLoading,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool isLoading;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.scheduleCardRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: OutlinedButton(
            onPressed: (isLoading || !enabled) ? null : onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.terracotta,
              side: BorderSide(
                color: AppColors.terracotta.withValues(alpha: 0.6),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.scheduleCardRadius,
                ),
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.button.copyWith(color: AppColors.terracotta),
            ),
          ),
        ),
      ),
    );
  }
}

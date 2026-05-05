import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/class_model.dart';
import '../../subscription/cubit/subscription_cubit.dart';
import '../cubit/booking_cubit.dart';

class ClassDetailScreen extends StatefulWidget {
  final ClassModel classModel;

  const ClassDetailScreen({super.key, required this.classModel});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookingCubit>().checkBookingStatus(widget.classModel.id);
  }

  @override
  Widget build(BuildContext context) {
    final classModel = widget.classModel;
    final dateFormat = DateFormat('d MMMM, EEEE', 'ru');

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AssetPaths.homeBackground, fit: BoxFit.cover),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(classModel.type, style: AppTextStyles.scheduleCardLabel),
                  const SizedBox(height: 4),
                  Text(
                    classModel.title,
                    style: AppTextStyles.scheduleSectionTitle,
                  ),
                  const SizedBox(height: 24),
                  _GlassCard(
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: dateFormat.format(classModel.startDate),
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          icon: Icons.access_time_outlined,
                          label: classModel.timeRange,
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          icon: Icons.timer_outlined,
                          label: '${classModel.durationMinutes} мин',
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          icon: Icons.people_outline,
                          label:
                              '${classModel.currentParticipants} / ${classModel.maxParticipants} участников',
                        ),
                        if (!classModel.isIncludedInSubscription) ...[
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.attach_money,
                            label: '${classModel.price.toStringAsFixed(0)} ₸',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!classModel.isIncludedInSubscription)
                    _GlassCard(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Это выездное мероприятие. Запись через администратора.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    BlocBuilder<SubscriptionCubit, SubscriptionState>(
                      builder: (context, subState) {
                        if (!subState.hasActiveSubscription) {
                          return _GlassCard(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.card_membership,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Для записи необходим активный абонемент.',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  const SizedBox(height: 24),
                  BlocConsumer<BookingCubit, BookingState>(
                    listener: (context, state) async {
                      if (state.status ==
                          BookingCubitStatus.cancelConfirmationRequired) {
                        final bookingId = state.existingBooking?.id;
                        if (bookingId == null) return;
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.darkBrown,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text(
                              'Отменить запись?',
                              style: AppTextStyles.scheduleCalendarTitle,
                            ),
                            content: Text(
                              'Вы уверены, что хотите отменить запись на «${classModel.title}»?',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: Text(
                                  'Назад',
                                  style: AppTextStyles.button.copyWith(
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: Text(
                                  'Да, отменить',
                                  style: AppTextStyles.button.copyWith(
                                    color: AppColors.terracotta,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true && context.mounted) {
                          context.read<BookingCubit>().cancelBooking(bookingId);
                        }
                        return;
                      }

                      const snackbarStatuses = {
                        BookingCubitStatus.success,
                        BookingCubitStatus.cancelled,
                        BookingCubitStatus.error,
                        BookingCubitStatus.alreadyBooked,
                        BookingCubitStatus.noSubscription,
                        BookingCubitStatus.classFull,
                        BookingCubitStatus.externalBookingRequired,
                      };
                      if (!snackbarStatuses.contains(state.status)) return;
                      final msg = state.message ?? '';
                      if (msg.isEmpty) return;
                      final isPositive =
                          state.status == BookingCubitStatus.success ||
                          state.status == BookingCubitStatus.cancelled;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            msg,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: isPositive
                              ? AppColors.primary
                              : AppColors.darkBrown,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    builder: (context, state) {
                      return _BookButton(
                        classModel: classModel,
                        bookingState: state,
                        onCancelTap: () =>
                            context.read<BookingCubit>().requestCancelBooking(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookButton extends StatelessWidget {
  final ClassModel classModel;
  final BookingState bookingState;
  final VoidCallback? onCancelTap;

  const _BookButton({
    required this.classModel,
    required this.bookingState,
    this.onCancelTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = bookingState.status == BookingCubitStatus.loading;
    final isBooked = bookingState.existingBooking != null;
    final isExternal = !classModel.isIncludedInSubscription;

    if (isExternal) {
      return _primaryButton(
        label: 'Запись через администратора',
        enabled: false,
        isLoading: false,
        onPressed: null,
      );
    }

    if (isBooked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _primaryButton(
            label: 'Вы записаны',
            enabled: false,
            isLoading: isLoading,
            onPressed: null,
          ),
          const SizedBox(height: 12),
          _cancelButton(context, isLoading),
        ],
      );
    }

    if (classModel.isFull) {
      return _primaryButton(
        label: 'Мест нет',
        enabled: false,
        isLoading: false,
        onPressed: null,
      );
    }

    return _primaryButton(
      label: 'Записаться',
      enabled: !isLoading,
      isLoading: isLoading,
      onPressed: () => context.read<BookingCubit>().bookClass(classModel),
    );
  }

  Widget _primaryButton({
    required String label,
    required bool enabled,
    required bool isLoading,
    required VoidCallback? onPressed,
  }) {
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
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: AppConstants.programsBorderWidth,
                ),
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

  Widget _cancelButton(BuildContext context, bool isLoading) {
    return SizedBox(
      height: 48,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.scheduleCardRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: OutlinedButton(
            onPressed: isLoading ? null : onCancelTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.terracotta,
              side: BorderSide(
                color: AppColors.terracotta.withValues(alpha: 0.6),
                width: AppConstants.programsBorderWidth,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.scheduleCardRadius,
                ),
              ),
            ),
            child: Text(
              'Отменить запись',
              style: AppTextStyles.button.copyWith(color: AppColors.terracotta),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.scheduleCardRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.scheduleCard.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(
              AppConstants.scheduleCardRadius,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: AppConstants.programsBorderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailRow({required this.icon, required this.label});

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

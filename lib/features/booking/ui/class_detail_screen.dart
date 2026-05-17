import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/data/models/class_model.dart';
import 'package:hygge_app/features/booking/bloc/booking_bloc.dart';
import 'package:hygge_app/features/booking/widgets/booking_book_button.dart';
import 'package:hygge_app/features/booking/widgets/booking_cancel_dialog.dart';
import 'package:hygge_app/features/booking/widgets/booking_detail_row.dart';
import 'package:hygge_app/features/booking/widgets/booking_glass_card.dart';
import 'package:hygge_app/features/booking/widgets/booking_info_card.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

class ClassDetailScreen extends StatefulWidget {
  const ClassDetailScreen({required this.classModel, super.key});
  final ClassModel classModel;

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(
      BookingCheckStatusEvent(classId: widget.classModel.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final classModel = widget.classModel;
    final loc = AppLocalizations.of(context);
    final dateFormat = DateFormat('d MMMM, EEEE', loc.localeName);

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
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    classModel.type,
                    style: AppTextStyles.scheduleCardLabel,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    classModel.title,
                    style: AppTextStyles.scheduleSectionTitle,
                  ),
                  const SizedBox(height: 24),
                  BookingGlassCard(
                    child: Column(
                      children: [
                        BookingDetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: dateFormat.format(classModel.startDate),
                        ),
                        const SizedBox(height: 12),
                        BookingDetailRow(
                          icon: Icons.access_time_outlined,
                          label: classModel.timeRange,
                        ),
                        const SizedBox(height: 12),
                        BookingDetailRow(
                          icon: Icons.timer_outlined,
                          label: loc.durationMinutes(
                            classModel.durationMinutes,
                          ),
                        ),
                        const SizedBox(height: 12),
                        BookingDetailRow(
                          icon: Icons.people_outline,
                          label: loc.participants(
                            classModel.currentParticipants,
                            classModel.maxParticipants,
                          ),
                        ),
                        if (!classModel.isIncludedInSubscription) ...[
                          const SizedBox(height: 12),
                          BookingDetailRow(
                            icon: Icons.attach_money,
                            label: '${classModel.price.toStringAsFixed(0)} ₸',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  BookingInfoCard(classModel: classModel, loc: loc),
                  const SizedBox(height: 24),
                  BlocConsumer<BookingBloc, BookingState>(
                    listener: (context, state) async {
                      if (state.status ==
                          BookingUiStatus.cancelConfirmationRequired) {
                        final bookingId = state.existingBooking?.id;
                        if (bookingId == null) return;
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (_) => BookingCancelDialog(
                            classModel: classModel,
                            loc: loc,
                          ),
                        );
                        if ((confirmed ?? false) && context.mounted) {
                          context.read<BookingBloc>().add(
                            BookingConfirmCancelEvent(bookingId: bookingId),
                          );
                        }
                        return;
                      }

                      const snackbarStatuses = {
                        BookingUiStatus.success,
                        BookingUiStatus.cancelled,
                        BookingUiStatus.error,
                        BookingUiStatus.alreadyBooked,
                        BookingUiStatus.noSubscription,
                        BookingUiStatus.classFull,
                        BookingUiStatus.externalBookingRequired,
                      };
                      if (!snackbarStatuses.contains(state.status)) return;

                      final msg = switch (state.status) {
                        BookingUiStatus.success => loc.bookingSuccess(
                          classModel.title,
                        ),
                        BookingUiStatus.cancelled => loc.bookingCancelled,
                        BookingUiStatus.alreadyBooked =>
                          loc.bookingAlreadyBooked,
                        BookingUiStatus.noSubscription =>
                          loc.bookingNoSubscription,
                        BookingUiStatus.classFull => loc.bookingClassFull,
                        BookingUiStatus.externalBookingRequired =>
                          loc.bookViaAdmin,
                        BookingUiStatus.error => loc.bookingError(
                          state.errorMessage ?? '',
                        ),
                        _ => null,
                      };
                      if (msg == null) return;

                      final isPositive =
                          state.status == BookingUiStatus.success ||
                          state.status == BookingUiStatus.cancelled;
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
                      return BookingBookButton(
                        classModel: classModel,
                        bookingState: state,
                        loc: loc,
                        onCancelTap: () => context.read<BookingBloc>().add(
                          const BookingRequestCancelEvent(),
                        ),
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

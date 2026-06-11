import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hygge_app/data/models/booking_model.dart';
import 'package:hygge_app/data/models/class_model.dart';
import 'package:hygge_app/features/booking/bloc/booking_bloc.dart';
import 'package:hygge_app/features/booking/ui/class_detail_screen.dart';
import 'package:hygge_app/features/subscription/bloc/subscription_bloc.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';

class _MockBookingBloc extends MockBloc<BookingEvent, BookingState>
    implements BookingBloc {}

class _MockSubscriptionBloc
    extends MockBloc<SubscriptionEvent, SubscriptionState>
    implements SubscriptionBloc {}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildSubject({
  required _MockBookingBloc bookingBloc,
  required _MockSubscriptionBloc subscriptionBloc,
  required ClassModel classModel,
}) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ru'),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<BookingBloc>.value(value: bookingBloc),
          BlocProvider<SubscriptionBloc>.value(value: subscriptionBloc),
        ],
        child: ClassDetailScreen(classModel: classModel),
      ),
    );

ClassModel _classAt(DateTime startDate) => ClassModel(
      id: 'class-1',
      title: 'Yoga',
      type: 'Йога',
      startDate: startDate,
      durationMinutes: 60,
      trainerId: 't-1',
      maxParticipants: 10,
      currentParticipants: 3,
      price: 0,
      isIncludedInSubscription: true,
    );

BookingModel _bookingAt(DateTime datetime) => BookingModel(
      id: 'bk-1',
      userId: 'u-1',
      classId: 'class-1',
      datetime: datetime,
      status: BookingStatus.confirmed,
      notificationSent: false,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late _MockBookingBloc mockBookingBloc;
  late _MockSubscriptionBloc mockSubscriptionBloc;

  setUp(() {
    mockBookingBloc = _MockBookingBloc();
    mockSubscriptionBloc = _MockSubscriptionBloc();

    const subState = SubscriptionState();
    whenListen(
      mockSubscriptionBloc,
      Stream.value(subState),
      initialState: subState,
    );
  });

  void seedBookedState(DateTime datetime) {
    final state = BookingState(existingBooking: _bookingAt(datetime));
    whenListen(mockBookingBloc, Stream.value(state), initialState: state);
  }

  testWidgets('renders_cancelButton_whenUserIsBooked', (tester) async {
    final farDate = DateTime.now().add(const Duration(hours: 48));
    seedBookedState(farDate);

    await tester.pumpWidget(
      _buildSubject(
        bookingBloc: mockBookingBloc,
        subscriptionBloc: mockSubscriptionBloc,
        classModel: _classAt(farDate),
      ),
    );
    await tester.pump();

    expect(find.text('Отменить запись'), findsOneWidget);
  });

  testWidgets('cancelButton_isEnabled_whenMoreThan24Hours', (tester) async {
    final farDate = DateTime.now().add(const Duration(hours: 48));
    seedBookedState(farDate);

    await tester.pumpWidget(
      _buildSubject(
        bookingBloc: mockBookingBloc,
        subscriptionBloc: mockSubscriptionBloc,
        classModel: _classAt(farDate),
      ),
    );
    await tester.pump();

    final button = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('Отменить запись'),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('cancelButton_isDisabled_whenLessThan24Hours', (tester) async {
    final nearDate = DateTime.now().add(const Duration(hours: 12));
    seedBookedState(nearDate);

    await tester.pumpWidget(
      _buildSubject(
        bookingBloc: mockBookingBloc,
        subscriptionBloc: mockSubscriptionBloc,
        classModel: _classAt(nearDate),
      ),
    );
    await tester.pump();

    final button = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('Отменить запись'),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('shows_cancelTooLate_text_whenLessThan24Hours', (tester) async {
    final nearDate = DateTime.now().add(const Duration(hours: 12));
    seedBookedState(nearDate);

    await tester.pumpWidget(
      _buildSubject(
        bookingBloc: mockBookingBloc,
        subscriptionBloc: mockSubscriptionBloc,
        classModel: _classAt(nearDate),
      ),
    );
    await tester.pump();

    expect(
      find.text('Отмена невозможна менее чем за 24 часа до занятия'),
      findsOneWidget,
    );
  });
}

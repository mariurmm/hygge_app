import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hygge_app/data/models/lesson_model.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/program_category.dart';
import 'package:hygge_app/data/models/program_model.dart';
import 'package:hygge_app/features/booking/bloc/booking_bloc.dart';
import 'package:hygge_app/features/programs_detail/bloc/program_details_bloc.dart';
import 'package:hygge_app/features/programs_detail/bloc/program_details_event.dart';
import 'package:hygge_app/features/programs_detail/bloc/program_details_state.dart';
import 'package:hygge_app/features/programs_detail/ui/program_details_page.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';

class _MockProgramDetailsBloc
    extends MockBloc<ProgramDetailsEvent, ProgramDetailsState>
    implements ProgramDetailsBloc {}

class _MockBookingBloc extends MockBloc<BookingEvent, BookingState>
    implements BookingBloc {}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

LessonModel _lessonAt(DateTime startDate) => LessonModel(
      id: 'lesson-1',
      programId: 'program-1',
      startDate: startDate,
      endDate: startDate.add(const Duration(hours: 1)),
    );

ProgramDetailsState _bookedState(LessonModel lesson) => ProgramDetailsState(
      status: ProgramDetailsStatus.loaded,
      program: const ProgramModel(
        id: 'program-1',
        category: ProgramCategory.yoga,
        title: 'Test Program',
        text: 'Description',
        price: 0,
        trainerId: 't-1',
      ),
      lesson: lesson,
      master: MasterModel.empty,
      bookedLessonIds: {lesson.id},
    );

Widget _buildSubject({
  required _MockProgramDetailsBloc programBloc,
  required _MockBookingBloc bookingBloc,
}) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ru'),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ProgramDetailsBloc>.value(value: programBloc),
          BlocProvider<BookingBloc>.value(value: bookingBloc),
        ],
        child: const ProgramDetailsView(),
      ),
    );

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late _MockProgramDetailsBloc programBloc;
  late _MockBookingBloc bookingBloc;

  setUp(() {
    programBloc = _MockProgramDetailsBloc();
    bookingBloc = _MockBookingBloc();

    const idleBookingState = BookingState();
    whenListen(
      bookingBloc,
      Stream.value(idleBookingState),
      initialState: idleBookingState,
    );
  });

  testWidgets('renders_cancelButton_whenLessonIsBooked', (tester) async {
    final farLesson = _lessonAt(DateTime.now().add(const Duration(hours: 48)));
    final state = _bookedState(farLesson);
    whenListen(programBloc, Stream.value(state), initialState: state);

    await tester.pumpWidget(
      _buildSubject(programBloc: programBloc, bookingBloc: bookingBloc),
    );
    await tester.pump();

    // When booked and >24h away, shows loc.cancelBooking text.
    expect(find.text('Отменить запись'), findsOneWidget);
  });

  testWidgets('cancelButton_isEnabled_whenMoreThan24Hours', (tester) async {
    final farLesson = _lessonAt(DateTime.now().add(const Duration(hours: 48)));
    final state = _bookedState(farLesson);
    whenListen(programBloc, Stream.value(state), initialState: state);

    await tester.pumpWidget(
      _buildSubject(programBloc: programBloc, bookingBloc: bookingBloc),
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
    final nearLesson =
        _lessonAt(DateTime.now().add(const Duration(hours: 12)));
    final state = _bookedState(nearLesson);
    whenListen(programBloc, Stream.value(state), initialState: state);

    await tester.pumpWidget(
      _buildSubject(programBloc: programBloc, bookingBloc: bookingBloc),
    );
    await tester.pump();

    // When <24h away, shows loc.cancelTooLate as the button label (disabled).
    final button = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('Отмена невозможна менее чем за 24 часа до занятия'),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(button.onPressed, isNull);
  });
}

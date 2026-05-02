import 'package:bloc/bloc.dart';

import '../../../data/models/lesson_model.dart';
import '../../../data/models/master_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/schedule_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final BookingRepository _bookingRepo;
  final ScheduleRepository _scheduleRepo;
  final String userId;

  HomeCubit({
    required BookingRepository bookingRepo,
    required ScheduleRepository scheduleRepo,
    required this.userId,
  })  : _bookingRepo = bookingRepo,
        _scheduleRepo = scheduleRepo,
        super(const HomeState()) {
    loadUpcoming();
  }

  Future<void> loadUpcoming() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final bookings = await _bookingRepo.getUpcomingBookings(userId);

      final lessons = await Future.wait(
        bookings.map((booking) async {
          final cls = await _scheduleRepo.getClass(booking.classId);
          if (cls == null) return null;
          return LessonModel(
            uuid: cls.id,
            ritual: cls.type,
            title: cls.title,
            text: '',
            startDate: cls.datetime,
            finishDate: cls.datetime.add(Duration(minutes: cls.durationMinutes)),
            price: cls.price,
            master: MasterModel.empty,
          );
        }),
      );

      emit(state.copyWith(
        lessons: lessons.whereType<LessonModel>().toList(),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

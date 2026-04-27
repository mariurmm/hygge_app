import 'package:bloc/bloc.dart';
import 'package:hygge_app/features/history/bloc/history_state.dart';
import 'package:hygge_app/features/shared/data/firebase_feature_repository.dart';

class HistoryBloc extends Cubit<HistoryState> {
  HistoryBloc({FirebaseFeatureRepository? repository})
      : _repository = repository ?? FirebaseFeatureRepository(),
        super(const HistoryState(lessons: [])) {
    _loadHistory();
  }

  final FirebaseFeatureRepository _repository;

  Future<void> _loadHistory() async {
    final lessons = await _repository.fetchBookings(status: 'completed');
    emit(HistoryState(lessons: lessons));
  }
}

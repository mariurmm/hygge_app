part of 'history_bloc.dart';

sealed class HistoryEvent {
  const HistoryEvent();
}

final class HistoryLoadRequested extends HistoryEvent {
  const HistoryLoadRequested();
}
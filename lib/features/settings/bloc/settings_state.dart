import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final String? localAvatarPath;
  final bool busy;
  final String? errorMessage;

  const SettingsState({
    this.localAvatarPath,
    this.busy = false,
    this.errorMessage,
  });

  SettingsState copyWith({
    String? localAvatarPath,
    bool? busy,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SettingsState(
      localAvatarPath: localAvatarPath ?? this.localAvatarPath,
      busy: busy ?? this.busy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [localAvatarPath, busy, errorMessage];
}

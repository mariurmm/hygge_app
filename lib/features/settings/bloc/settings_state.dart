import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final String? localAvatarPath;
  final bool busy;
  final String? errorMessage;
  final bool hasUnsavedChanges;
  final bool allowPop;
  final String savedName;

  const SettingsState({
    this.localAvatarPath,
    this.busy = false,
    this.errorMessage,
    this.hasUnsavedChanges = false,
    this.allowPop = false,
    this.savedName = '',
  });

  SettingsState copyWith({
    String? localAvatarPath,
    bool? busy,
    String? errorMessage,
    bool? hasUnsavedChanges,
    bool? allowPop,
    String? savedName,
    bool clearError = false,
    bool clearLocalAvatar = false,
  }) {
    return SettingsState(
      localAvatarPath: clearLocalAvatar
          ? null
          : (localAvatarPath ?? this.localAvatarPath),
      busy: busy ?? this.busy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      allowPop: allowPop ?? this.allowPop,
      savedName: savedName ?? this.savedName,
    );
  }

  @override
  List<Object?> get props => [
        localAvatarPath,
        busy,
        errorMessage,
        hasUnsavedChanges,
        allowPop,
        savedName,
      ];
}

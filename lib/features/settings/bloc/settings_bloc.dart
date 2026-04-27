import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hygge_app/data/models/user_model.dart';
import 'package:hygge_app/data/repositories/auth_repository.dart';
import 'package:hygge_app/features/app/bloc/app_bloc.dart';
import 'package:hygge_app/features/app/bloc/app_event.dart';
import 'package:hygge_app/features/settings/bloc/settings_state.dart';

class SettingsBloc extends Cubit<SettingsState> {
  final AuthRepository _authRepository;
  final AppBloc _appBloc;
  final TextEditingController nameController;
  final TextEditingController emailController;

  SettingsBloc({
    required AuthRepository authRepository,
    required AppBloc appBloc,
    required UserModel user,
  }) : _authRepository = authRepository,
       _appBloc = appBloc,
       nameController = TextEditingController(text: user.displayName),
       emailController = TextEditingController(text: user.email),
       super(const SettingsState());

  Future<void> pickAvatarFromGallery() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    emit(state.copyWith(localAvatarPath: file.path, clearError: true));
  }

  void deleteAvatar() {
    emit(state.copyWith(clearLocalAvatar: true, clearError: true));
  }

  Future<void> persistProfileFields() async {
    emit(state.copyWith(busy: true, clearError: true));
    try {
      await _authRepository.updateUserProfileFields(
        displayName: nameController.text,
        email: emailController.text,
      );
      // Уведомляем AppBloc, чтобы он перечитал актуальные данные из Firebase.
      // Это необходимо, так как updateDisplayName не триггерит authStateChanges.
      _appBloc.add(const AppUserRefreshRequested());
      emit(state.copyWith(busy: false));
    } catch (e) {
      emit(state.copyWith(busy: false, errorMessage: e.toString()));
    }
  }

  Future<void> deleteAccount() async {
    emit(state.copyWith(busy: true, clearError: true));
    try {
      await _authRepository.deleteAccount();
      emit(state.copyWith(busy: false));
    } catch (e) {
      emit(state.copyWith(busy: false, errorMessage: e.toString()));
      rethrow;
    }
  }

  ImageProvider<Object>? avatarImage() {
    final path = state.localAvatarPath;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      return FileImage(File(path));
    }
    return null;
  }

  @override
  Future<void> close() {
    nameController.dispose();
    emailController.dispose();
    return super.close();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/router/route_names.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/data/models/user_model.dart';
import 'package:hygge_app/data/repositories/auth_repository.dart';
import 'package:hygge_app/features/app/bloc/app_bloc.dart';
import 'package:hygge_app/features/app/bloc/app_event.dart';
import 'package:hygge_app/features/settings/bloc/settings_bloc.dart';
import 'package:hygge_app/features/settings/bloc/settings_state.dart';
import 'package:hygge_app/widgets/glass_panel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(
        authRepository: AuthRepository.instance,
        user: context.read<AppBloc>().state.user,
      ),
      child: BlocListener<SettingsBloc, SettingsState>(
        listenWhen: (p, c) =>
            c.errorMessage != null && c.errorMessage != p.errorMessage,
        listener: (context, state) {
          final msg = state.errorMessage;
          if (msg != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg)),
            );
          }
        },
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            final bloc = context.read<SettingsBloc>();
            final appUser = context.watch<AppBloc>().state.user;

            return Scaffold(
              backgroundColor: Colors.transparent,
              extendBody: true,
              extendBodyBehindAppBar: true,
              body: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      AssetPaths.homeBackground,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.profileCardsBottomInset,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppPaddings.profileScreenHorizontal,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(
                              height: AppConstants.settingsHeaderTopSpacing,
                            ),
                            Row(
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 44,
                                    minHeight: 44,
                                  ),
                                  onPressed: () => context.pop(),
                                  icon: Image.asset(
                                    AssetPaths.arrowBackPng,
                                    width: 24,
                                    height: 24,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Настройки профиля',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.settingsHeaderTitle,
                                  ),
                                ),
                                const SizedBox(width: 44),
                              ],
                            ),
                            Center(
                              child: GlassRoundedPanel(
                                width: AppConstants.settingsAvatarWidth,
                                height: AppConstants.settingsAvatarHeight,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.settingsGlassRadius,
                                  ),
                                  child: _settingsAvatarFill(bloc, appUser),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: AppConstants.settingsAfterAvatarSpacing,
                            ),
                            Center(
                              child: TextButton(
                                onPressed: state.busy
                                    ? null
                                    : () => bloc.pickAvatarFromGallery(),
                                child: Text(
                                  'Поменять фото',
                                  style: AppTextStyles.settingsChangePhoto,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: AppConstants.settingsAfterChangePhotoSpacing,
                            ),
                            Text(
                              'Обязательные данные',
                              style: AppTextStyles.settingsHeaderTitle.copyWith(
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(
                              height: AppConstants.settingsLabelInputSpacing,
                            ),
                            Text(
                              'Имя Фамилия',
                              style: AppTextStyles.settingsLabel16Light,
                            ),
                            const SizedBox(
                              height: AppConstants.settingsLabelInputSpacing,
                            ),
                            Center(
                              child: GlassRoundedPanel(
                                width: AppConstants.settingsInputWidth,
                                height: AppConstants.settingsInputHeight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    controller: bloc.nameController,
                                    style: AppTextStyles.settingsInput16Medium,
                                    cursorColor: Colors.white,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onEditingComplete: () =>
                                        bloc.persistProfileFields(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: AppConstants.settingsLabelInputSpacing,
                            ),
                            Text(
                              'Адрес электронной почты',
                              style: AppTextStyles.settingsLabel16Light,
                            ),
                            const SizedBox(
                              height: AppConstants.settingsLabelInputSpacing,
                            ),
                            Center(
                              child: GlassRoundedPanel(
                                width: AppConstants.settingsInputWidth,
                                height: AppConstants.settingsInputHeight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    controller: bloc.emailController,
                                    style: AppTextStyles.settingsInput16Medium,
                                    cursorColor: Colors.white,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onEditingComplete: () =>
                                        bloc.persistProfileFields(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: AppConstants.settingsAfterEmailSpacing,
                            ),
                            _settingsActionRow(
                              assetPath: AssetPaths.logoutIcon,
                              fallbackIcon: Icons.logout_rounded,
                              label: 'Выйти из аккаунта',
                              textStyle: AppTextStyles.settingsActionWhite,
                              onTap: state.busy
                                  ? null
                                  : () async {
                                      context
                                          .read<AppBloc>()
                                          .add(const AppSignOutRequested());
                                      if (context.mounted) {
                                        context.go(RouteNames.login);
                                      }
                                    },
                            ),
                            const SizedBox(height: 16),
                            _settingsActionRow(
                              assetPath: AssetPaths.deleteAccountIcon,
                              fallbackIcon: Icons.delete_outline_rounded,
                              label: 'Удалить аккаунт',
                              textStyle: AppTextStyles.settingsActionDelete,
                              onTap: state.busy
                                  ? null
                                  : () async {
                                      try {
                                        await bloc.deleteAccount();
                                        if (context.mounted) {
                                          context.go(RouteNames.login);
                                        }
                                      } catch (_) {}
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget _settingsAvatarFill(SettingsBloc bloc, UserModel appUser) {
  final local = bloc.avatarImage();
  if (local != null) {
    return Image(
      image: local,
      fit: BoxFit.cover,
      width: AppConstants.settingsAvatarWidth,
      height: AppConstants.settingsAvatarHeight,
    );
  }
  if (appUser.photoUrl.isNotEmpty) {
    return Image.network(
      appUser.photoUrl,
      fit: BoxFit.cover,
      width: AppConstants.settingsAvatarWidth,
      height: AppConstants.settingsAvatarHeight,
      errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black26),
    );
  }
  return const ColoredBox(color: Colors.black26);
}

Widget _settingsActionRow({
  required String assetPath,
  required IconData fallbackIcon,
  required String label,
  required TextStyle textStyle,
  required VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            assetPath,
            width: AppConstants.settingsActionIconSize,
            height: AppConstants.settingsActionIconSize,
            errorBuilder: (_, __, ___) => Icon(
              fallbackIcon,
              color: textStyle.color,
              size: AppConstants.settingsActionIconSize,
            ),
          ),
          const SizedBox(width: AppConstants.settingsActionIconTextGap),
          Flexible(
            child: Text(
              label,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}

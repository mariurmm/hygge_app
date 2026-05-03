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
import 'package:hygge_app/features/app/bloc/locale_cubit.dart';
import 'package:hygge_app/features/settings/bloc/settings_bloc.dart';
import 'package:hygge_app/features/settings/bloc/settings_state.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';
import 'package:hygge_app/widgets/glass_panel.dart';
import '../../../widgets/tab_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(
        authRepository: context.read<AuthRepository>(),
        appBloc: context.read<AppBloc>(),
        user: context.read<AppBloc>().state.user,
      ),
      child: BlocListener<SettingsBloc, SettingsState>(
        listenWhen: (prev, curr) => curr.errorMessage != null && curr.errorMessage != prev.errorMessage,
        listener: (context, state) {
          if (state.errorMessage case final msg?) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
          }
        },
        child: const _SettingsView(),
      ),
    );
  }
}

// ─── Main View ────────────────────────────────────────────────────────────────

// _SettingsView is a StatelessWidget — all unsaved-changes/saving state lives
// in SettingsBloc (hasUnsavedChanges, allowPop, savedName, busy).
class _SettingsView extends StatelessWidget {
  const _SettingsView();

  Future<void> _save(BuildContext context) async {
    await context.read<SettingsBloc>().save();
  }

  void _popAfterAction(BuildContext context) {
    context.read<SettingsBloc>().setAllowPop();
    context.pop();
  }

  void _showUnsavedChangesDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.dialogSaveChangesTitle),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, 'cancel'), child: Text(loc.dialogCancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, 'discard'), child: Text(loc.dialogDiscard)),
          TextButton(onPressed: () => Navigator.pop(ctx, 'save'), child: Text(loc.dialogSave)),
        ],
      ),
    ).then((result) {
      if (!context.mounted) return;
      if (result == 'save') {
        _save(context).then((_) {
          if (context.mounted) _popAfterAction(context);
        });
      } else if (result == 'discard') {
        final bloc = context.read<SettingsBloc>();
        bloc.nameController.text = bloc.state.savedName;
        _popAfterAction(context);
      }
    });
  }

  Future<void> _signOut(BuildContext context) async {
    context.read<AppBloc>().add(const AppSignOutRequested());
    if (context.mounted) context.go(RouteNames.login);
  }

  Future<void> _deleteAccount(BuildContext context, SettingsBloc bloc) async {
    try {
      await bloc.deleteAccount();
      if (context.mounted) context.go(RouteNames.login);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SettingsBloc>().state;
    final bloc = context.read<SettingsBloc>();
    final appUser = context.watch<AppBloc>().state.user;
    final loc = AppLocalizations.of(context);

    return PopScope(
      canPop: state.allowPop || !state.hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showUnsavedChangesDialog(context);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned.fill(child: Image.asset(AssetPaths.homeBackground, fit: BoxFit.cover)),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: AppConstants.profileCardsBottomInset),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppPaddings.profileScreenHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Хедер ──
                      ProgramsHeader(
                        trailing: const SizedBox.shrink(),
                        leading: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                          onPressed: () {
                            if (state.hasUnsavedChanges) {
                              _showUnsavedChangesDialog(context);
                            } else {
                              context.pop();
                            }
                          },
                          icon: Image.asset(
                            AssetPaths.arrowBackPng,
                            width: 24,
                            height: 24,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Аватар ──
                      _AvatarSection(bloc: bloc, appUser: appUser, busy: state.busy),

                      const SizedBox(height: 32),

                      // ── Секция: Профиль ──
                      _SectionLabel(label: loc.settingsRequiredFields),
                      const SizedBox(height: 12),
                      _InputField(
                        label: loc.settingsFullName,
                        controller: bloc.nameController,
                        hasChanges: state.hasUnsavedChanges,
                        onSave: state.busy ? null : () => _save(context),
                      ),
                      const SizedBox(height: 16),
                      _ReadonlyField(label: loc.settingsEmailAddress, controller: bloc.emailController),

                      const SizedBox(height: 32),

                      // ── Секция: Настройки приложения ──
                      _SectionLabel(label: loc.settingsAppSettings),
                      const SizedBox(height: 12),
                      _ActionRow(
                        assetPath: '',
                        fallbackIcon: Icons.language_rounded,
                        leadingWidget: Text(
                          _languageFlag(
                            context.watch<LocaleCubit>().state?.languageCode ??
                                Localizations.localeOf(context).languageCode,
                          ),
                          style: const TextStyle(fontSize: 24),
                        ),
                        label: loc.settingsChangeLanguage,
                        textStyle: AppTextStyles.settingsActionWhite,
                        onTap: () => _LanguagePickerSheet.show(context),
                      ),

                      const SizedBox(height: 32),

                      // ── Секция: Аккаунт ──
                      _SectionLabel(label: loc.settingsAccount),
                      const SizedBox(height: 12),
                      _ActionRow(
                        assetPath: AssetPaths.logoutIcon,
                        fallbackIcon: Icons.logout_rounded,
                        label: loc.settingsSignOut,
                        textStyle: AppTextStyles.settingsActionWhite,
                        onTap: state.busy ? null : () => _signOut(context),
                      ),
                      const SizedBox(height: 8),
                      _ActionRow(
                        assetPath: AssetPaths.deleteAccountIcon,
                        fallbackIcon: Icons.delete_outline_rounded,
                        label: loc.settingsDeleteAccount,
                        textStyle: AppTextStyles.settingsActionDelete,
                        onTap: state.busy ? null : () => _deleteAccount(context, bloc),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.settingsLabel16Light.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
        color: Colors.white70,
      ),
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({required this.bloc, required this.appUser, required this.busy});

  final SettingsBloc bloc;
  final UserModel appUser;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: busy ? null : bloc.pickAvatarFromGallery,
        child: GlassRoundedPanel(
          width: AppConstants.settingsAvatarWidth,
          height: AppConstants.settingsAvatarHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.settingsGlassRadius),
            child: _avatarContent(),
          ),
        ),
      ),
    );
  }

  Widget _avatarContent() {
    final localImage = bloc.avatarImage();
    if (localImage != null) {
      return Image(
        image: localImage,
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
}

// ─── Editable Input Field ─────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  const _InputField({required this.label, required this.controller, required this.hasChanges, this.onSave});

  final String label;
  final TextEditingController controller;
  final bool hasChanges;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.settingsLabel16Light),
        const SizedBox(height: AppConstants.settingsLabelInputSpacing),
        Center(
          child: GlassRoundedPanel(
            width: AppConstants.settingsInputWidth,
            height: AppConstants.settingsInputHeight,
            padding: const EdgeInsets.only(left: 20, right: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: AppTextStyles.settingsInput16Medium,
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onEditingComplete: hasChanges ? onSave : null,
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onSave,
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: Icon(
                      hasChanges ? Icons.check_rounded : Icons.edit_outlined,
                      color: (hasChanges && onSave != null) ? Colors.white : Colors.white38,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Readonly Field (email) ───────────────────────────────────────────────────

class _ReadonlyField extends StatelessWidget {
  const _ReadonlyField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.settingsLabel16Light),
            const SizedBox(width: 6),
            const Icon(Icons.lock_outline_rounded, color: Colors.white38, size: 13),
          ],
        ),
        const SizedBox(height: AppConstants.settingsLabelInputSpacing),
        Center(
          child: GlassRoundedPanel(
            width: AppConstants.settingsInputWidth,
            height: AppConstants.settingsInputHeight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                controller.text,
                style: AppTextStyles.settingsInput16Medium.copyWith(color: Colors.white38),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Action Row ───────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.assetPath,
    required this.fallbackIcon,
    required this.label,
    required this.textStyle,
    required this.onTap,
    this.leadingWidget,
  });

  final String assetPath;
  final IconData fallbackIcon;
  final String label;
  final TextStyle textStyle;
  final VoidCallback? onTap;
  final Widget? leadingWidget;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            leadingWidget ??
                Image.asset(
                  assetPath,
                  width: AppConstants.settingsActionIconSize,
                  height: AppConstants.settingsActionIconSize,
                  errorBuilder: (_, __, ___) =>
                      Icon(fallbackIcon, color: textStyle.color, size: AppConstants.settingsActionIconSize),
                ),
            const SizedBox(width: AppConstants.settingsActionIconTextGap),
            Flexible(
              child: Text(label, style: textStyle, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Language helpers ─────────────────────────────────────────────────────────

String _languageFlag(String code) => switch (code) {
  'ru' => '🇷🇺',
  'kk' => '🇰🇿',
  _ => '🇬🇧',
};

// ─── Language Picker ──────────────────────────────────────────────────────────

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet();

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LanguagePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final currentCode = context.read<LocaleCubit>().state?.languageCode ?? Localizations.localeOf(context).languageCode;

    return Container(
      decoration: const BoxDecoration(
        color: Color.fromRGBO(20, 20, 20, 0.92),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Text(loc.settingsSelectLanguage, style: AppTextStyles.settingsHeaderTitle)),
          const SizedBox(height: 16),
          ...AppLocalizations.supportedLocales.map(
            (locale) => _LanguageTile(locale: locale, isSelected: locale.languageCode == currentCode),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.locale, required this.isSelected});

  final Locale locale;
  final bool isSelected;

  static String _localeName(String code) => switch (code) {
    'ru' => 'Русский',
    'kk' => 'Қазақша',
    _ => 'English',
  };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<LocaleCubit>().setLocale(locale);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Text(_languageFlag(locale.languageCode), style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(child: Text(_localeName(locale.languageCode), style: AppTextStyles.settingsActionWhite)),
            if (isSelected) const Icon(Icons.check_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}

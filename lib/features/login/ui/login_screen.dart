import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../features/app/bloc/app_bloc.dart';
import '../../../features/app/bloc/app_state.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Экран входа — Hygge Concept.
///
/// Дизайн:
/// - Фон — фото листа (assets/images/login_background.png)
/// - Логотип Hygge сверху (assets/images/hygge_logo.png)
/// - Текст «Здравствуйте!» по центру
/// - Иконка медитирующей фигуры с чакрами (assets/icons/chakra.svg)
/// - Полупрозрачная кнопка «Вход через Google» внизу
///
/// Логика:
/// Слушает [AppBloc] через [BlocListener]:
/// - Когда статус меняется на [AppStatus.authenticated] → переходим на Home.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _onSignInPressed() async {
    setState(() => _isLoading = true);

    try {
      await AuthRepository.instance.signInWithGoogle();
      // Навигация произойдёт через BlocListener ниже.
    } catch (error) {
      AppLogger.error('LoginScreen: ошибка входа', error: error);

      if (!mounted) return;

      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.signInError)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AppStatus.authenticated) {
          context.go(RouteNames.main);
        }
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── 1. Фоновое изображение листа ──────────────────────────────
            const _LoginBackground(),

            // ── 2. Основной контент ───────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // Логотип «hy.gge CONCEPT»
                  const _HyggeLogo(),

                  const Spacer(),

                  // «Здравствуйте!»
                  // TODO: заменить на loc.loginGreeting после добавления в .arb файлы
                  Text(
                    'Здравствуйте!',
                    style: const TextStyle(
                      fontFamily: 'CeraPro',
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Иконка медитации с чакрами
                  const _ChakraIcon(),

                  const Spacer(),

                  // Кнопка «Вход через Google»
                  // TODO: заменить на loc.loginGoogleButton после добавления в .arb файлы
                  _GoogleSignInButton(
                    label: 'Вход через Google',
                    isLoading: _isLoading,
                    onTap: _onSignInPressed,
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Приватные виджеты
// ─────────────────────────────────────────────────────────────────────────────

/// Фоновая фотография листа, растянутая на весь экран.
class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/png/login_background.png',
      fit: BoxFit.cover,
    );
  }
}

/// Логотип «hy.gge CONCEPT».
class _HyggeLogo extends StatelessWidget {
  const _HyggeLogo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPaddings.defaultPadding,
      ),
      child: Image.asset(
        'assets/png/hygge_logo.png',
        width: 500,
        height: 200,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Иконка медитирующей фигуры с чакрами.
///
/// Для SVG подключи пакет flutter_svg в pubspec.yaml:
/// ```yaml
/// dependencies:
///   flutter_svg: ^2.0.0
/// ```
/// Затем замени Image.asset на SvgPicture.asset (см. комментарий внутри).
class _ChakraIcon extends StatelessWidget {
  const _ChakraIcon();

  @override
  Widget build(BuildContext context) {
    // После подключения flutter_svg замени на:
    //
    // return SvgPicture.asset(
    //   'assets/icons/chakra.svg',
    //   width: 120,
    //   height: 120,
    //   colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    // );

    return Image.asset(
      'assets/png/chakra.png',
      width: 120,
      height: 120,
      color: Colors.white,
    );
  }
}

/// Полупрозрачная кнопка-таблетка «Вход через Google».
///
/// При [isLoading] == true показывает индикатор и блокирует повторное нажатие.
class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPaddings.largePadding,
      ),
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(35),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'CeraPro',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
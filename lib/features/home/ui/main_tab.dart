import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../l10n/generated/app_localizations.dart';

class MainTab extends StatelessWidget {
  const MainTab({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Фоновое изображение на весь экран
          Positioned.fill(
            child: Image.asset('assets/png/background1.png', fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Хедер ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Логотип + название
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/svg/logohygge.svg',
                            width: 32,
                            height: 32,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'hy.gge',
                            style: TextStyle(
                              fontFamily: 'Cera Pro',
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      // Колокольчик
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                ),

                // ── Скролл контент ──
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Заголовок ──
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            top: 8,
                            right: 20,
                          ),
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: 'Cera Pro',
                                fontWeight: FontWeight.w500,
                                fontSize: 28,
                                height: 1.25,
                                color: Colors.white,
                              ),
                              children: [
                                TextSpan(text: 'Обретите\nсвое '),
                                TextSpan(
                                  text: 'спокойствие',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFFE08564),
                                  ),
                                ),
                                TextSpan(text: '\nсегодня'),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Анонсы ──
                        const Padding(
                          padding: EdgeInsets.only(left: 19),
                          child: Text(
                            'Анонсы',
                            style: TextStyle(
                              fontFamily: 'Cera Pro',
                              fontWeight: FontWeight.w500,
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Баннер анонса
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(35),
                            child: Stack(
                              children: [
                                // Картинка баннера
                                Image.asset(
                                  'assets/png/banner.png',
                                  width: double.infinity,
                                  height: 218,
                                  fit: BoxFit.cover,
                                ),
                                // Подпись внизу баннера
                                Positioned(
                                  left: 20,
                                  bottom: 16,
                                  child: Text(
                                    loc.readOurNews,
                                    style: const TextStyle(
                                      fontFamily: 'Cera Pro',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── Предстоящие программы ──
                        const Padding(
                          padding: EdgeInsets.only(left: 19),
                          child: Text(
                            'Предстоящие программы',
                            style: TextStyle(
                              fontFamily: 'Cera Pro',
                              fontWeight: FontWeight.w500,
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Горизонтальный скролл карточек
                        SizedBox(
                          height: 172,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(left: 18, right: 18),
                            itemCount: 4,
                            itemBuilder: (context, index) => const _ProgramCard(
                              title: 'Новая программа',
                              date: 'Начало 01.06',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Карточка программы ──
class _ProgramCard extends StatelessWidget {
  final String title;
  final String date;

  const _ProgramCard({required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.14),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0.18),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.08),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.white70,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cera Pro',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  date,
                  style: const TextStyle(
                    fontFamily: 'Cera Pro',
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

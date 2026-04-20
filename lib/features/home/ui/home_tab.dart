import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/widgets/tab_header.dart';
import 'dart:ui';
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
          Positioned.fill(
            child: Image.asset('assets/png/background1.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Хедер ──
                const ProgramsHeader(),

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
                            left: AppPaddings.programsScreenHorizontal,
                            top: 8,
                            right: AppPaddings.programsScreenHorizontal,
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.programsHeading,
                              children: [
                                TextSpan(text: loc.homeHeadlinePart1),
                                TextSpan(
                                  text: loc.homeHeadlineAccent,
                                  style: AppTextStyles.programsHeading.copyWith(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFFE08564),
                                  ),
                                ),
                                TextSpan(text: loc.homeHeadlinePart2),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Анонсы ──
                        Padding(
                          padding: const EdgeInsets.only(
                            left: AppPaddings.programsScreenHorizontal,
                          ),
                          child: Text(
                            loc.homeAnnouncements,
                            style: AppTextStyles.programsHeading.copyWith(
                              fontSize: 24,
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
                                Image.asset(
                                  'assets/png/banner.png',
                                  width: double.infinity,
                                  height: 218,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  left: 20,
                                  bottom: 16,
                                  child: Text(
                                    loc.readOurNews,
                                    style: AppTextStyles.programsFilter,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── Предстоящие программы ──
                        Padding(
                          padding: const EdgeInsets.only(
                            left: AppPaddings.programsScreenHorizontal,
                          ),
                          child: Text(
                            loc.homeUpcomingPrograms,
                            style: AppTextStyles.programsHeading.copyWith(
                              fontSize: 24,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Горизонтальный скролл карточек
                        SizedBox(
                          height: 172,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppPaddings.programsScreenHorizontal,
                            ),
                            itemCount: 4,
                            itemBuilder: (context, index) => _ProgramCard(
                              title: loc.homeProgramCardTitle,
                              date: loc.homeProgramCardDate,
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
                Text(title, style: AppTextStyles.programsCardTitle),
                const SizedBox(height: 6),
                Text(date, style: AppTextStyles.programsCardDescription),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

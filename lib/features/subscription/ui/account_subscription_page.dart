import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/data/models/subscription_model.dart';
import 'package:hygge_app/data/repositories/user_repository/user_repository_impl.dart';
import 'package:hygge_app/widgets/glass_panel.dart';

import '../bloc/account_subscription_bloc.dart';
import '../bloc/account_subscription_event.dart';
import '../bloc/account_subscription_state.dart';

class AccountSubscriptionPage extends StatelessWidget {
  const AccountSubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AccountSubscriptionBloc(repository: UserRepositoryImpl())
            ..add(const AccountSubscriptionStarted()),
      child: const AccountSubscriptionView(),
    );
  }
}

class AccountSubscriptionView extends StatelessWidget {
  const AccountSubscriptionView({super.key});

  String _locale(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'en' || code == 'ru' || code == 'kk') return code;
    return 'ru';
  }

  String _t(BuildContext context, String key) {
    final locale = _locale(context);

    const values = {
      'ru': {
        'page': 'Счёт и подписка',
        'currentPlan': 'Текущий тариф',
        'free': 'Free',
        'premiumActive': 'Доступ ко всем программам активен',
        'freeActive': 'Базовый доступ без активной подписки',
        'manageTitle': 'Управление подпиской',
        'manageSubtitle': 'Изменить тариф или отменить подписку',
        'historyTitle': 'История платежей',
        'historySubtitle': 'Посмотреть оплаченные периоды',
        'error': 'Ошибка загрузки',
      },
      'en': {
        'page': 'Account & subscription',
        'currentPlan': 'Current plan',
        'free': 'Free',
        'premiumActive': 'Access to all programs is active',
        'freeActive': 'Basic access without an active subscription',
        'manageTitle': 'Manage subscription',
        'manageSubtitle': 'Change plan or cancel subscription',
        'historyTitle': 'Payment history',
        'historySubtitle': 'View paid periods',
        'error': 'Loading error',
      },
      'kk': {
        'page': 'Шот және жазылым',
        'currentPlan': 'Ағымдағы тариф',
        'free': 'Free',
        'premiumActive': 'Барлық бағдарламаларға қолжетімділік белсенді',
        'freeActive': 'Белсенді жазылымсыз негізгі қолжетімділік',
        'manageTitle': 'Жазылымды басқару',
        'manageSubtitle': 'Тарифті өзгерту немесе жазылымнан бас тарту',
        'historyTitle': 'Төлем тарихы',
        'historySubtitle': 'Төленген кезеңдерді көру',
        'error': 'Жүктеу қатесі',
      },
    };

    return values[locale]?[key] ?? values['ru']![key]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AssetPaths.homeBackground, fit: BoxFit.cover),

          SafeArea(
            bottom: false,
            child:
                BlocBuilder<AccountSubscriptionBloc, AccountSubscriptionState>(
                  builder: (context, state) {
                    if (state.status == AccountSubscriptionStatus.loading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (state.status == AccountSubscriptionStatus.failure) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            state.errorMessage ?? _t(context, 'error'),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.programsSubtitle,
                          ),
                        ),
                      );
                    }

                    final user = state.user;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.profileCardsBottomInset,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppPaddings.profileScreenHorizontal,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InnerHeader(
                              onBack: () => Navigator.of(context).pop(),
                            ),

                            const SizedBox(height: 18),

                            Text(
                              _t(context, 'page'),
                              style: AppTextStyles.programsHeading,
                            ),

                            const SizedBox(
                              height: AppSpacings.profileNameCardGap,
                            ),

                            _AccountGlassCard(
                              name: user.displayName,
                              email: user.email,
                              photoUrl: user.photoUrl,
                            ),

                            const SizedBox(
                              height: AppSpacings.profileCardsVerticalGap,
                            ),

                            _SubscriptionGlassCard(
                              subscription: user.subscription,
                              currentPlanLabel: _t(context, 'currentPlan'),
                              freeLabel: _t(context, 'free'),
                              premiumActiveText: _t(context, 'premiumActive'),
                              freeActiveText: _t(context, 'freeActive'),
                            ),

                            const SizedBox(
                              height: AppSpacings.profileCardsVerticalGap,
                            ),

                            _ActionGlassTile(
                              title: _t(context, 'manageTitle'),
                              subtitle: _t(context, 'manageSubtitle'),
                              onTap: () {},
                            ),

                            const SizedBox(height: 12),

                            _ActionGlassTile(
                              title: _t(context, 'historyTitle'),
                              subtitle: _t(context, 'historySubtitle'),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}

class _InnerHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _InnerHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            onPressed: onBack,
            icon: Image.asset(
              AssetPaths.arrowBackPng,
              width: AppConstants.programsHeaderIconSize,
              height: AppConstants.programsHeaderIconSize,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: AppConstants.programsHeaderIconSize,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'hygge concept',
            style: AppTextStyles.programsLogo.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }
}

class _AccountGlassCard extends StatelessWidget {
  final String name;
  final String email;
  final String photoUrl;

  const _AccountGlassCard({
    required this.name,
    required this.email,
    required this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GlassRoundedPanel(
      width: double.infinity,
      height: 104,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.programsCardMedia,
            backgroundImage: photoUrl.isNotEmpty
                ? NetworkImage(photoUrl)
                : null,
            child: photoUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : 'Hygge user',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.programsCardTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.programsCardDescription.copyWith(
                    fontSize: 14,
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

class _SubscriptionGlassCard extends StatelessWidget {
  final SubscriptionModel? subscription;
  final String currentPlanLabel;
  final String freeLabel;
  final String premiumActiveText;
  final String freeActiveText;

  const _SubscriptionGlassCard({
    required this.subscription,
    required this.currentPlanLabel,
    required this.freeLabel,
    required this.premiumActiveText,
    required this.freeActiveText,
  });

  @override
  Widget build(BuildContext context) {
    final isPremium = subscription?.isNotEmpty == true;
    final title = (subscription != null && subscription!.isNotEmpty) ? currentPlanLabel : freeLabel;

    return GlassRoundedPanel(
      width: double.infinity,
      height: 150,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(currentPlanLabel, style: AppTextStyles.settingsLabel16Light),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTextStyles.programsHeading.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 10),
          Text(
            isPremium ? premiumActiveText : freeActiveText,
            style: AppTextStyles.programsCardDescription,
          ),
        ],
      ),
    );
  }
}

class _ActionGlassTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionGlassTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassRoundedPanel(
      width: double.infinity,
      height: 82,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.settingsGlassRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.programsCardTitle),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.programsCardDescription.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

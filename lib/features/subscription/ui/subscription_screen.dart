import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/features/subscription/bloc/subscription_bloc.dart';
import 'package:hygge_app/features/subscription/ui/widgets/subscription_content.dart';
import 'package:hygge_app/features/subscription/ui/widgets/subscription_empty.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';
import 'package:hygge_app/widgets/tab_header.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AssetPaths.homeBackground, fit: BoxFit.cover),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProgramsHeader(
                  showLogo: false,
                  leading: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: AppConstants.programsHeaderLogoSize,
                      minHeight: AppConstants.programsHeaderLogoSize,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Image.asset(
                      AssetPaths.arrowBack,
                      width: 24,
                      height: 24,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: AppConstants.iconSizeMd,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
                    builder: (context, state) {
                      if (state.status == SubscriptionStatus.initial) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }
                      if (state.subscription == null) {
                        return SubscriptionEmpty(loc: loc);
                      }
                      return SubscriptionContent(state: state, loc: loc);
                    },
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

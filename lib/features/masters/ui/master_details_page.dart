import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_paddings.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/data/models/program_model.dart';
import 'package:hygge_app/data/repositories/programs_repository.dart';
import 'package:hygge_app/features/programs_list/ui/programm_list.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';
import 'package:hygge_app/widgets/base_layout.dart';
import 'package:hygge_app/widgets/tab_header.dart';

class MasterDetailsPage extends StatefulWidget {
  const MasterDetailsPage({
    required this.master,
    required this.repository,
    super.key,
  });

  final MasterModel master;
  final ProgramsRepository repository;

  @override
  State<MasterDetailsPage> createState() => _MasterDetailsPageState();
}

class _MasterDetailsPageState extends State<MasterDetailsPage> {
  late final Future<List<ProgramModel>> _programsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _programsFuture = widget.repository.fetchProgramsByMasterId(
      widget.master.id,
      locale: Localizations.localeOf(context).languageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterDetailsView(
      master: widget.master,
      programsFuture: _programsFuture,
    );
  }
}

class MasterDetailsView extends StatelessWidget {
  const MasterDetailsView({
    required this.master,
    required this.programsFuture,
    super.key,
  });

  final MasterModel master;
  final Future<List<ProgramModel>> programsFuture;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            AssetPaths.homeBackground,
            fit: BoxFit.cover,
          ),
          SafeArea(
            bottom: false,
            child: HyggeScreenLayout(
              header: ProgramsHeader(
                leading: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: AppConstants.profileProgramsHeaderIconSize,
                    minHeight: AppConstants.profileProgramsHeaderIconSize,
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: Image.asset(
                    AssetPaths.arrowBack,
                    width: AppConstants.arrowBackIconSize,
                    height: AppConstants.arrowBackIconSize,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
                title: loc.aboutMaster,
                showLogo: false,
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPaddings.programsScreenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _MasterHero(master: master),
                      const SizedBox(
                        height: AppSpacings.profileCardsVerticalGap,
                      ),
                      Text(
                        loc.masterPrograms,
                        style: AppTextStyles.programsHeading.copyWith(
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<List<ProgramModel>>(
                        future: programsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final programs =
                              snapshot.data ?? const <ProgramModel>[];

                          if (programs.isEmpty) {
                            return _EmptyText(text: loc.noMasterPrograms);
                          }

                          return ProgrammList(
                            type: ProgrammCardType.big,
                            programs: programs,
                            mastersById: <String, MasterModel>{
                              master.id: master,
                            },
                          );
                        },
                      ),
                      const SizedBox(
                        height: AppConstants.profileCardsBottomInset,
                      ),
                    ],
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

class _MasterHero extends StatelessWidget {
  const _MasterHero({
    required this.master,
  });

  final MasterModel master;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.programsCard.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.programsCardMedia,
                  backgroundImage: master.photoUrl.isNotEmpty
                      ? NetworkImage(master.photoUrl)
                      : null,
                  child: master.photoUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    master.fullName,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.programsHeading.copyWith(
                      fontSize: 26,
                      height: 1.08,
                    ),
                  ),
                ),
              ],
            ),
            if (master.bio.isNotEmpty) ...<Widget>[
              const SizedBox(height: 18),
              Text(
                master.bio,
                style: AppTextStyles.programsCardDescription.copyWith(
                  fontSize: 15,
                  height: 1.42,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.programsCardDescription.copyWith(
        height: 1.35,
      ),
    );
  }
}

Future<void> openMasterDetails(
  BuildContext context, {
  required MasterModel master,
}) async {
  if (master.isEmpty) return;

  final repository = context.read<ProgramsRepository>();

  await Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      pageBuilder: (_, _, _) {
        return MasterDetailsPage(
          master: master,
          repository: repository,
        );
      },
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  );
}

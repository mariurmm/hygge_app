import 'package:flutter/material.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/data/models/master_model.dart';
import 'package:hygge_app/features/masters/ui/master_details_page.dart';
import 'package:hygge_app/l10n/generated/app_localizations.dart';

class ProgramsMastersList extends StatelessWidget {
  const ProgramsMastersList({
    required this.masters,
    super.key,
  });

  final List<MasterModel> masters;

  @override
  Widget build(BuildContext context) {
    if (masters.isEmpty) {
      return Text(
        AppLocalizations.of(context).masterNotFound,
        style: AppTextStyles.settingsLabel16Light,
      );
    }

    return Column(
      children: <Widget>[
        for (var index = 0; index < masters.length; index++) ...<Widget>[
          _MasterCard(master: masters[index]),
          if (index < masters.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _MasterCard extends StatelessWidget {
  const _MasterCard({
    required this.master,
  });

  final MasterModel master;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: () async {
          await openMasterDetails(context, master: master);
        },
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.programsCard.withValues(alpha: 0.74),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 38,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        master.fullName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.programsCardTitle.copyWith(
                          height: 1.12,
                        ),
                      ),
                      if (master.bio.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 7),
                        Text(
                          master.bio,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.programsCardDescription.copyWith(
                            fontSize: 14,
                            height: 1.3,
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/core/utils/external_links.dart';

class ProfileAboutSection extends StatelessWidget {
  const ProfileAboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('О нас', style: AppTextStyles.programsHeading),
        const SizedBox(height: AppSpacings.programsLeadGap),
        _LinkRow(
          icon: Icons.phone_outlined,
          label: AppConstants.profileContactPhoneDisplay,
          onTap: () => launchExternalUrl(AppConstants.profileContactPhoneUri),
        ),
        const SizedBox(height: AppSpacings.scheduleCardTextGapV),
        _LinkRow(
          icon: Icons.email_outlined,
          label: AppConstants.profileContactEmail,
          onTap: () => launchExternalUrl(AppConstants.profileContactEmailUri),
        ),
        const SizedBox(height: AppSpacings.scheduleCardTextGapV),
        _LinkRow(
          icon: Icons.camera_alt_outlined,
          label: '@hy.gge_concept',
          onTap: () =>
              launchExternalUrl(AppConstants.profileInstagramConceptUrl),
        ),
        const SizedBox(height: AppSpacings.scheduleCardTextGapV),
        _LinkRow(
          icon: Icons.camera_alt_outlined,
          label: '@hy.gge.specialty.bar',
          onTap: () => launchExternalUrl(AppConstants.profileInstagramBarUrl),
        ),
        const SizedBox(height: AppSpacings.scheduleCardTextGapV),
        _LinkRow(
          icon: Icons.map_outlined,
          label: AppConstants.profileMapAddress,
          onTap: () => launchExternalUrl(AppConstants.profileMapUrl),
        ),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.programsSubtitle.copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

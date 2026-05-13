import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/constants/app_spacings.dart';
import 'package:hygge_app/core/constants/asset_paths.dart';
import 'package:hygge_app/core/theme/app_text_styles.dart';
import 'package:hygge_app/core/utils/external_links.dart';
import 'package:hygge_app/data/models/contact_info_model.dart';
import 'package:hygge_app/data/repositories/app_config_repository.dart';
import 'package:hygge_app/di/injection.dart';

class ProfileAboutSection extends StatelessWidget {
  const ProfileAboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return FutureBuilder<ContactInfoModel>(
      future: getIt<AppConfigRepository>().getContactInfo(languageCode),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData) {
          return const Text('Failed to load contact info');
        }
        final contactInfo = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contactInfo.title,
              style: AppTextStyles.programsHeading.copyWith(fontSize: 24),
            ),
            const SizedBox(height: AppSpacings.programsLeadGap),
            _LinkRow(
              icon: const Icon(Icons.phone_outlined, color: Colors.white),
              label: contactInfo.phoneDisplay,
              onTap: () => launchExternalUrl(contactInfo.phoneUri),
            ),
            const SizedBox(height: AppSpacings.scheduleCardTextGapV),
            _LinkRow(
              icon: const Icon(Icons.email_outlined, color: Colors.white),
              label: contactInfo.email,
              onTap: () => launchExternalUrl(contactInfo.emailUri),
            ),
            const SizedBox(height: AppSpacings.scheduleCardTextGapV),
            _LinkRow(
              icon: SvgPicture.asset(AssetPaths.instagramIcon),
              label: contactInfo.instagramConceptLabel,
              onTap: () => launchExternalUrl(contactInfo.instagramConceptUrl),
            ),
            const SizedBox(height: AppSpacings.scheduleCardTextGapV),
            _LinkRow(
              icon: SvgPicture.asset(AssetPaths.instagramIcon),
              label: contactInfo.instagramBarLabel,
              onTap: () => launchExternalUrl(contactInfo.instagramBarUrl),
            ),
            const SizedBox(height: AppSpacings.scheduleCardTextGapV),
            _LinkRow(
              icon: SvgPicture.asset(AssetPaths.mapIcon),
              label: contactInfo.mapAddress,
              onTap: () => launchExternalUrl(contactInfo.mapUrl),
            ),
          ],
        );
      },
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final Widget icon;
  final String label;
  final VoidCallback onTap;

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
            SizedBox(
              width: AppConstants.aboutSectionIconSize,
              height: AppConstants.aboutSectionIconSize,
              child: icon,
            ),
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

// import 'package:flutter/material.dart';
// import 'package:hygge_app/core/constants/app_constants.dart';
// import 'package:hygge_app/core/constants/app_spacings.dart';
// import 'package:hygge_app/core/theme/app_text_styles.dart';
// import 'package:hygge_app/core/utils/external_links.dart';
// import '../../../../l10n/generated/app_localizations.dart';

// class ProfileAboutSection extends StatelessWidget {
//   const ProfileAboutSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final loc = AppLocalizations.of(context);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           loc.profileAboutTitle,
//           style: AppTextStyles.programsHeading.copyWith(fontSize: 24),
//         ),
//         const SizedBox(height: AppSpacings.programsLeadGap),
//         _LinkRow(
//           icon: const Icon(Icons.phone_outlined),
//           label: AppConstants.profileContactPhoneDisplay,
//           onTap: () =>
//               launchExternalUrl(AppConstants.profileContactPhoneUri),
//         ),
//         const SizedBox(height: AppSpacings.scheduleCardTextGapV),
//         _LinkRow(
//           icon: Icons.email_outlined,
//           label: AppConstants.profileContactEmail,
//           onTap: () =>
//               launchExternalUrl(AppConstants.profileContactEmailUri),
//         ),
//         const SizedBox(height: AppSpacings.scheduleCardTextGapV),
//         _LinkRow(
//           icon: Icons.camera_alt_outlined,
//           label: '@hy.gge_concept',
//           onTap: () =>
//               launchExternalUrl(AppConstants.profileInstagramConceptUrl),
//         ),
//         const SizedBox(height: AppSpacings.scheduleCardTextGapV),
//         _LinkRow(
//           icon: Icons.camera_alt_outlined,
//           label: '@hy.gge.specialty.bar',
//           onTap: () =>
//               launchExternalUrl(AppConstants.profileInstagramBarUrl),
//         ),
//         const SizedBox(height: AppSpacings.scheduleCardTextGapV),
//         _LinkRow(
//           icon: Icons.map_outlined,
//           label: loc.profileMapAddress,
//           onTap: () => launchExternalUrl(AppConstants.profileMapUrl),
//         ),
//       ],
//     );
//   }
// }

// class _LinkRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;

//   const _LinkRow({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 6),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(icon, color: Colors.white, size: 22),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 label,
//                 style: AppTextStyles.programsSubtitle.copyWith(
//                   decoration: TextDecoration.underline,
//                   decorationColor: Colors.white70,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

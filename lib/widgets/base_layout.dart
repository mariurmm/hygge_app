import 'package:flutter/material.dart';
import 'package:hygge_app/core/constants/app_constants.dart';

class HyggeScreenLayout extends StatelessWidget {
  const HyggeScreenLayout({
    required this.header,
    required this.children,
    super.key,
    this.bottomPadding = AppConstants.programsCardsBottomInset,
    this.onRefresh,
  });

  final Widget header;
  final List<Widget> children;
  final double bottomPadding;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final scrollView = SingleChildScrollView(
      physics: onRefresh != null
          ? const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            )
          : const ClampingScrollPhysics(),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        Expanded(
          child: onRefresh != null
              ? RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                  onRefresh: onRefresh!,
                  child: scrollView,
                )
              : scrollView,
        ),
      ],
    );
  }
}

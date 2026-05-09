import 'package:flutter/material.dart';
import 'package:hygge_app/core/constants/app_constants.dart';

class HyggeScreenLayout extends StatelessWidget {
  const HyggeScreenLayout({
    required this.header,
    required this.children,
    this.bottomPadding = AppConstants.programsCardsBottomInset,
    super.key,
  });

  final Widget header;
  final List<Widget> children;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

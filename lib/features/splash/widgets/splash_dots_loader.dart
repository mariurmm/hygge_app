import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hygge_app/core/constants/app_constants.dart';
import 'package:hygge_app/core/theme/app_colors.dart';

class SplashDotsLoader extends StatefulWidget {
  const SplashDotsLoader({super.key});

  @override
  State<SplashDotsLoader> createState() => _SplashDotsLoaderState();
}

class _SplashDotsLoaderState extends State<SplashDotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(AppConstants.splashDotCount, (i) {
          final double sin = math
              .sin(
                ((_controller.value - i / AppConstants.splashDotCount) % 1.0) *
                    math.pi,
              )
              .clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.splashDotSpacing,
            ),
            child: Opacity(
              opacity:
                  AppConstants.splashDotOpacityMin +
                  AppConstants.splashDotOpacityRange * sin,
              child: Transform.scale(
                scale:
                    AppConstants.splashDotScaleMin +
                    AppConstants.splashDotScaleRange * sin,
                child: Container(
                  width: AppConstants.splashDotSize,
                  height: AppConstants.splashDotSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightBrown,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// lib/features/favourites/ui/widgets/favourite_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/features/favourites/bloc/favourites_cubit.dart';
import 'package:hygge_app/features/favourites/bloc/favourites_state.dart';
import 'package:hygge_app/core/theme/app_colors.dart';

/// Кнопка-сердечко для добавления/удаления занятия из избранного.
/// Встраивается в [ProgrammCard].
class FavouriteButton extends StatelessWidget {
  const FavouriteButton({
    super.key,
    required this.lessonUuid,
  });

  final String lessonUuid;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FavouritesCubit, FavouritesState, bool>(
      // BlocSelector — пересчитывает только при изменении конкретного uuid
      selector: (state) => state.isFavourite(lessonUuid),
      builder: (context, isFavourite) {
        return GestureDetector(
          onTap: () => context.read<FavouritesCubit>().toggle(lessonUuid),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: Icon(
              isFavourite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(isFavourite),
              color: isFavourite ? AppColors.terracotta : Colors.white70,
              size: 22,
            ),
          ),
        );
      },
    );
  }
}
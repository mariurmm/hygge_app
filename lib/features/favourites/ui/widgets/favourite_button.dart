import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hygge_app/core/theme/app_colors.dart';
import 'package:hygge_app/features/favourites/bloc/favourites_bloc.dart';

class FavouriteButton extends StatelessWidget {
  final String programId;

  const FavouriteButton({super.key, required this.programId});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FavouritesBloc, FavouritesState, bool>(
      selector: (state) => state.isFavourite(programId),
      builder: (context, isFavourite) {
        return GestureDetector(
          onTap: () {
            context.read<FavouritesBloc>().add(FavouritesToggled(programId));
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              isFavourite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              key: ValueKey<bool>(isFavourite),
              color: isFavourite ? AppColors.terracotta : Colors.white70,
              size: 22,
            ),
          ),
        );
      },
    );
  }
}

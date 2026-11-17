import 'package:flutter/material.dart';

import '../state/favorites.dart';

/// Heart toggle bound to the shared favourites set.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Set<String>>(
    valueListenable: favoriteIds,
    builder: (context, ids, _) {
      final saved = ids.contains(placeId);
      return IconButton(
        tooltip: saved ? 'Дуртайгаас хасах' : 'Дуртайд нэмэх',
        isSelected: saved,
        icon: const Icon(Icons.favorite_border),
        selectedIcon: Icon(
          Icons.favorite,
          color: Theme.of(context).colorScheme.error,
        ),
        onPressed: () => toggleFavorite(placeId),
      );
    },
  );
}

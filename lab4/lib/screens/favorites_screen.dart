import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/places.dart';
import '../models/place.dart';
import '../state/favorites.dart';

/// "Дуртай газрууд": saved destinations, removable with an undo.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  void _remove(BuildContext context, Place place) {
    setFavorite(place.id, false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('«${place.name}» хасагдлаа'),
          action: SnackBarAction(
            label: 'Буцаах',
            onPressed: () => setFavorite(place.id, true),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Дуртай газрууд')),
    body: ListenableBuilder(
      listenable: Listenable.merge([favoriteIds, placesVersion]),
      builder: (context, _) {
        final saved = [
          for (final place in places)
            if (favoriteIds.value.contains(place.id)) place,
        ];
        if (saved.isEmpty) {
          // Scrolls instead of overflowing on tiny/landscape screens with big text.
          return LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 56,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Дуртай газар алга',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Газрын хуудсан дээрх зүрхэн тэмдэг дээр дарж хадгална уу.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: saved.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final place = saved[i];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage: place.imageProvider,
                  ),
                  title: Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('${place.region} · ${place.bestSeason}'),
                  trailing: IconButton(
                    tooltip: 'Дуртайгаас хасах',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _remove(context, place),
                  ),
                  onTap: () => context.push('/favorites/place/${place.id}'),
                );
              },
            ),
          ),
        );
      },
    ),
  );
}

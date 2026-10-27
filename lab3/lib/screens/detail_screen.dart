import 'package:flutter/material.dart';

import '../models/place.dart';
import '../widgets/place_image.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.place,
    this.favoriteIds,
    this.onToggleFavorite,
  });

  final Place place;
  final ValueNotifier<Set<String>>? favoriteIds;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(place.name),
      actions: [
        if (favoriteIds != null)
          ValueListenableBuilder<Set<String>>(
            valueListenable: favoriteIds!,
            builder: (context, favorites, child) {
              final saved = favorites.contains(place.id);
              return IconButton(
                tooltip: saved ? 'Дуртайгаас хасах' : 'Дуртайд нэмэх',
                icon: Icon(saved ? Icons.favorite : Icons.favorite_border),
                onPressed: onToggleFavorite,
              );
            },
          ),
      ],
    ),
    body: SafeArea(top: false, child: PlaceDetailView(place: place)),
  );
}

/// Scaffold-free so the same view can be embedded in the expanded layout.
class PlaceDetailView extends StatelessWidget {
  const PlaceDetailView({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final imageForeground = theme.brightness == Brightness.dark
        ? colors.onSurface
        : colors.onPrimary;

    return ListView(
      key: PageStorageKey('detail-${place.id}'),
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        Stack(
          children: [
            PlaceImage(place: place, height: 260, width: double.infinity),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.scrim.withValues(alpha: 0),
                      colors.scrim.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Text(
                  place.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: imageForeground,
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: _Rating(rating: place.rating),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Stat(
                  icon: Icons.location_on,
                  value: place.region,
                  semanticLabel: 'Байршил: ${place.region}',
                ),
              ),
              Expanded(
                child: _Stat(
                  icon: Icons.route,
                  value: '${place.distanceKm} км',
                  semanticLabel:
                      'Улаанбаатараас ойролцоогоор '
                      '${place.distanceKm} километр',
                ),
              ),
              Expanded(
                child: _Stat(
                  icon: switch (place.bestSeason) {
                    'Хавар' => Icons.local_florist,
                    'Намар' => Icons.eco,
                    'Өвөл' => Icons.ac_unit,
                    _ => Icons.wb_sunny,
                  },
                  value: place.bestSeason,
                  semanticLabel: 'Тохиромжтой улирал: ${place.bestSeason}',
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(place.description, style: theme.textTheme.bodyLarge),
        ),
      ],
    );
  }
}

class _Rating extends StatelessWidget {
  const _Rating({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Үнэлгээ: 5-аас ${rating.toStringAsFixed(1)}. Жишээ үнэлгээ.',
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 5; i++)
              Icon(
                rating >= i + 1
                    ? Icons.star
                    : rating >= i + 0.5
                    ? Icons.star_half
                    : Icons.star_border,
                color: theme.colorScheme.tertiary,
                size: 20,
              ),
            const SizedBox(width: 6),
            Text(rating.toStringAsFixed(1), style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.value,
    required this.semanticLabel,
  });

  final IconData icon;
  final String value;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

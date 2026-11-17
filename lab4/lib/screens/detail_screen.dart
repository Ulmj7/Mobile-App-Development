import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/picked_location.dart';
import '../models/place.dart';
import '../state/ratings.dart';
import '../widgets/favorite_button.dart';
import '../widgets/place_image.dart';
import '../widgets/rating_input.dart';
import '../widgets/star_rating.dart';
import 'map_picker_screen.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(place.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      actions: [FavoriteButton(placeId: place.id)],
    ),
    body: PlaceDetailView(place: place),
  );
}

/// The scrolling body of a destination: photo gallery, rating, facts, location
/// and description. Has no Scaffold so any screen can embed it.
class PlaceDetailView extends StatelessWidget {
  const PlaceDetailView({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            _Gallery(place: place),
            ValueListenableBuilder<Map<String, int>>(
              valueListenable: userRatings,
              builder: (context, ratings, _) {
                final summary = ratingOf(place, ratings);
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: summary.hasRating
                      ? Row(
                          children: [
                            StarRating(rating: summary.average),
                            const SizedBox(width: 8),
                            Text(
                              summary.label,
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '(${summary.count} үнэлгээ)',
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Шинэ газар — үнэлгээ хараахан алга',
                          style: theme.textTheme.bodyMedium,
                        ),
                );
              },
            ),
            _RateCard(place: place),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Stat(
                      icon: Icons.place_outlined,
                      text: place.region,
                      semantics: 'Аймаг: ${place.region}',
                    ),
                  ),
                  Expanded(
                    child: _Stat(
                      icon: Icons.directions_car_outlined,
                      text: place.distanceKm > 0
                          ? '${place.distanceKm} км'
                          : '–',
                      semantics: place.distanceKm > 0
                          ? 'Улаанбаатараас ${place.distanceKm} километр'
                          : 'Зай тодорхойгүй',
                    ),
                  ),
                  Expanded(
                    child: _Stat(
                      icon: _seasonIcon(place.bestSeason),
                      text: place.bestSeason,
                      semantics: 'Тохиромжтой улирал: ${place.bestSeason}',
                    ),
                  ),
                ],
              ),
            ),
            if (place.hasLocation)
              ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: const Text('Байршил'),
                subtitle: Text(
                  PickedLocation(
                    latitude: place.latitude!,
                    longitude: place.longitude!,
                  ).coordinates,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  '/map',
                  extra: MapPickerArgs(
                    readOnly: true,
                    title: place.name,
                    initial: PickedLocation(
                      latitude: place.latitude!,
                      longitude: place.longitude!,
                      name: place.name,
                      region: place.region,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(place.description, style: theme.textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _seasonIcon(String season) => switch (season) {
    'Хавар' => Icons.local_florist_outlined,
    'Зун' => Icons.wb_sunny_outlined,
    'Намар' => Icons.eco_outlined,
    'Өвөл' => Icons.ac_unit,
    _ => Icons.calendar_month_outlined,
  };
}

/// Cover photograph with the title on a scrim. With several photographs it
/// becomes a swipeable [PageView] with a page counter and dots.
class _Gallery extends StatefulWidget {
  const _Gallery({required this.place});

  final Place place;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  static const _height = 260.0;
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int page) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(page);
    } else {
      _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final images = widget.place.imageProviders;
    final many = images.length > 1;
    return Column(
      children: [
        SizedBox(
          height: _height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (many)
                PageView.builder(
                  key: const Key('photo-gallery'),
                  controller: _controller,
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) => PlaceImage(
                    place: widget.place,
                    provider: images[i],
                    height: _height,
                  ),
                )
              else
                PlaceImage(place: widget.place, height: _height),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          theme.colorScheme.scrim.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
                      child: Text(
                        widget.place.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: dark
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (many) ...[
                // Mouse users on the web/desktop get arrows as well as drag.
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: IconButton.filledTonal(
                      tooltip: 'Өмнөх зураг',
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _page > 0 ? () => _go(_page - 1) : null,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: IconButton.filledTonal(
                      tooltip: 'Дараах зураг',
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _page < images.length - 1
                          ? () => _go(_page + 1)
                          : null,
                    ),
                  ),
                ),
              ],
              if (many)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.scrim.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Text(
                          '${_page + 1} / ${images.length}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (many)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < images.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: i == _page
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RateCard extends StatelessWidget {
  const _RateCard({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<Map<String, int>>(
      valueListenable: userRatings,
      builder: (context, ratings, _) {
        final mine = ratings[place.id];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  mine == null ? 'Энэ газрыг үнэлэх' : 'Таны үнэлгээ: $mine/5',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RatingInput(
                    value: mine ?? 0,
                    onChanged: (stars) {
                      ratePlace(place.id, stars);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text('«${place.name}»-д $stars од өглөө'),
                          ),
                        );
                    },
                  ),
                ),
                Text(
                  'Од дээр дарж үнэлгээ өгнө үү',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.text,
    required this.semantics,
  });

  final IconData icon;
  final String text;
  final String semantics;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semantics,
    excludeSemantics: true,
    child: Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

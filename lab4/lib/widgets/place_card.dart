import 'package:flutter/material.dart';

import '../models/place.dart';
import '../state/ratings.dart';
import 'place_image.dart';

class PlaceCard extends StatelessWidget {
  const PlaceCard({super.key, required this.place, required this.onTap});

  final Place place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<Map<String, int>>(
      valueListenable: userRatings,
      builder: (context, ratings, _) {
        final summary = ratingOf(place, ratings);
        return Semantics(
          button: true,
          label: summary.hasRating
              ? '${place.name}, ${place.region}, үнэлгээ ${summary.label}'
              : '${place.name}, ${place.region}, шинэ газар',
          excludeSemantics: true,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: PlaceImage(place: place)),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                place.region,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              summary.hasRating ? summary.label : 'Шинэ',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

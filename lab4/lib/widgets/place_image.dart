import 'package:flutter/material.dart';

import '../models/place.dart';

/// A destination photograph: the user's own picture if there is one, otherwise
/// the bundled asset. A broken image keeps its size and shows an icon.
class PlaceImage extends StatelessWidget {
  const PlaceImage({
    super.key,
    required this.place,
    this.provider,
    this.width,
    this.height,
  });

  final Place place;

  /// Overrides [Place.imageProvider], e.g. for one page of a gallery.
  final ImageProvider? provider;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) => Image(
    image: provider ?? place.imageProvider,
    width: width,
    height: height,
    fit: BoxFit.cover,
    excludeFromSemantics: true,
    errorBuilder: (context, error, stackTrace) {
      final colors = Theme.of(context).colorScheme;
      return Container(
        width: width,
        height: height,
        color: colors.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(
          Icons.broken_image_outlined,
          color: colors.onSurfaceVariant,
        ),
      );
    },
  );
}

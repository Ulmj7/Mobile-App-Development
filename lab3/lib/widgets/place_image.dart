import 'package:flutter/material.dart';

import '../models/place.dart';

class PlaceImage extends StatelessWidget {
  const PlaceImage({super.key, required this.place, this.width, this.height});

  final Place place;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) => Image.asset(
    place.image,
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

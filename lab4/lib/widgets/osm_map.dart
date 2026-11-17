import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../config.dart';

/// Replaces the network tile source (widget tests have no network).
@visibleForTesting
TileProvider? tileProviderOverride;

/// OpenStreetMap raster tiles. The usage policy requires an identifying
/// User-Agent ([appPackageName]) and visible attribution ([osmAttribution]).
TileLayer osmTileLayer() => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: appPackageName,
  maxNativeZoom: 19,
  tileProvider: tileProviderOverride,
);

/// "© OpenStreetMap contributors", bottom right. Unlike flutter_map's
/// SimpleAttributionWidget it wraps instead of overflowing at large text sizes.
Widget osmAttribution() => const _OsmAttribution();

class _OsmAttribution extends StatelessWidget {
  const _OsmAttribution();

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Align(
      alignment: Alignment.bottomRight,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Text(
            '© OpenStreetMap contributors',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    ),
  );
}

/// "+" / "−" buttons for a map (mouse and keyboard users have no pinch).
/// Place inside a [Stack] that holds the [FlutterMap]; sits above the
/// attribution at the bottom right.
class MapZoomButtons extends StatelessWidget {
  const MapZoomButtons({super.key, required this.controller});

  final MapController controller;

  void _zoom(double delta) {
    final camera = controller.camera;
    controller.move(
      camera.center,
      (camera.zoom + delta).clamp(camera.minZoom ?? 3, camera.maxZoom ?? 18),
    );
  }

  @override
  Widget build(BuildContext context) => Positioned(
    right: 8,
    bottom: 40,
    child: Column(
      children: [
        IconButton.filledTonal(
          tooltip: 'Томруулах',
          icon: const Icon(Icons.add),
          onPressed: () => _zoom(1),
        ),
        const SizedBox(height: 4),
        IconButton.filledTonal(
          tooltip: 'Жижигрүүлэх',
          icon: const Icon(Icons.remove),
          onPressed: () => _zoom(-1),
        ),
      ],
    ),
  );
}

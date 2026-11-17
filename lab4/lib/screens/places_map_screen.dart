import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../data/places.dart';
import '../widgets/osm_map.dart';

/// "Газрын зураг": every destination that has coordinates as a marker. Tapping
/// a marker opens that destination's detail screen (task 2 #2).
class PlacesMapScreen extends StatefulWidget {
  const PlacesMapScreen({super.key});

  @override
  State<PlacesMapScreen> createState() => _PlacesMapScreenState();
}

class _PlacesMapScreenState extends State<PlacesMapScreen> {
  final _map = MapController();

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Газрын зураг')),
      body: ListenableBuilder(
        listenable: placesVersion,
        builder: (context, _) {
          final located = [
            for (final place in places)
              if (place.hasLocation) place,
          ];
          final points = [
            for (final place in located)
              LatLng(place.latitude!, place.longitude!),
          ];
          return Stack(
            children: [
              FlutterMap(
                mapController: _map,
                options: MapOptions(
                  initialCameraFit: points.length > 1
                      ? CameraFit.coordinates(
                          coordinates: points,
                          padding: const EdgeInsets.all(56),
                          maxZoom: 8,
                        )
                      : null,
                  initialCenter: const LatLng(46.8625, 103.8467),
                  initialZoom: 4.6,
                  minZoom: 3,
                  maxZoom: 18,
                ),
                children: [
                  osmTileLayer(),
                  MarkerLayer(
                    markers: [
                      for (final place in located)
                        Marker(
                          point: LatLng(place.latitude!, place.longitude!),
                          width: 36,
                          height: 36,
                          alignment: Alignment.topCenter,
                          child: Tooltip(
                            message: place.name,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () =>
                                  context.push('/explore/place/${place.id}'),
                              child: Semantics(
                                button: true,
                                label: place.name,
                                excludeSemantics: true,
                                child: Icon(
                                  Icons.location_pin,
                                  size: 36,
                                  color: place.isUserAdded
                                      ? scheme.tertiary
                                      : scheme.error,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  osmAttribution(),
                ],
              ),
              // Nearby places (Terelj / Khustai) overlap at country zoom.
              MapZoomButtons(controller: _map),
            ],
          );
        },
      ),
    );
  }
}

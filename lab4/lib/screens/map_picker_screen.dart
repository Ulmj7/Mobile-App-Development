import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../models/picked_location.dart';
import '../services/geocoding_service.dart';
import '../utils/geo.dart';
import '../widgets/osm_map.dart';

class MapPickerArgs {
  const MapPickerArgs({
    this.initial,
    this.readOnly = false,
    this.title = 'Байршил сонгох',
  });

  /// Where the marker starts, e.g. a place that already has a location.
  final PickedLocation? initial;

  /// Just show [initial]: no tapping, searching or confirming.
  final bool readOnly;
  final String title;
}

/// Full-screen map. Search for a place or tap the map to drop a pin, then
/// confirm: the screen pops with the chosen [PickedLocation].
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key, this.args = const MapPickerArgs()});

  final MapPickerArgs args;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  static const _mongolia = LatLng(46.8625, 103.8467);

  final _map = MapController();
  final _searchController = TextEditingController();

  PickedLocation? _picked;
  bool _resolving = false;
  String? _error;

  List<PickedLocation> _results = const [];
  bool _searching = false;
  String? _searchError;

  /// Only the newest reverse lookup may update the screen.
  int _requestId = 0;

  /// Same for searches: a tap, a clear or a newer search makes a slow answer
  /// stale, so it can no longer move the pin or bring the results back.
  int _searchId = 0;

  bool get _readOnly => widget.args.readOnly;

  @override
  void initState() {
    super.initState();
    _picked = widget.args.initial;
  }

  @override
  void dispose() {
    _map.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectPoint(LatLng point) async {
    final id = ++_requestId;
    _searchId++; // a search still in flight must not override this tap
    setState(() {
      _picked = PickedLocation(
        latitude: point.latitude,
        longitude: point.longitude,
      );
      _resolving = true;
      _searching = false;
      _error = null;
      _searchError = null;
      _results = const [];
    });
    try {
      final resolved = await Geocoding.reverse(point.latitude, point.longitude);
      if (!mounted || id != _requestId) return;
      setState(() {
        _picked = resolved;
        _resolving = false;
      });
    } on GeocodingException catch (e) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _resolving = false;
        _error = e.message;
      });
    } catch (_) {
      // Anything unexpected must not leave the progress bar running.
      if (!mounted || id != _requestId) return;
      setState(() {
        _resolving = false;
        _error = 'Хаяг тодорхойлж чадсангүй. Дахин оролдоно уу.';
      });
    }
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _searching) return;
    final id = ++_searchId;
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _searchError = null;
      _results = const [];
    });
    try {
      final found = await Geocoding.search(query);
      if (!mounted || id != _searchId) return;
      if (found.length == 1) {
        _choose(found.single);
        setState(() => _searching = false);
      } else {
        setState(() {
          _results = found;
          _searching = false;
          _searchError = found.isEmpty
              ? 'Юу ч олдсонгүй. Өөр нэрээр хайна уу.'
              : null;
        });
      }
    } on GeocodingException catch (e) {
      if (!mounted || id != _searchId) return;
      setState(() {
        _searching = false;
        _searchError = e.message;
      });
    } catch (_) {
      if (!mounted || id != _searchId) return;
      setState(() {
        _searching = false;
        _searchError = 'Хайлт амжилтгүй боллоо. Дахин оролдоно уу.';
      });
    }
  }

  void _clearSearch() {
    _searchId++; // forget a search still in flight
    setState(() {
      _searchController.clear();
      _searching = false;
      _results = const [];
      _searchError = null;
    });
  }

  void _choose(PickedLocation location) {
    _requestId++; // drop any reverse lookup still in flight
    _searchId++;
    setState(() {
      _picked = location;
      _resolving = false;
      _searching = false;
      _error = null;
      _results = const [];
    });
    _map.move(LatLng(location.latitude, location.longitude), 10);
  }

  @override
  Widget build(BuildContext context) {
    final picked = _picked;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      // The keyboard covers the map instead of squeezing the layout: on a small
      // phone the info panel plus a shrunken map would overflow.
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(widget.args.title)),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _map,
                  options: MapOptions(
                    initialCenter: picked == null
                        ? _mongolia
                        : LatLng(picked.latitude, picked.longitude),
                    initialZoom: picked == null ? 4.6 : 10,
                    minZoom: 3,
                    maxZoom: 18,
                    onTap: _readOnly
                        ? null
                        : (tap, point) => _selectPoint(point),
                  ),
                  children: [
                    osmTileLayer(),
                    if (picked != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(picked.latitude, picked.longitude),
                            width: 48,
                            height: 48,
                            alignment: Alignment.topCenter,
                            child: Icon(
                              Icons.location_pin,
                              size: 48,
                              color: scheme.error,
                              semanticLabel: 'Сонгосон байршил',
                            ),
                          ),
                        ],
                      ),
                    osmAttribution(),
                  ],
                ),
                if (!_readOnly)
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: _SearchPanel(
                          controller: _searchController,
                          searching: _searching,
                          error: _searchError,
                          results: _results,
                          onSubmit: _search,
                          onClear: _clearSearch,
                          onPick: _choose,
                        ),
                      ),
                    ),
                  ),
                MapZoomButtons(controller: _map),
              ],
            ),
          ),
          _InfoPanel(
            picked: picked,
            resolving: _resolving,
            error: _error,
            readOnly: _readOnly,
            onConfirm: picked == null || _resolving
                ? null
                : () => context.pop(picked),
          ),
        ],
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.controller,
    required this.searching,
    required this.error,
    required this.results,
    required this.onSubmit,
    required this.onClear,
    required this.onPick,
  });

  final TextEditingController controller;
  final bool searching;
  final String? error;
  final List<PickedLocation> results;
  final VoidCallback onSubmit;
  final VoidCallback onClear;
  final ValueChanged<PickedLocation> onPick;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 4,
    margin: EdgeInsets.zero,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => onSubmit(),
          decoration: InputDecoration(
            hintText: 'Газрын нэрээр хайх',
            prefixIcon: const Icon(Icons.search),
            border: InputBorder.none,
            suffixIcon: searching
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        semanticsLabel: 'Хайж байна',
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Арилгах',
                        icon: const Icon(Icons.clear),
                        onPressed: onClear,
                      ),
                      IconButton(
                        tooltip: 'Хайх',
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: onSubmit,
                      ),
                    ],
                  ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (results.length > 1) ...[
          const Divider(height: 1),
          // Flexible: on a short window the list shrinks instead of overflowing.
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: results.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final r = results[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.place_outlined),
                    title: Text(
                      r.name ?? r.region ?? r.address ?? r.coordinates,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: r.address == null
                        ? null
                        : Text(
                            r.address!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    onTap: () => onPick(r),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.picked,
    required this.resolving,
    required this.error,
    required this.readOnly,
    required this.onConfirm,
  });

  final PickedLocation? picked;
  final bool resolving;
  final String? error;
  final bool readOnly;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = picked;
    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        // Big text / landscape: scroll rather than overflow.
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.5,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (resolving) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 12),
                ],
                if (p == null)
                  Text(
                    'Газрын зураг дээр дарж эсвэл хайж байршлаа тэмдэглэнэ үү.',
                    style: theme.textTheme.bodyMedium,
                  )
                else ...[
                  Text(
                    p.name ??
                        p.region ??
                        (resolving ? 'Хаяг хайж байна…' : 'Сонгосон байршил'),
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (p.address != null)
                    Text(
                      p.address!,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${p.coordinates} · Улаанбаатараас ~'
                    '${distanceFromUbKm(p.latitude, p.longitude)} км (шулуун шугамаар)',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                ],
                if (!readOnly) ...[
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: onConfirm,
                    icon: const Icon(Icons.check),
                    label: const Text('Энэ байршлыг сонгох'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

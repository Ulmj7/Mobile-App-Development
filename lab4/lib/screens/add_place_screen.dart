import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../config.dart';
import '../data/places.dart';
import '../models/picked_location.dart';
import '../models/place.dart';
import '../utils/geo.dart';
import 'map_picker_screen.dart';

/// Form for a new destination. Pops with the new [Place] on save.
class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _region = TextEditingController();
  final _description = TextEditingController();
  final _distance = TextEditingController();
  final _picker = ImagePicker();

  String _season = 'Зун';
  PickedLocation? _location;
  final _images = <Uint8List>[];
  bool _picking = false;

  // True while a field still holds the value the map filled in, so picking a
  // second spot may replace it but never overwrites what the user typed.
  bool _regionAuto = false;
  bool _distanceAuto = false;

  @override
  void dispose() {
    _name.dispose();
    _region.dispose();
    _description.dispose();
    _distance.dispose();
    super.dispose();
  }

  String? _required(String? value, {int min = 2}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Заавал бөглөнө үү';
    if (v.length < min) return 'Хамгийн багадаа $min тэмдэгт';
    return null;
  }

  String? _validateDistance(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null; // optional
    final km = int.tryParse(v);
    if (km == null) return 'Бүхэл тоо оруулна уу';
    if (km < 1 || km > 5000) return 'Зай 1–5000 км байх ёстой';
    return null;
  }

  Future<void> _pickOnMap() async {
    final picked = await context.push<PickedLocation>(
      '/map',
      extra: MapPickerArgs(initial: _location),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _location = picked;
      final region = picked.region ?? picked.address;
      if (region != null && (_region.text.trim().isEmpty || _regionAuto)) {
        _region.text = region;
        _regionAuto = true;
      }
      if (_name.text.trim().isEmpty && picked.name != null) {
        _name.text = picked.name!;
      }
      if (_distance.text.trim().isEmpty || _distanceAuto) {
        _distance.text =
            '${distanceFromUbKm(picked.latitude, picked.longitude)}';
        _distanceAuto = true;
      }
    });
  }

  void _clearLocation() => setState(() => _location = null);

  Future<void> _pickImages(ImageSource source) async {
    final room = maxUserImages - _images.length;
    if (room <= 0 || _picking) return;
    setState(() => _picking = true);
    try {
      final List<XFile> files;
      if (source == ImageSource.camera) {
        final file = await _picker.pickImage(
          source: source,
          maxWidth: 1600,
          imageQuality: 85,
        );
        files = [?file];
      } else if (room == 1) {
        // pickMultiImage needs a limit of at least 2.
        final file = await _picker.pickImage(
          source: source,
          maxWidth: 1600,
          imageQuality: 85,
        );
        files = [?file];
      } else {
        files = await _picker.pickMultiImage(
          maxWidth: 1600,
          imageQuality: 85,
          limit: room,
        );
      }
      final bytes = [
        for (final file in files.take(room)) await file.readAsBytes(),
      ];
      if (!mounted || bytes.isEmpty) return;
      // Re-check against the list as it is now, not as it was before the picker.
      final left = maxUserImages - _images.length;
      setState(() => _images.addAll(bytes.take(left)));
      if (files.length > room || bytes.length > left) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Дээд тал нь 3 зураг оруулж болно')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Зураг сонгож чадсангүй')));
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final place = Place(
      id: 'user-${DateTime.now().microsecondsSinceEpoch}',
      name: _name.text.trim(),
      region: _region.text.trim(),
      image: 'assets/images/placeholder.jpg',
      description: _description.text.trim(),
      rating: 0,
      distanceKm: int.tryParse(_distance.text.trim()) ?? 0,
      bestSeason: _season,
      latitude: _location?.latitude,
      longitude: _location?.longitude,
      imageBytes: List.unmodifiable(_images),
    );
    context.pop(place);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Газар нэмэх')),
    body: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Газрын нэр',
                  border: OutlineInputBorder(),
                ),
                validator: _required,
              ),
              const SizedBox(height: 16),
              _LocationSummary(
                location: _location,
                onPick: _pickOnMap,
                onClear: _clearLocation,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _region,
                textInputAction: TextInputAction.next,
                onChanged: (_) => _regionAuto = false,
                decoration: const InputDecoration(
                  labelText: 'Аймаг / байршил',
                  border: OutlineInputBorder(),
                ),
                validator: _required,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _distance,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onChanged: (_) => _distanceAuto = false,
                decoration: const InputDecoration(
                  labelText: 'Улаанбаатараас зай (км)',
                  helperText: 'Заавал биш. Газрын зургаас сонговол шулуун шугамаар автоматаар бодогдоно.',
                  helperMaxLines: 2,
                  border: OutlineInputBorder(),
                ),
                validator: _validateDistance,
              ),
              const SizedBox(height: 16),
              Text(
                'Хамгийн тохиромжтой улирал',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final season in seasons)
                    ChoiceChip(
                      label: Text(season),
                      selected: _season == season,
                      onSelected: (_) => setState(() => _season = season),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _description,
                maxLines: 4,
                maxLength: 300,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Тайлбар',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _required(v, min: 10),
              ),
              const SizedBox(height: 8),
              _ImagePickerField(
                images: _images,
                busy: _picking,
                onAdd: _pickImages,
                onRemove: (i) => setState(() => _images.removeAt(i)),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Хадгалах'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ImagePickerField extends StatelessWidget {
  const _ImagePickerField({
    required this.images,
    required this.busy,
    required this.onAdd,
    required this.onRemove,
  });

  final List<Uint8List> images;
  final bool busy;
  final ValueChanged<ImageSource> onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final full = images.length >= maxUserImages || busy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Зураг (заавал биш, ${images.length}/$maxUserImages)',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (images.isEmpty)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Зураг оруулах (заавал биш)',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      images[i],
                      width: 160,
                      height: 120,
                      fit: BoxFit.cover,
                      semanticLabel: 'Оруулсан зураг ${i + 1}',
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: IconButton.filledTonal(
                      tooltip: 'Зургийг хасах',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => onRemove(i),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: full ? null : () => onAdd(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(images.isEmpty ? 'Галерейгаас' : 'Зураг нэмэх'),
            ),
            if (cameraSupported)
              OutlinedButton.icon(
                onPressed: full ? null : () => onAdd(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Камераар'),
              ),
          ],
        ),
      ],
    );
  }
}

class _LocationSummary extends StatelessWidget {
  const _LocationSummary({
    required this.location,
    required this.onPick,
    required this.onClear,
  });

  final PickedLocation? location;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final loc = location;
    if (loc == null) {
      return OutlinedButton.icon(
        onPressed: onPick,
        icon: const Icon(Icons.map_outlined),
        label: const Text('Газрын зураг дээр байршил тэмдэглэх'),
      );
    }
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(Icons.push_pin_outlined),
        title: Text(
          loc.name ?? loc.region ?? 'Сонгосон байршил',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          loc.address == null
              ? loc.coordinates
              : '${loc.coordinates}\n${loc.address}',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: loc.address != null,
        onTap: onPick,
        trailing: IconButton(
          tooltip: 'Байршлыг арилгах',
          icon: const Icon(Icons.close),
          onPressed: onClear,
        ),
      ),
    );
  }
}

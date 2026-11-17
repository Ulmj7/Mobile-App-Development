import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/places.dart';
import '../models/place.dart';
import '../state/ratings.dart';
import '../widgets/place_card.dart';
import 'place_search.dart';

/// "Газрууд": the catalogue grid with search, season filter, rating sort and a
/// button to add a destination.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// null means "Бүгд" (all seasons).
  String? _season;
  bool _sortByRating = false;

  bool get _filtered => _season != null || _sortByRating;

  List<Place> _visible(Map<String, int> ratings) {
    final list = [
      for (final place in places)
        if (_season == null || place.bestSeason == _season) place,
    ];
    if (_sortByRating) {
      // List.sort is not stable; decorate with the original index so equal
      // ratings keep their catalogue order.
      final order = {for (var i = 0; i < list.length; i++) list[i].id: i};
      list.sort((a, b) {
        final byRating = ratingOf(
          b,
          ratings,
        ).average.compareTo(ratingOf(a, ratings).average);
        return byRating != 0 ? byRating : order[a.id]!.compareTo(order[b.id]!);
      });
    }
    return list;
  }

  Future<void> _openSearch() async {
    final place = await showSearch<Place?>(
      context: context,
      delegate: PlaceSearch(places: List.of(places)),
    );
    if (place != null && mounted) context.push('/places/place/${place.id}');
  }

  Future<void> _openFilters() => showModalBottomSheet<void>(
    context: context,
    // Cover the navigation rail too, so the sheet is modal for the whole app.
    useRootNavigator: true,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) {
        void update(void Function() change) {
          setState(change);
          setSheetState(() {});
        }

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Text(
                    'Улирал',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                for (final season in [null, ...seasons])
                  ListTile(
                    title: Text(season ?? 'Бүгд'),
                    trailing: _season == season
                        ? const Icon(Icons.check)
                        : null,
                    selected: _season == season,
                    onTap: () => update(() => _season = season),
                  ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Үнэлгээгээр эрэмбэлэх'),
                  subtitle: const Text('Өндөр дундаж үнэлгээтэй газар эхэнд'),
                  value: _sortByRating,
                  onChanged: (value) => update(() => _sortByRating = value),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text('Болсон'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  Future<void> _addPlace() async {
    final place = await context.push<Place>('/places/add');
    if (place == null) return;
    addPlace(place);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('«${place.name}» нэмэгдлээ')));
  }

  static int _columns(double width) => width < 600
      ? 2
      : width < 900
      ? 3
      : width < 1200
      ? 4
      : 5;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Аяллын газрууд'),
      actions: [
        IconButton(
          tooltip: 'Хайх',
          icon: const Icon(Icons.search),
          onPressed: _openSearch,
        ),
        IconButton(
          tooltip: 'Шүүлтүүр',
          isSelected: _filtered,
          icon: const Icon(Icons.filter_list),
          selectedIcon: const Icon(Icons.filter_alt),
          onPressed: _openFilters,
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      tooltip: 'Газар нэмэх',
      onPressed: _addPlace,
      child: const Icon(Icons.add_location_alt),
    ),
    body: ListenableBuilder(
      listenable: Listenable.merge([placesVersion, userRatings]),
      builder: (context, _) {
        final visible = _visible(userRatings.value);
        return Column(
          children: [
            if (_filtered)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (_season != null)
                        InputChip(
                          label: Text(_season!),
                          onDeleted: () => setState(() => _season = null),
                          deleteButtonTooltipMessage:
                              'Улирлын шүүлтүүрийг арилгах',
                        ),
                      if (_sortByRating)
                        InputChip(
                          label: const Text('Үнэлгээгээр'),
                          avatar: const Icon(
                            Icons.star,
                            size: 18,
                            color: Colors.amber,
                          ),
                          onDeleted: () =>
                              setState(() => _sortByRating = false),
                          deleteButtonTooltipMessage: 'Эрэмбийг арилгах',
                        ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: visible.isEmpty
                  ? _EmptyFilter(onClear: () => setState(() => _season = null))
                  : LayoutBuilder(
                      builder: (context, constraints) => GridView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _columns(constraints.maxWidth),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: visible.length,
                        itemBuilder: (context, i) => PlaceCard(
                          key: ValueKey(visible[i].id),
                          place: visible[i],
                          onTap: () =>
                              context.push('/places/place/${visible[i].id}'),
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    ),
  );
}

class _EmptyFilter extends StatelessWidget {
  const _EmptyFilter({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.travel_explore,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          const Text(
            'Энэ улиралд тохирох газар алга',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onClear,
            child: const Text('Шүүлтүүр арилгах'),
          ),
        ],
      ),
    ),
  );
}

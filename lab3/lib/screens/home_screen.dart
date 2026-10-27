import 'package:flutter/material.dart';

import '../data/places.dart';
import '../models/place.dart';
import '../widgets/app_drawer.dart';
import '../widgets/place_card.dart';
import 'detail_screen.dart';
import 'place_search.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _favoriteIds = ValueNotifier<Set<String>>({});
  Place _selected = places.first;
  bool _favoritesOnly = false;

  @override
  void dispose() {
    _favoriteIds.dispose();
    super.dispose();
  }

  void _toggleFavorite(Place place) {
    final next = Set<String>.of(_favoriteIds.value);
    if (!next.add(place.id)) next.remove(place.id);
    _favoriteIds.value = next;
  }

  void _openPlace(Place place) {
    setState(() => _selected = place);
    if (MediaQuery.sizeOf(context).width >= 840) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailScreen(
          place: place,
          favoriteIds: _favoriteIds,
          onToggleFavorite: () => _toggleFavorite(place),
        ),
      ),
    );
  }

  Future<void> _search() async {
    final place = await showSearch<Place?>(
      context: context,
      delegate: PlaceSearch(places: places),
    );
    if (!mounted || place == null) return;
    if (_favoritesOnly && !_favoriteIds.value.contains(place.id)) {
      setState(() => _favoritesOnly = false);
    }
    _openPlace(place);
  }

  void _showAddPlace() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.68,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Газар нэмэх',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Text('Дуртай газрууддаа нэмэх газраа сонгоно уу.'),
              ),
              Expanded(
                child: ValueListenableBuilder<Set<String>>(
                  valueListenable: _favoriteIds,
                  builder: (context, favorites, child) => ListView.builder(
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final place = places[index];
                      return CheckboxListTile(
                        secondary: CircleAvatar(
                          backgroundImage: AssetImage(place.image),
                        ),
                        title: Text(place.name),
                        subtitle: Text(place.region),
                        value: favorites.contains(place.id),
                        onChanged: (_) => _toggleFavorite(place),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'TRAVEL APP',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.travel_explore,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: const [
        Text('Монгол орны байгалийн үзэсгэлэнт 10 газартай танилцаарай.'),
        SizedBox(height: 12),
        Text(
          'Зайг Улаанбаатараас авто замаар явах ойролцоо хэмжээгээр '
          'харуулсан. Үнэлгээнүүд нь танилцуулах жишээ утга. '
          'Дуртай газрууд апп нээлттэй байх хугацаанд хадгалагдана.',
        ),
      ],
    );
  }

  Widget _buildWide(List<Place> visible) {
    final selected = visible.firstWhere(
      (place) => place.id == _selected.id,
      orElse: () => visible.first,
    );
    return Row(
      children: [
        SizedBox(
          width: 340,
          child: ListView(
            key: PageStorageKey('list-$_favoritesOnly'),
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              for (final place in visible)
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(place.image),
                  ),
                  title: Text(place.name),
                  subtitle: Text(place.region),
                  selected: place.id == selected.id,
                  onTap: () => setState(() => _selected = place),
                ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: PlaceDetailView(place: selected)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Set<String>>(
    valueListenable: _favoriteIds,
    builder: (context, favorites, child) {
      final visible = _favoritesOnly
          ? places.where((place) => favorites.contains(place.id)).toList()
          : places;

      return Scaffold(
        appBar: AppBar(
          title: Text(
            _favoritesOnly
                ? 'Дуртай газрууд'
                : MediaQuery.sizeOf(context).width < 600
                ? 'TRAVEL APP'
                : 'TRAVEL APP-д тавтай морил',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Хайх',
              onPressed: _search,
            ),
          ],
        ),
        drawer: AppDrawer(
          favoritesOnly: _favoritesOnly,
          onAllPlaces: () => setState(() => _favoritesOnly = false),
          onFavorites: () => setState(() => _favoritesOnly = true),
          onAbout: _showAbout,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddPlace,
          tooltip: 'Газар нэмэх',
          child: const Icon(Icons.add_location_alt),
        ),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (visible.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Дуртай газар алга',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '«Газар нэмэх» товчоор дуртай газраа сонгоорой.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (constraints.maxWidth >= 840) return _buildWide(visible);
              final columns = constraints.maxWidth >= 600 ? 3 : 2;

              return GridView.builder(
                key: PageStorageKey('grid-$_favoritesOnly'),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: visible.length,
                itemBuilder: (context, index) => PlaceCard(
                  place: visible[index],
                  onTap: () => _openPlace(visible[index]),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}

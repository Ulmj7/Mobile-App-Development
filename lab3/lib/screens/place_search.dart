import 'package:flutter/material.dart';

import '../models/place.dart';

class PlaceSearch extends SearchDelegate<Place?> {
  PlaceSearch({required this.places})
    : super(searchFieldLabel: 'Газрын нэр, аймаг, улирал');

  final List<Place> places;

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        tooltip: 'Арилгах',
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    tooltip: 'Буцах',
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    final term = query.trim().toLowerCase();
    final matches = places
        .where(
          (place) => [
            place.id,
            place.name,
            place.region,
            place.bestSeason,
          ].any((value) => value.toLowerCase().contains(term)),
        )
        .toList();

    if (matches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Газар олдсонгүй.\nӨөр нэр, аймаг эсвэл улирлаар хайна уу.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final place = matches[index];
        return ListTile(
          leading: CircleAvatar(backgroundImage: AssetImage(place.image)),
          title: Text(place.name),
          subtitle: Text(place.region),
          onTap: () => close(context, place),
        );
      },
    );
  }
}

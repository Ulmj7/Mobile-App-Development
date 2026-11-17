import 'package:flutter/foundation.dart';

/// Ids of the favourite destinations. Kept for the current session only.
final favoriteIds = ValueNotifier<Set<String>>({});

bool isFavorite(String id) => favoriteIds.value.contains(id);

void setFavorite(String id, bool value) {
  if (value == isFavorite(id)) return;
  // A fresh set, so ValueNotifier sees a change.
  favoriteIds.value = value
      ? {...favoriteIds.value, id}
      : ({...favoriteIds.value}..remove(id));
}

void toggleFavorite(String id) => setFavorite(id, !isFavorite(id));

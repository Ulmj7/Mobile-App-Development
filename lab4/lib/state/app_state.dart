import 'package:flutter/material.dart';

import '../data/places.dart';
import 'auth_service.dart';
import 'favorites.dart';
import 'ratings.dart';
import 'settings.dart';

/// Puts every in-memory store back to its first-launch value (tests).
@visibleForTesting
void resetAppState({bool loggedIn = false}) {
  favoriteIds.value = {};
  userRatings.value = {};
  themeMode.value = ThemeMode.system;
  resetPlaces();
  auth.reset(loggedIn: loggedIn);
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/places.dart';
import 'screens/add_place_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/map_picker_screen.dart';
import 'screens/places_map_screen.dart';
import 'screens/settings_screen.dart';
import 'state/auth_service.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Below this width the app uses a bottom bar, from it a side rail.
const railBreakpoint = 600.0;

const _topLevelPaths = {'/places', '/favorites', '/explore', '/settings'};

/// Detail page for a catalogue place; unknown ids (e.g. a stale link) show a
/// short message instead of crashing.
Widget _detail(String? id) {
  for (final place in places) {
    if (place.id == id) return DetailScreen(place: place);
  }
  return Scaffold(
    appBar: AppBar(),
    body: const Center(child: Text('Газар олдсонгүй')),
  );
}

/// A new router each call, so tests (and hot restarts) never share history.
GoRouter buildRouter() => GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/places',
  refreshListenable: auth,
  redirect: (context, state) {
    final onLogin = state.matchedLocation == '/login';
    if (!auth.loggedIn) return onLogin ? null : '/login';
    return onLogin ? '/places' : null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    // Full-screen: no navigation rail / bar while picking or viewing a point.
    GoRoute(
      path: '/map',
      parentNavigatorKey: _rootKey,
      builder: (context, state) => MapPickerScreen(
        args: state.extra is MapPickerArgs
            ? state.extra! as MapPickerArgs
            : const MapPickerArgs(),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) =>
          AppShell(shell: shell, path: state.uri.path),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/places',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'place/:id',
                  builder: (context, state) =>
                      _detail(state.pathParameters['id']),
                ),
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const AddPlaceScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
              routes: [
                GoRoute(
                  path: 'place/:id',
                  builder: (context, state) =>
                      _detail(state.pathParameters['id']),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              builder: (context, state) => const PlacesMapScreen(),
              routes: [
                GoRoute(
                  path: 'place/:id',
                  builder: (context, state) =>
                      _detail(state.pathParameters['id']),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'password',
                  builder: (context, state) => const ChangePasswordScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

/// Wraps the four main sections with a NavigationRail (wide) or a
/// NavigationBar (narrow). The bar is hidden on sub-pages so forms and
/// details get the full height of a phone.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell, required this.path});

  final StatefulNavigationShell shell;
  final String path;

  static const _destinations = [
    (Icons.explore_outlined, Icons.explore, 'Газрууд'),
    (Icons.favorite_border, Icons.favorite, 'Дуртай'),
    (Icons.map_outlined, Icons.map, 'Газрын зураг'),
    (Icons.settings_outlined, Icons.settings, 'Тохиргоо'),
  ];

  void _select(int index) =>
      shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= railBreakpoint;
    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                selectedIndex: shell.currentIndex,
                onDestinationSelected: _select,
                labelType: NavigationRailLabelType.all,
                destinations: [
                  for (final (icon, selected, label) in _destinations)
                    NavigationRailDestination(
                      icon: Icon(icon),
                      selectedIcon: Icon(selected),
                      label: Text(label),
                    ),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: shell),
          ],
        ),
      );
    }
    return Scaffold(
      body: shell,
      bottomNavigationBar: _topLevelPaths.contains(path)
          ? NavigationBar(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _select,
              destinations: [
                for (final (icon, selected, label) in _destinations)
                  NavigationDestination(
                    icon: Icon(icon),
                    selectedIcon: Icon(selected),
                    label: label,
                  ),
              ],
            )
          : null,
    );
  }
}

import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    this.favoritesOnly = false,
    this.onAllPlaces,
    this.onFavorites,
    this.onAbout,
  });

  final bool favoritesOnly;
  final VoidCallback? onAllPlaces;
  final VoidCallback? onFavorites;
  final VoidCallback? onAbout;

  void _navigate(BuildContext context, VoidCallback? action) {
    Navigator.of(context).pop();
    action?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Аяллын газрууд',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Бүх газар'),
            selected: !favoritesOnly,
            onTap: () => _navigate(context, onAllPlaces),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Дуртай'),
            selected: favoritesOnly,
            onTap: () => _navigate(context, onFavorites),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Тухай'),
            onTap: () => _navigate(context, onAbout),
          ),
        ],
      ),
    );
  }
}

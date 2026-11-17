import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_service.dart';
import '../state/settings.dart';

/// "Тохиргоо": account, appearance, about and sign-out.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static String _themeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'Системийн тохиргоо',
    ThemeMode.light => 'Цайвар',
    ThemeMode.dark => 'Бараан',
  };

  Future<void> _chooseTheme(BuildContext context) => showDialog<void>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      title: const Text('Харагдац'),
      children: [
        for (final mode in ThemeMode.values)
          ListTile(
            title: Text(_themeLabel(mode)),
            trailing: themeMode.value == mode ? const Icon(Icons.check) : null,
            onTap: () {
              themeMode.value = mode;
              Navigator.of(dialogContext).pop();
            },
          ),
      ],
    ),
  );

  void _about(BuildContext context) => showAboutDialog(
    context: context,
    applicationName: 'TRAVEL APP',
    applicationVersion: '1.1.0',
    applicationIcon: Icon(
      Icons.travel_explore,
      size: 48,
      color: Theme.of(context).colorScheme.primary,
    ),
    children: const [
      Text(
        'Монгол орны байгалийн үзэсгэлэнт газруудтай танилцаж, өөрийн '
        'газраа нэмж, үнэлээрэй.',
      ),
      SizedBox(height: 12),
      Text(
        'Зайг Улаанбаатараас авто замаар явах ойролцоо хэмжээгээр '
        'харуулсан. Үнэлгээнүүд нь танилцуулах жишээ утга. Дуртай газар, '
        'үнэлгээ, нэмсэн газрууд апп нээлттэй байх хугацаанд хадгалагдана. '
        'Газрын зураг: © OpenStreetMap contributors.',
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Тохиргоо')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              ListenableBuilder(
                listenable: auth,
                builder: (context, _) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    foregroundColor: scheme.onPrimaryContainer,
                    child: const Icon(Icons.person),
                  ),
                  title: Text(auth.email.isEmpty ? 'Зочин' : auth.email),
                  subtitle: const Text('Нэвтэрсэн хэрэглэгч'),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.lock_reset),
                title: const Text('Нууц үг солих'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/password'),
              ),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeMode,
                builder: (context, mode, _) => ListTile(
                  leading: const Icon(Icons.brightness_6_outlined),
                  title: const Text('Харагдац'),
                  subtitle: Text(_themeLabel(mode)),
                  onTap: () => _chooseTheme(context),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Тухай'),
                onTap: () => _about(context),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton.icon(
                  onPressed: auth.logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Гарах'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

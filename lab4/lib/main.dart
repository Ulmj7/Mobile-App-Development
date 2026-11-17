import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'state/settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Roboto Slab',
    ], await rootBundle.loadString('assets/fonts/LICENSE.txt'));
    yield LicenseEntryWithLineBreaks([
      'Destination photographs',
    ], await rootBundle.loadString('assets/PHOTO_CREDITS.txt'));
  });
  runApp(const TravelApp());
}

class TravelApp extends StatefulWidget {
  const TravelApp({super.key});

  @override
  State<TravelApp> createState() => _TravelAppState();
}

class _TravelAppState extends State<TravelApp> {
  // Owned here (not a global) so every app instance starts at the login page.
  final GoRouter _router = buildRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  ThemeData _theme(Brightness brightness) => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: brightness,
    ),
    fontFamily: 'RobotoSlab',
    appBarTheme: const AppBarTheme(centerTitle: false),
  );

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: themeMode,
    builder: (context, mode, _) => MaterialApp.router(
      title: 'TRAVEL APP',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: mode,
      // Flutter only drags with touch by default; the web and desktop builds
      // are used with a mouse or trackpad (photo gallery, horizontal lists).
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
        },
      ),
      routerConfig: _router,
    ),
  );
}

# TRAVEL APP — Лабораторийн ажил №3

Flutter implementation of [Лабораторийн ажил 3](../Лабораторийн%20ажил%203.pdf), including the visual references on pages 9–10. The Flutter package is named `travel_mn`; the project lives directly in `lab3/`.

## Run

Start an Android emulator or connect a phone, then run:

```sh
flutter pub get
flutter run
```

For a browser preview without Chrome:

```sh
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080
```

Open the printed address in Firefox or another browser. Resize the viewport to check the breakpoints.

## Lab requirements

- Pure Dart, immutable `Place` model with a const constructor.
- Ten destinations with Mongolian descriptions and local JPEG photographs.
- Locally bundled Roboto Slab regular and bold fonts, registered in `pubspec.yaml`.
- Material 3, `ColorScheme.fromSeed(Colors.teal)`, `textTheme`, and system light/dark themes.
- Reusable stateless `PlaceCard`, `AppDrawer`, `DetailScreen`, and Scaffold-free `PlaceDetailView`.
- `GridView.builder` inside `LayoutBuilder`: two columns below 600 dp, three at 600–839 dp.
- A 340 dp destination list and shared detail view at 840 dp and above.
- `Navigator.push` for phone/tablet details; `Stack` and `Positioned` for the photo title; `Row` and `Expanded` for the facts.
- The reference's welcome title, photo cards, drawer labels, teal location FAB, centered stars, and three detail facts.
- Search by name, province, ID, or season. The location FAB opens a destination selector to add/remove favorites. A phone detail's heart does the same; the drawer's “Дуртай” filters the catalogue.
- About and standard license screens. Photo/font credits are bundled in the app.

Favorites are intentionally kept only while the app is open. The lab does not require a database, new custom destinations, booking, a map, or an API. Ratings are illustrative lab values, not real visitor-review aggregates.

## Data and distance sources

Distances are rounded, approximate road distances **from Ulaanbaatar**, rather than straight-line distances. The endpoint, route, and access road affect the actual journey. The app describes this in “Тухай”.

| Place | Region | Approx. km | Source |
|---|---|---:|---|
| Горхи-Тэрэлж | Төв аймаг | 70 | [Gorkhi–Terelj location](https://www.qaghan.com/mongolia/heritage/gorkhi-terelj) — the park extends into Töv; its popular visitor area is in Nalaikh. |
| Хөвсгөл нуур | Хөвсгөл аймаг | 900 | [Road transfer to Khatgal/Jankhai](https://www.travelgobimongolia.com/car-transportation-between-ulaanbaatar-khuvsgul-lake/) |
| Хонгорын элс | Өмнөговь аймаг | 730 | [Visit Silk Road](https://visitsilkroad.org/destination/khongoryn-els/) — approximate sum of 550 km to Dalanzadgad and 180 km onward. |
| Хархорин | Өвөрхангай аймаг | 360 | [Kharkhorin](https://www.qaghan.com/mongolia/heritage/karakorum) |
| Алтай Таван Богд | Баян-Өлгий аймаг | 1920 | [View Mongolia](https://www.viewmongolia.com/altai-tavan-bogd-mountain-national-park-mongolia.html) |
| Орхоны хүрхрээ | Өвөрхангай аймаг | 495 | [Ulaan Tsutgalan](https://viewmongolia.com/ulaantsutgalan-waterfall.html) |
| Цагаан суварга | Дундговь аймаг | 420 | [View Mongolia](https://www.viewmongolia.com/tsagaan-suvarga.html) |
| Хустайн нуруу | Төв аймаг | 100 | [Hustai National Park](https://www.hustai.mn/байршил-2/) |
| Тэрхийн Цагаан нуур | Архангай аймаг | 660 | [Khorgo–Terkhiin Tsagaan](https://viewmongolia.com/khorgo-volcano-terkhiin-tsagaan-lake.html) |
| Ёлын ам | Өмнөговь аймаг | 610 | [Yol Valley](https://tourmongolia.com/portfolio/yol-valley/) — approximately 550 km to Dalanzadgad plus the access road. |

The first six destinations and their order follow the reference. The additional four complete the required collection. The PDF's sample 800 km for Khuvsgul has been replaced with a sourced approximate 900 km road journey.

## Four-season photos and attribution

All photographs show the named Mongolian locations; no generated imagery is used. Capture dates include spring (Yolyn Am, March 30), summer (Khuvsgul, the dunes, monastery, waterfall, and lake), autumn (Hustai, September; Tsagaan Suvarga, October), and winter (Altai Tavan Bogd, January 20). The recorded January capture date, rather than the mere presence of a permanent glacier, documents the winter scene. A photograph's season is independent of `bestSeason`, which describes when to visit.

[assets/PHOTO_CREDITS.txt](assets/PHOTO_CREDITS.txt) and [assets/photo_sources.json](assets/photo_sources.json) record the original file, photographer, date, license, license URL, and transformations. JPEG comments also retain the source and license. CC BY-SA photographs retain their original share-alike license.

Roboto Slab comes from the [official Google Fonts repository](https://github.com/google/fonts/tree/main/apache/robotoslab). The bundled 400/700 static instances include Mongolian Cyrillic; their Apache license and copyright notice are in [assets/fonts/LICENSE.txt](assets/fonts/LICENSE.txt).

## Verify

```sh
flutter analyze
flutter test
flutter build apk --debug
flutter build web
```

Tests cover destination/asset integrity, all layout boundaries, phone navigation/back, wide selection, search and empty results, favorites, the location selector, dark mode, and enlarged text.

Platform scaffold: Android, iOS, web. Building iOS requires macOS/Xcode.

## Saved previews and verification

Native Android captures: [phone](docs/screenshots/phone.png), [wide layout](docs/screenshots/wide.png), [drawer](docs/screenshots/drawer.png).

Verified on 2026-10-27 with Flutter 3.47.2 / Dart 3.13.2:

- Static analysis: no issues.
- Tests: all 18 passed.
- Android debug APK and Flutter web builds: successful.
- Native Android emulator: phone, three-column medium layout, expanded master/detail, navigation drawer, light/dark themes, and 1.3x system font scale.
- Independent Android UI review: **ship**, with no material findings.
- All ten JPEGs decode, match their source records, and retain attribution; both fonts include Mongolian Cyrillic.

The emulator was one Medium Phone API 37 AVD configured at different display sizes, rather than separate physical phone/tablet devices. Display, font-scale, and night-mode settings were restored afterward. iOS and live browser rendering were not tested.

The built APK is at `build/app/outputs/flutter-apk/app-debug.apk`; the web bundle is in `build/web/`. Build output is ignored by version control. The source design system is recorded in [DESIGN.md](DESIGN.md).

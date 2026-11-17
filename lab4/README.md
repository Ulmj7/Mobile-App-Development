# TRAVEL APP — Лабораторийн ажил №4

Flutter implementation of [Лабораторийн ажил 4](Лабораторийн%20ажил%204.pdf): maps (OpenStreetMap), place search (Nominatim), image upload, form validation, ratings and the five individual tasks of *Даалгавар 2*. It extends the Lab 3 catalogue; the package is still named `travel_mn` and lives directly in `lab4/`.

## Run

```sh
flutter pub get
flutter run -d chrome        # or an Android emulator / phone
```

Sign in with any e-mail containing `@` and the default password **`Mobile317`** (task 2 #1; the Lab 3 PDF's `flutter123` is not used). The map picker and the "Газрын зураг" screen need an internet connection for tiles; place search uses the public Nominatim API.

## Lab requirements (Даалгавар 1)

| Requirement | Where |
|---|---|
| Gradient login screen | `lib/screens/login_screen.dart` |
| `go_router` navigation, NavigationRail (≥ 600 dp) / NavigationBar (phones) | `lib/router.dart` |
| Search by name and by season, season filter sheet | `lib/screens/home_screen.dart`, `place_search.dart` |
| "Газар нэмэх" form: name, region, distance, description, season, photo | `lib/screens/add_place_screen.dart` |
| Gallery/camera photo with preview (`image_picker`; camera only on phones) | `add_place_screen.dart`, `lib/config.dart` |
| Map picker: search, tap to mark, reverse-geocoded province, coordinates, distance from Ulaanbaatar | `lib/screens/map_picker_screen.dart`, `lib/services/geocoding_service.dart` |
| 1–5 star rating, card average updates | `lib/state/ratings.dart`, `widgets/rating_input.dart`, `widgets/place_card.dart` |
| Favorites with undo | `lib/state/favorites.dart`, `screens/favorites_screen.dart` |
| Settings: "Нууц үг солих", theme, "Тухай", logout | `lib/screens/settings_screen.dart`, `change_password_screen.dart` |

## Individual work (Даалгавар 2)

1. **Default password** is `Mobile317` (`AuthService.defaultPassword`, shown as the login hint).
2. **Real coordinates + all-places map.** The ten places carry OpenStreetMap coordinates (table below). The new "Газрын зураг" destination (`lib/screens/places_map_screen.dart`) shows them as markers; tapping a marker opens that place's detail page.
3. **Up to three photos.** The form uses `pickMultiImage(limit: …)` (single `pickImage` when one slot is left); the detail page shows them in a swipeable `PageView` with a counter and dots.
4. **Password strength.** The change-password form rates the new password weak / medium / strong (length ≥ 8 and ≥ 12, lower case, upper case, digit, symbol) with a coloured `LinearProgressIndicator` (`lib/widgets/password_strength_meter.dart`, `lib/utils/validators.dart`).
5. **Sort by rating.** "Шүүлтүүр" → "Үнэлгээгээр эрэмбэлэх" sorts by average rating (bundled average combined with your own rating); the order changes as soon as you rate.

## Deliberate differences from the PDF

- **Package name / password:** `mn.edu.travel.travel_mn` (kept from Lab 3) instead of the sample `com.example.travel_mn`; default password `Mobile317` (task 2 #1) instead of `flutter123`.
- **Rating average:** the PDF averages a place's stored rating (weighted by its `ratingCount`) with the user's rating. With ~100–350 seeded ratings one new rating changes the average by less than 0.04, so task 2 #5 (order updates when you rate) would hardly ever be visible. `ratingOf` therefore limits the weight of the *illustrative seed* ratings to `ratingSeedWeight = 10`; the displayed rating count is still `ratingCount + 1`.
- **Add-place form wording / validation:** labels such as "Газрын нэр" and "Аймаг / байршил", and the distance range 1–5000 km, are close to but not identical with the PDF text. The form accepts up to three photos (task 2 #3).
- **Geocoding errors:** `Geocoding.reverse` throws a `GeocodingException` ("address not found") instead of returning `null`; the map picker shows it as a message and keeps the pin.
- **Navigation:** besides Газрууд / Дуртай / Тохиргоо the rail has a fourth item, "Газрын зураг" (task 2 #2).

## Place coordinates

Looked up on 2026-11-11 with OpenStreetMap Nominatim (name search, `countrycodes=mn`) and cross-checked against Wikipedia coordinates where an article exists. They are one representative point per place (an entrance, centre or landmark), not a boundary.

| Place | Latitude | Longitude | Source / note |
|---|---:|---:|---|
| Горхи-Тэрэлж | 47.88843 | 107.42282 | Nominatim (Wikipedia gives the park centroid 48.150, 107.576) |
| Хөвсгөл нуур | 51.02045 | 100.47857 | Nominatim, lake centre |
| Хонгорын элс | 43.77076 | 102.17193 | Nominatim, dunes |
| Хархорин | 47.21466 | 102.84885 | Nominatim, Karakorum site (Erdene Zuu: Wikipedia 47.202, 102.843) |
| Алтай Таван Богд | 48.61885 | 88.42564 | Nominatim, national-park centre (Wikipedia 48.55, 88.62) |
| Орхоны хүрхрээ | 46.78744 | 101.96024 | Nominatim (Wikipedia, Ulaan Tsutgalan: 46.787, 101.960) |
| Цагаан суварга | 44.57694 | 105.71771 | Nominatim, rock formation near Ölziit, Dundgovi |
| Хустайн нуруу | 47.69350 | 105.88555 | Nominatim (Wikipedia 47.765, 105.878) |
| Тэрхийн Цагаан нуур | 48.15738 | 99.65772 | Nominatim (Wikipedia 48.171, 99.722) |
| Ёлын ам | 43.50035 | 104.09740 | Nominatim (Wikipedia 43.493, 104.084) |

Distances in the list are still Lab 3's approximate **road** kilometres from Ulaanbaatar. For a destination added through the map the form fills in the **straight-line** distance (haversine) instead, and the user can overwrite it.

## Map services and usage policy

- Tiles: `https://tile.openstreetmap.org/{z}/{x}/{y}.png` with the app package name as `userAgentPackageName` and the required "© OpenStreetMap contributors" attribution. The public tile server is for light, interactive use — switch to a tile provider with an API key before publishing the app.
- Search/reverse geocoding: Nominatim with an identifying `User-Agent` (not settable in browsers), at most one request per 1.1 s, results cached in memory, 15 s timeout, Mongolian messages for 403/429/network errors.
- Android needs the `INTERNET` permission (added); iOS needs the photo-library and camera usage strings (added).

## Data and photo sources

Distances, photographs, fonts and their licenses are unchanged from Lab 3 — see [assets/PHOTO_CREDITS.txt](assets/PHOTO_CREDITS.txt) and [assets/photo_sources.json](assets/photo_sources.json). `assets/images/placeholder.jpg` (used when a user adds a place without a photo) is a generated CC0 illustration. Ratings of bundled places are illustrative lab values.

## Verify

```sh
flutter analyze
flutter test
flutter build web
flutter build apk --debug
```

Last run on 2026-11-11 (Flutter 3.47.2 / Dart 3.13.2, Linux):

| Check | Result |
| --- | --- |
| `flutter analyze` | No issues found |
| `flutter test` | 151 tests passed (unit, data integrity, geocoding with a mock HTTP client, widget tests at several widths, dark theme and 1.8× text) |
| `flutter build web` | OK |
| `flutter build apk --debug` | OK (built before the last round of fixes; `android/` has not changed since) |
| Web build in Chrome | Login with `Mobile317`; grid + rail; all-places map and marker → detail; rating → card average and live sort; add place with a live Nominatim search → province, coordinates and distance auto-filled; change password (wrong current password rejected, old password rejected after the change, new one accepted) and logout; phone width (390 dp) with the bottom bar |

Not tested: a real Android/iOS device or emulator (camera, gallery picker, multi-photo selection on a device — covered only by a fake image picker in tests), and the Linux desktop target. Photo upload in the browser was not exercised by hand.

Design notes are in [DESIGN.md](DESIGN.md), product context in [PRODUCT.md](PRODUCT.md).

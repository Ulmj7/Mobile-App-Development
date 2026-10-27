---
name: Travel MN
description: Flutter Material 3 travel catalogue matching the Lab 3 reference.
colors:
  teal-seed: "#009688"
  rating-amber: "#FFC107"
typography:
  headline-small: {fontFamily: RobotoSlab, fontSize: "24px", fontWeight: 400, lineHeight: 1.33}
  title-large: {fontFamily: RobotoSlab, fontSize: "22px", fontWeight: 400, lineHeight: 1.27}
  title-medium: {fontFamily: RobotoSlab, fontSize: "16px", fontWeight: 500, lineHeight: 1.5}
  body-large: {fontFamily: RobotoSlab, fontSize: "16px", fontWeight: 400, lineHeight: 1.5}
  body-medium: {fontFamily: RobotoSlab, fontSize: "14px", fontWeight: 400, lineHeight: 1.43}
  body-small: {fontFamily: RobotoSlab, fontSize: "12px", fontWeight: 400, lineHeight: 1.33}
rounded:
  card: "12px"
  fab: "16px"
spacing:
  grid: "12px"
  content: "16px"
  modal: "24px"
  bottom-clearance: "88px"
---

# Design System: Travel MN

## Overview

The screenshots on pages 9–10 of `../Лабораторийн ажил 3.pdf` govern the visual direction: destination photographs, Roboto Slab, and native Material 3 controls.
This document records the implemented Flutter system. Product context is in [PRODUCT.md](PRODUCT.md); surface intent is in [travel.md](.impeccable/surface-briefs/travel.md).

## Colors

[TravelApp._theme](lib/main.dart) is the source of truth: `ColorScheme.fromSeed(seedColor: Colors.teal, brightness: brightness).copyWith(tertiary: Colors.amber)`.
`ThemeMode.system` selects light or dark. The teal token is the seed, not a replacement value for the generated `primary` role.
Primary icons use `primary`; surfaces and text inherit semantic Material pairs. The drawer header uses `primaryContainer` with `onPrimaryContainer`.
Rating stars use the amber `tertiary` override. Image failures use `surfaceContainerHighest` with `onSurfaceVariant`.

## Typography

[pubspec.yaml](pubspec.yaml) bundles `RobotoSlab-Regular.ttf` (400) and `RobotoSlab-Bold.ttf` (700); [lib/main.dart](lib/main.dart) applies the family globally.
Sizes and requested weights come from native Material 3 text roles, with platform text scaling retained.
`headlineSmall` serves photo titles and the selection-sheet heading; `titleLarge` serves app-bar, drawer, and empty-state titles.
`titleMedium` serves card names; `bodyLarge` serves descriptions; `bodySmall` serves regions, facts, and numeric ratings. Unstyled copy and controls inherit native roles.

## Layout

Measurements are Flutter logical pixels (dp); frontmatter `px` strings serialize those logical values. Typography values are the unscaled base sizes.
[home_screen.dart](lib/screens/home_screen.dart) uses two grid columns below 600 dp, three from 600 to below 840 dp, and a 340 dp list beside the shared detail at 840 dp and above.
Grid cells have a 0.8 width/height ratio. Grid spacing supplies cell gaps and top/side padding; bottom-clearance spacing reserves scroll space below content.
The expanded panes are separated by a 1 dp `VerticalDivider`. Home and detail bodies retain `SafeArea(top: false)`.
The native app-bar toolbar is 56 dp. The home title becomes `TRAVEL APP` below 600 dp; its single line ellipsizes when necessary.
[detail_screen.dart](lib/screens/detail_screen.dart) uses a scrolling detail with a full-width, 260 dp photo and bottom-clearance spacing.
The photo title uses content padding. Rating padding is 12 dp above and 4 dp below; facts padding is 16/12/16/16 dp (left/top/right/bottom).
Facts occupy three equal-width columns; captions wrap and center beneath icons with a 4 dp gap. Description sides use content spacing.
The selection sheet's content height is 68% of screen height, with native drag handle and safe-area handling; heading sides use modal spacing and supporting-copy padding is 24/8/24/16 dp.

## Elevation & Depth

Depth comes from native Material 3 surfaces and component elevation. The standard `Card` retains its 1 dp elevation; app bar, FAB, drawer, and sheet keep framework defaults.
The detail title has the implemented vertical `scrim` gradient from transparent to 70% opacity; its foreground is `onPrimary` in light mode and `onSurface` in dark mode.

## Shapes

Cards retain the native card radius and use `Clip.antiAlias`. The FAB retains its native radius; `CircleAvatar` provides circular list thumbnails.
Drawer and sheet corners, borders, and state layers remain native Material defaults.

## Components

- **Destination card:** [place_card.dart](lib/widgets/place_card.dart) uses a native `Card` with its 4 dp margin, an `InkWell`, expanding photo, and 10 dp caption padding. Name and region each have one ellipsized line.
- **Photograph:** [place_image.dart](lib/widgets/place_image.dart) loads bundled assets with `BoxFit.cover`; failure preserves the requested dimensions and shows a broken-image icon. Images are excluded from semantics because adjacent text identifies the destination.
- **Detail:** the photo title wraps; five 20 dp full/half/outline stars precede a one-decimal rating with a 6 dp gap. Rating and each fact provide one descriptive semantic label.
- **Navigation:** [app_drawer.dart](lib/widgets/app_drawer.dart) closes before applying its action. Selected list tiles reflect the current catalogue or favorite filter. Below 840 dp selection opens a native `MaterialPageRoute`; expanded selection updates the adjacent detail.
- **Search:** [place_search.dart](lib/screens/place_search.dart) uses native `SearchDelegate` input, keyboard, focus, selection, and search submission. Suggestions/results filter the same local list; clear, back, and no-results states remain native.
- **Favorites:** icon-button and checkbox states update immediately through the shared notifier and last for the current session. The FAB opens native `CheckboxListTile` selection controls; an empty filter shows explanatory copy.
- **Control states:** `InkWell`, `IconButton`, FAB, list tiles, checkboxes, dialogs, and sheets retain native pressed, focus, hover, disabled, feedback, dismissal, and transition behavior. Visible iconography is Material.

## Do's and Don'ts

- **Do** use the existing theme roles, bundled assets, shared detail view, native controls, text scaling, and semantic labels.
- **Do** preserve the implemented breakpoints and scrolling behavior when extending these screens.
- **Don't** substitute fixed generated-role colors or custom control states for the native theme behavior.

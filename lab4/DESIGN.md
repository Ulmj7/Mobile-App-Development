---
name: Travel MN
description: Flutter Material 3 travel app for Lab 4 — gradient login, destination grid, maps, ratings.
colors:
  teal-seed: "#009688"
  rating-amber: "#FFC107"
typography:
  font-family: RobotoSlab
rounded:
  card: "12px"
  login-card: "24px"
spacing:
  grid: "12px"
  content: "16px"
---

# Design System: Travel MN

## Overview

`Лабораторийн ажил 4.pdf` governs the visual direction: Material 3, the gradient login, a navigation rail on wide screens and full-screen map picking. Product context is in [PRODUCT.md](PRODUCT.md); the Lab 3 foundations (photo cards, Roboto Slab, detail layout) are kept.

## Colors

[TravelApp._theme](lib/main.dart) is the source of truth: `ColorScheme.fromSeed(seedColor: Colors.teal, brightness: brightness)`. Unlike Lab 3 the `tertiary` role is **not** overridden, so the login gradient (`primary → secondary → tertiary`, stops 0 / 0.55 / 1, top-left to bottom-right) matches the PDF's teal-to-blue-grey screenshot. Stars use `Colors.amber` explicitly. The password meter uses `error` (weak), orange (medium) and green (strong); all other colours come from the theme, so light and dark modes follow the system or the Settings choice (`lib/state/settings.dart`).

## Typography

Roboto Slab (400/700, bundled, includes Mongolian Cyrillic) is applied globally; sizes come from Material 3 text roles with platform text scaling preserved (verified at 1.8×).

## Layout

- [lib/router.dart](lib/router.dart): below 600 dp a bottom `NavigationBar` on the four top-level pages (Газрууд, Дуртай, Газрын зураг, Тохиргоо) and none on sub-pages; from 600 dp a labelled `NavigationRail` + divider. Sub-pages (detail, add form, change password) keep the rail; the map picker (`/map`) is full-screen on the root navigator.
- [home_screen.dart](lib/screens/home_screen.dart): grid of 2 columns below 600 dp, 3 below 900, 4 below 1200, else 5; card aspect 0.8; the FAB (`add_location_alt`) adds a destination. Filters live in a bottom sheet (season + rating sort) and active filters show as chips.
- [detail_screen.dart](lib/screens/detail_screen.dart): content capped at 720 dp; 260 dp swipeable photo gallery with counter and dots; rating card; three facts; map link; description.
- Forms (login 420 dp, add place and change password 480–640 dp) are centred and scroll when the keyboard is open.
- [map_picker_screen.dart](lib/screens/map_picker_screen.dart): the map fills the screen; a search panel floats on top, zoom buttons on the right, and an info panel with a confirm button at the bottom.

## Components

- **Destination card** (`widgets/place_card.dart`): photo, name, region and rating; rebuilds when `userRatings` changes; "Шинэ" when a place has no rating.
- **Stars** (`widgets/star_rating.dart`): a `CustomPainter` star with clipped partial fill; `RatingInput` is five tap targets with tooltips.
- **Photos** (`widgets/place_image.dart`): `Image(image: place.imageProvider)` so bundled assets and picked bytes share one path; failures show a broken-image icon.
- **Maps** (`widgets/osm_map.dart`): one tile layer and attribution shared by the picker and the all-places map; markers carry the place name as tooltip/semantics label.
- **Password field / meter**: show/hide toggle with tooltips; strength shown as bar + text, announced as one semantic label.

## Do's and Don'ts

- **Do** use theme roles, native controls, text scaling and semantic labels; keep the 600 dp breakpoint in `railBreakpoint`.
- **Do** keep Mongolian UI strings consistent with the PDF screenshots.
- **Don't** call Nominatim faster than once per 1.1 s or without the app User-Agent (outside the browser).
- **Don't** hard-code colours that the theme already supplies.

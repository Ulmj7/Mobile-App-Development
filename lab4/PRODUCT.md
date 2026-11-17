# Travel MN

A Flutter travel app for Mobile App Development Lab 4 (map, image upload and ratings).
The governing brief is `Лабораторийн ажил 4.pdf` in this directory; it builds on the Lab 3 catalogue.

Users sign in, browse ten Mongolian destinations, search them by name or season, sort them by rating, rate them with one to five stars, keep favorites, add their own destination (with up to three photos and a point picked on an OpenStreetMap map) and view all destinations on one map.

Target platforms: Android, iOS and web. Material 3 follows the system light/dark setting unless the user picks one in Settings. Compact widths use a bottom navigation bar and two grid columns; widths of 600 dp and above use a side navigation rail and more grid columns.

Data is demo-grade: sign-in is local (no server), favorites, ratings and added destinations live in memory for the session, and ratings of the bundled places are illustrative. Map tiles and place search need the internet (OpenStreetMap, Nominatim); everything else works offline.

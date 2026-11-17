import 'package:flutter/foundation.dart';

/// Must match the Android applicationId / iOS bundle id. The OpenStreetMap tile
/// and Nominatim usage policies ask apps to identify themselves with it.
const appPackageName = 'mn.edu.travel.travel_mn';

const nominatimUserAgent = 'travel_mn/1.4 (Flutter lab app; $appPackageName)';

/// A camera is only offered on phones; browsers and desktops use the gallery.
bool get cameraSupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

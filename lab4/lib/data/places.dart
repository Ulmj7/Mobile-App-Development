import 'package:flutter/foundation.dart';

import '../models/place.dart';

// Distances and photograph sources are documented in README.md.
// Ratings and rating counts are illustrative lab data, not collected visitor
// reviews. Coordinates are the OpenStreetMap (Nominatim) positions of each
// destination; see README.md.

/// Season labels used by the add-place form and the home filter.
const seasons = ['Хавар', 'Зун', 'Намар', 'Өвөл'];

/// All destinations. Starts with the ten bundled places; the user can append
/// more through [addPlace]. Listen to [placesVersion] to rebuild on change.
final places = <Place>[
  Place(
    id: 'terelj',
    name: 'Горхи-Тэрэлж',
    region: 'Төв аймаг',
    image: 'assets/images/terelj.jpg',
    description:
        'Хадан цохио, ой мод бүхий байгалийн цогцолборт газар. '
        'Мэлхий хад, Арьяабалын сүм зэрэг үзвэртэй.',
    rating: 4.7,
    ratingCount: 128,
    distanceKm: 70,
    bestSeason: 'Зун',
    latitude: 47.88843,
    longitude: 107.42282,
  ),
  Place(
    id: 'khuvsgul',
    name: 'Хөвсгөл нуур',
    region: 'Хөвсгөл аймаг',
    image: 'assets/images/khuvsgul.jpg',
    description:
        'Монголын хамгийн гүн, цэнгэг устай нуур. '
        'Эргэн тойрон тайга ой, уул нуруугаар хүрээлэгдсэн.',
    rating: 4.9,
    ratingCount: 342,
    distanceKm: 900,
    bestSeason: 'Зун',
    latitude: 51.02045,
    longitude: 100.47857,
  ),
  Place(
    id: 'khongor',
    name: 'Хонгорын элс',
    region: 'Өмнөговь аймаг',
    image: 'assets/images/khongor.jpg',
    description:
        'Говь гурван сайханы байгалийн цогцолборт газрын '
        'сүрлэг элсэн манхан. Салхинд дуу авиа гаргадаг тул '
        '«Дуут манхан» хэмээн нэрлэдэг.',
    rating: 4.8,
    ratingCount: 215,
    distanceKm: 730,
    bestSeason: 'Намар',
    latitude: 43.77076,
    longitude: 102.17193,
  ),
  Place(
    id: 'kharkhorin',
    name: 'Хархорин',
    region: 'Өвөрхангай аймаг',
    image: 'assets/images/kharkhorin.jpg',
    description:
        'Орхоны хөндийн байгалийн үзэсгэлэн, түүх соёл '
        'хосолсон газар. Эртний Хархорум хотын туурь, '
        'Эрдэнэ Зуу хийдтэй танилцах боломжтой.',
    rating: 4.6,
    ratingCount: 187,
    distanceKm: 360,
    bestSeason: 'Зун',
    latitude: 47.21466,
    longitude: 102.84885,
  ),
  Place(
    id: 'altai',
    name: 'Алтай Таван Богд',
    region: 'Баян-Өлгий аймаг',
    image: 'assets/images/altai.jpg',
    description:
        'Монгол Алтайн мөнх цаст оргилууд, Потанины мөсөн '
        'гол бүхий байгалийн цогцолборт газар. Монголын хамгийн '
        'өндөр Хүйтэн оргил энд оршдог.',
    rating: 4.9,
    ratingCount: 96,
    distanceKm: 1920,
    bestSeason: 'Зун',
    latitude: 48.61885,
    longitude: 88.42564,
  ),
  Place(
    id: 'orkhon',
    name: 'Орхоны хүрхрээ',
    region: 'Өвөрхангай аймаг',
    image: 'assets/images/orkhon.jpg',
    description:
        'Бат-Өлзий сумын нутагт орших Улаан цутгалан хүрхрээ. '
        'Галт уулын чулуулгаар хүрээлэгдсэн хавцал, голын '
        'хөндийгөөр явган аялж болно.',
    rating: 4.8,
    ratingCount: 164,
    distanceKm: 495,
    bestSeason: 'Зун',
    latitude: 46.78744,
    longitude: 101.96024,
  ),
  Place(
    id: 'tsagaan_suvarga',
    name: 'Цагаан суварга',
    region: 'Дундговь аймаг',
    image: 'assets/images/tsagaan_suvarga.jpg',
    description:
        'Өлзийт сумын нутаг дахь олон өнгийн тунамал '
        'чулуун цав. Суварга мэт хэлбэртэй хадан тогтоц нь '
        'нар мандах, жаргах үед онцгой үзэсгэлэнтэй.',
    rating: 4.7,
    ratingCount: 143,
    distanceKm: 420,
    bestSeason: 'Хавар',
    latitude: 44.57694,
    longitude: 105.71771,
  ),
  Place(
    id: 'khustai',
    name: 'Хустайн нуруу',
    region: 'Төв аймаг',
    image: 'assets/images/khustai.jpg',
    description:
        'Тахь нутагшуулсан байгалийн цогцолборт газар. '
        'Ойт хээрийн тогтоц, зэрлэг амьтдыг байгальд нь '
        'ажиглах боломжтой.',
    rating: 4.6,
    ratingCount: 121,
    distanceKm: 100,
    bestSeason: 'Намар',
    latitude: 47.6935,
    longitude: 105.88555,
  ),
  Place(
    id: 'terkhiin',
    name: 'Тэрхийн Цагаан нуур',
    region: 'Архангай аймаг',
    image: 'assets/images/terkhiin.jpg',
    description:
        'Тариат сумын нутагт, Хоргын галт уулын ойролцоо '
        'орших цэнгэг уст нуур. Галт уулын хүрмэн чулуу, '
        'уулс, нүүдлийн шувуудтай тайван орчинтой.',
    rating: 4.8,
    ratingCount: 108,
    distanceKm: 660,
    bestSeason: 'Зун',
    latitude: 48.15738,
    longitude: 99.65772,
  ),
  Place(
    id: 'yolyn_am',
    name: 'Ёлын ам',
    region: 'Өмнөговь аймаг',
    image: 'assets/images/yolyn_am.jpg',
    description:
        'Говь гурван сайханы уулс дахь нарийн, өндөр '
        'хадан хавцал. Сүүдэртэй хэсгийн мөс зуны эхэн хүртэл '
        'хадгалагддаг бөгөөд өвөл цас мөсөн төрхтэй болдог.',
    rating: 4.7,
    ratingCount: 176,
    distanceKm: 610,
    bestSeason: 'Зун',
    latitude: 43.50035,
    longitude: 104.0974,
  ),
];

/// Bumped whenever [places] changes, so lists can rebuild.
final placesVersion = ValueNotifier<int>(0);

void addPlace(Place place) {
  places.add(place);
  placesVersion.value++;
}

/// Removes every user-added destination (used by [resetAppState]).
void resetPlaces() {
  places.removeWhere((place) => place.isUserAdded);
  placesVersion.value++;
}

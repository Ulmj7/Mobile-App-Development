import '../models/place.dart';

// Distances and photograph sources are documented in README.md.
// Ratings are illustrative lab data, not collected visitor reviews.
const places = <Place>[
  Place(
    id: 'terelj',
    name: 'Горхи-Тэрэлж',
    region: 'Төв аймаг',
    image: 'assets/images/terelj.jpg',
    description:
        'Хадан цохио, ой мод бүхий байгалийн цогцолборт газар. '
        'Мэлхий хад, Арьяабалын сүм зэрэг үзвэртэй.',
    rating: 4.7,
    distanceKm: 70,
    bestSeason: 'Зун',
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
    distanceKm: 900,
    bestSeason: 'Зун',
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
    distanceKm: 730,
    bestSeason: 'Намар',
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
    distanceKm: 360,
    bestSeason: 'Зун',
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
    distanceKm: 1920,
    bestSeason: 'Зун',
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
    distanceKm: 495,
    bestSeason: 'Зун',
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
    distanceKm: 420,
    bestSeason: 'Хавар',
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
    distanceKm: 100,
    bestSeason: 'Намар',
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
    distanceKm: 660,
    bestSeason: 'Зун',
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
    distanceKm: 610,
    bestSeason: 'Зун',
  ),
];

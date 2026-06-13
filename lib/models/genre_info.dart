import 'package:flutter/material.dart';

class GenreInfo {
  final String name;
  final String nameHindi;
  final String description;
  final IconData icon;
  final Color color;
  final String imagePath; // local asset path

  const GenreInfo({
    required this.name,
    required this.nameHindi,
    required this.description,
    required this.icon,
    required this.color,
    required this.imagePath,
  });
}

const List<GenreInfo> kGenres = [
  GenreInfo(
    name: 'Folk',
    nameHindi: 'लोक गीत',
    description: 'Pahadi songs of the mountains',
    icon: Icons.terrain,
    color: Color(0xFF1B5E20),
    imagePath: 'assets/images/genre_folk.jpg',       // Pahadi village in the hills
  ),
  GenreInfo(
    name: 'Devotional',
    nameHindi: 'भक्ति',
    description: 'Char Dham — Land of the Gods',
    icon: Icons.temple_hindu,
    color: Color(0xFFBF360C),
    imagePath: 'assets/images/genre_devotional.jpg', // Kedarnath pilgrimage
  ),
  GenreInfo(
    name: 'Wedding',
    nameHindi: 'विवाह गीत',
    description: 'Pahadi wedding celebrations',
    icon: Icons.local_florist,
    color: Color(0xFFAD1457),
    imagePath: 'assets/images/genre_wedding.jpg',    // Buransh rhododendrons
  ),
  GenreInfo(
    name: 'Festival',
    nameHindi: 'उत्सव गीत',
    description: 'Holika, Diwali & harvest songs',
    icon: Icons.whatshot,
    color: Color(0xFF4527A0),
    imagePath: 'assets/images/genre_festival.jpg',   // Festival fire & dance
  ),
  GenreInfo(
    name: 'Dance',
    nameHindi: 'नृत्य गीत',
    description: 'Jhora, Nauchami & Langvir',
    icon: Icons.album,
    color: Color(0xFF006064),
    imagePath: 'assets/images/genre_dance.jpg',      // Folk dancers
  ),
  GenreInfo(
    name: 'Romantic',
    nameHindi: 'श्रृंगार',
    description: 'Songs of the Ganga & Yamuna',
    icon: Icons.water,
    color: Color(0xFF880E4F),
    imagePath: 'assets/images/genre_romantic.jpg',   // Himalayan range
  ),
];

GenreInfo genreInfoFor(String name) {
  try {
    return kGenres.firstWhere((g) => g.name == name);
  } catch (_) {
    return const GenreInfo(
      name: 'Other',
      nameHindi: 'अन्य',
      description: 'More songs',
      icon: Icons.library_music,
      color: Color(0xFF37474F),
      imagePath: 'assets/images/bg_mountains.jpg',
    );
  }
}

const List<String> kRegions = ['Garhwal', 'Kumaon', 'Jaunsari'];
const List<String> kAllGenreNames = [
  'Folk', 'Devotional', 'Wedding', 'Festival', 'Dance', 'Romantic'
];

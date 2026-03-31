import 'package:equatable/equatable.dart';

enum TableLocation { window, garden, private, bar, main }

class RestaurantTable extends Equatable {
  final String id;
  final String name;
  final int minGuests;
  final int maxGuests;
  final TableLocation location;
  final String description;
  final String imagePath;
  final bool isAvailable;
  final double pricePerPerson;

  const RestaurantTable({
    required this.id,
    required this.name,
    required this.minGuests,
    required this.maxGuests,
    required this.location,
    required this.description,
    required this.imagePath,
    this.isAvailable = true,
    required this.pricePerPerson,
  });

  String get locationLabel {
    switch (location) {
      case TableLocation.window: return 'Window View';
      case TableLocation.garden: return 'Garden Terrace';
      case TableLocation.private: return 'Private Room';
      case TableLocation.bar: return 'Chef\'s Bar';
      case TableLocation.main: return 'Main Dining';
    }
  }

  @override
  List<Object?> get props => [id, name, minGuests, maxGuests, location, isAvailable];
}

final List<RestaurantTable> sampleTables = [
  const RestaurantTable(
    id: 't1',
    name: 'The Celestial',
    minGuests: 2,
    maxGuests: 2,
    location: TableLocation.window,
    description: 'Floor-to-ceiling windows overlooking the city skyline. Perfect for an intimate dinner for two with a breathtaking panoramic view.',
    imagePath: 'https://images.unsplash.com/photo-1559329007-40df8a9345d8?w=800&q=80',
    pricePerPerson: 180,
  ),
  const RestaurantTable(
    id: 't2',
    name: 'The Conservatory',
    minGuests: 2,
    maxGuests: 4,
    location: TableLocation.garden,
    description: 'A secluded terrace surrounded by manicured gardens and soft ambient lighting. An al fresco dining experience like no other.',
    imagePath: 'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?w=800&q=80',
    pricePerPerson: 160,
  ),
  const RestaurantTable(
    id: 't3',
    name: 'The Vault',
    minGuests: 4,
    maxGuests: 8,
    location: TableLocation.private,
    description: 'Our exclusive private dining room with dedicated butler service, curated wine cellar access, and complete privacy for your most special occasions.',
    imagePath: 'https://images.unsplash.com/photo-1549488507-1fca49fcc474?w=800&q=80',
    pricePerPerson: 250,
  ),
  const RestaurantTable(
    id: 't4',
    name: 'The Atelier',
    minGuests: 1,
    maxGuests: 4,
    location: TableLocation.bar,
    description: 'Sit at the counter and watch our executive chef craft each dish live. An immersive culinary theater experience for the discerning food lover.',
    imagePath: 'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=800&q=80',
    pricePerPerson: 220,
  ),
  const RestaurantTable(
    id: 't5',
    name: 'Grand Salon',
    minGuests: 4,
    maxGuests: 12,
    location: TableLocation.main,
    description: 'The heart of our dining room, adorned with crystal chandeliers and hand-painted murals. Grand in scale, intimate in atmosphere.',
    imagePath: 'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=800&q=80',
    pricePerPerson: 140,
  ),
];

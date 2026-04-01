class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final String location;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<String> gallery;
  final double priceLevel;      // 1–4
  final String openTime;
  final String closeTime;
  final bool isOpen;
  final bool isFavorite;
  final String description;
  final String phone;
  final String address;
  final List<MenuItem> menu;
  final List<Review> reviews;
  final List<String> tags;
  final double distance;        // km
  final bool hasOffer;
  final String? offerText;
  final int availableTables;

  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.gallery,
    required this.priceLevel,
    required this.openTime,
    required this.closeTime,
    required this.isOpen,
    required this.isFavorite,
    required this.description,
    required this.phone,
    required this.address,
    required this.menu,
    required this.reviews,
    required this.tags,
    required this.distance,
    required this.hasOffer,
    this.offerText,
    required this.availableTables,
  });

  Restaurant copyWith({bool? isFavorite}) => Restaurant(
    id: id, name: name, cuisine: cuisine, location: location,
    rating: rating, reviewCount: reviewCount, imageUrl: imageUrl,
    gallery: gallery, priceLevel: priceLevel, openTime: openTime,
    closeTime: closeTime, isOpen: isOpen,
    isFavorite: isFavorite ?? this.isFavorite,
    description: description, phone: phone, address: address,
    menu: menu, reviews: reviews, tags: tags, distance: distance,
    hasOffer: hasOffer, offerText: offerText, availableTables: availableTables,
  );

  String get priceString => '\$' * priceLevel.toInt();
}

class MenuItem {
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  const MenuItem({required this.name, required this.description,
      required this.price, required this.category, required this.imageUrl});
}

class Review {
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final String date;
  const Review({required this.userName, required this.userAvatar,
      required this.rating, required this.comment, required this.date});
}

// ── Sample data ───────────────────────────────────────────────────────────────
final sampleRestaurants = [
  Restaurant(
    id: 'r1', name: 'La Maison Élégante', cuisine: 'French Fine Dining',
    location: 'Downtown', rating: 4.9, reviewCount: 1284,
    imageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600&q=80',
      'https://images.unsplash.com/photo-1424847651672-bf20a4b0982b?w=600&q=80',
      'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?w=600&q=80',
      'https://images.unsplash.com/photo-1551632436-cbf8dd35adfa?w=600&q=80',
    ],
    priceLevel: 4, openTime: '6:00 PM', closeTime: '11:00 PM',
    isOpen: true, isFavorite: true,
    description: 'An exquisite journey through classical French cuisine. Our executive chef crafts seasonal tasting menus using only the finest locally-sourced ingredients. Three Michelin stars, impeccable service.',
    phone: '+1 (212) 555-0101', address: '28 Park Avenue, Manhattan, NY 10001',
    tags: ['Michelin Star', 'Fine Dining', 'Wine Bar', 'Private Dining'],
    distance: 0.8, hasOffer: true, offerText: '20% OFF Weekend Brunch',
    availableTables: 4,
    menu: [
      const MenuItem(name: 'Foie Gras Terrine', description: 'Duck liver, brioche toast, fig compote', price: 42, category: 'Starters', imageUrl: 'https://images.unsplash.com/photo-1553361371-9b22f78e8b1d?w=200&q=80'),
      const MenuItem(name: 'Wagyu Beef Rossini', description: 'A5 Wagyu, foie gras, truffle sauce', price: 145, category: 'Mains', imageUrl: 'https://images.unsplash.com/photo-1558030006-450675393462?w=200&q=80'),
      const MenuItem(name: 'Soufflé Grand Marnier', description: 'Classic soufflé, crème anglaise', price: 28, category: 'Desserts', imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=200&q=80'),
    ],
    reviews: [
      const Review(userName: 'James W.', userAvatar: 'J', rating: 5.0, comment: 'Absolutely world-class. The tasting menu was a journey through flavour. Will return.', date: 'Dec 2024'),
      const Review(userName: 'Sophia L.', userAvatar: 'S', rating: 4.8, comment: 'Perfect for our anniversary. Service was impeccable, ambiance divine.', date: 'Nov 2024'),
    ],
  ),
  Restaurant(
    id: 'r2', name: 'Sakura Omakase', cuisine: 'Japanese Omakase',
    location: 'Midtown', rating: 4.8, reviewCount: 876,
    imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=600&q=80',
      'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=600&q=80',
      'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=600&q=80',
    ],
    priceLevel: 4, openTime: '5:30 PM', closeTime: '10:30 PM',
    isOpen: true, isFavorite: false,
    description: 'Chef Tanaka brings 30 years of Kyoto tradition to New York. Our omakase experience features 18 courses of seasonal Japanese cuisine, sake pairings, and an intimate 12-seat counter.',
    phone: '+1 (212) 555-0202', address: '54 E 54th St, New York, NY 10022',
    tags: ['Omakase', 'Sushi', 'Sake Bar', 'Counter Dining'],
    distance: 1.2, hasOffer: false, availableTables: 2,
    menu: [
      const MenuItem(name: 'Otoro Nigiri', description: 'Bluefin tuna belly, house soy', price: 28, category: 'Nigiri', imageUrl: 'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=200&q=80'),
      const MenuItem(name: 'Wagyu Tataki', description: 'Seared beef, ponzu, microgreens', price: 48, category: 'Cooked', imageUrl: 'https://images.unsplash.com/photo-1558030006-450675393462?w=200&q=80'),
    ],
    reviews: [
      const Review(userName: 'Michael R.', userAvatar: 'M', rating: 5.0, comment: 'The best omakase outside Japan. Chef Tanaka is a true artist.', date: 'Jan 2025'),
    ],
  ),
  Restaurant(
    id: 'r3', name: 'Terra Cucina', cuisine: 'Modern Italian',
    location: 'West Village', rating: 4.7, reviewCount: 2341,
    imageUrl: 'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?w=800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?w=600&q=80',
      'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600&q=80',
    ],
    priceLevel: 3, openTime: '12:00 PM', closeTime: '10:00 PM',
    isOpen: true, isFavorite: true,
    description: 'Farm-to-table Italian cuisine in the heart of the West Village. Our pasta is hand-made daily, and our wine list celebrates small Italian producers. A neighbourhood gem.',
    phone: '+1 (212) 555-0303', address: '15 Bank Street, West Village, NY 10014',
    tags: ['Italian', 'Pasta', 'Natural Wine', 'Garden Terrace'],
    distance: 2.1, hasOffer: true, offerText: 'Free Tiramisu on Birthday',
    availableTables: 7,
    menu: [
      const MenuItem(name: 'Burrata Pugliese', description: 'Fresh burrata, heirloom tomatoes, basil oil', price: 22, category: 'Antipasti', imageUrl: 'https://images.unsplash.com/photo-1551632436-cbf8dd35adfa?w=200&q=80'),
      const MenuItem(name: 'Tagliatelle al Ragù', description: 'Hand-rolled pasta, 8-hour beef ragù', price: 34, category: 'Pasta', imageUrl: 'https://images.unsplash.com/photo-1551183053-bf91798d2ead?w=200&q=80'),
    ],
    reviews: [
      const Review(userName: 'Elena M.', userAvatar: 'E', rating: 4.7, comment: 'Feels like eating in a Tuscan kitchen. The pasta alone is worth the trip.', date: 'Feb 2025'),
    ],
  ),
  Restaurant(
    id: 'r4', name: 'The Ember Grill', cuisine: 'American Steakhouse',
    location: 'Financial District', rating: 4.6, reviewCount: 1893,
    imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1544025162-d76694265947?w=600&q=80',
      'https://images.unsplash.com/photo-1558030006-450675393462?w=600&q=80',
    ],
    priceLevel: 3, openTime: '5:00 PM', closeTime: '11:00 PM',
    isOpen: false, isFavorite: false,
    description: 'Dry-aged prime beef, live-fire cooking, and an exceptional bourbon collection. Our USDA Prime steaks are aged 45 days in-house and grilled over imported Japanese binchotan charcoal.',
    phone: '+1 (212) 555-0404', address: '88 Broad Street, NYC 10004',
    tags: ['Steakhouse', 'Dry-Aged', 'Bourbon Bar', 'Private Events'],
    distance: 3.4, hasOffer: false, availableTables: 5,
    menu: [
      const MenuItem(name: '45-Day Dry-Aged Ribeye', description: '16oz USDA Prime, bone-in, compound butter', price: 89, category: 'Steaks', imageUrl: 'https://images.unsplash.com/photo-1558030006-450675393462?w=200&q=80'),
      const MenuItem(name: 'Truffle Fries', description: 'Hand-cut, black truffle oil, parmesan', price: 18, category: 'Sides', imageUrl: 'https://images.unsplash.com/photo-1541592106381-b31e9677c0e5?w=200&q=80'),
    ],
    reviews: [
      const Review(userName: 'David K.', userAvatar: 'D', rating: 4.6, comment: 'Best steak in the city, full stop. The dry-aged ribeye is extraordinary.', date: 'Mar 2025'),
    ],
  ),
  Restaurant(
    id: 'r5', name: 'Spice Garden', cuisine: 'Modern Indian',
    location: 'Curry Hill', rating: 4.5, reviewCount: 3120,
    imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600&q=80',
      'https://images.unsplash.com/photo-1424847651672-bf20a4b0982b?w=600&q=80',
    ],
    priceLevel: 2, openTime: '11:00 AM', closeTime: '10:30 PM',
    isOpen: true, isFavorite: false,
    description: 'Modern Indian cuisine that celebrates the depth and diversity of the subcontinent. Chef Patel re-imagines classic dishes with contemporary technique and seasonal local produce.',
    phone: '+1 (212) 555-0505', address: '127 Lexington Ave, NY 10016',
    tags: ['Indian', 'Vegetarian Friendly', 'Cocktail Bar', 'Brunch'],
    distance: 1.8, hasOffer: true, offerText: 'Lunch Thali — \$28',
    availableTables: 10,
    menu: [
      const MenuItem(name: 'Butter Chicken', description: 'Heritage breed chicken, tomato masala', price: 28, category: 'Mains', imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=200&q=80'),
      const MenuItem(name: 'Dal Makhani', description: 'Black lentils, slow-cooked 24hrs', price: 22, category: 'Mains', imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=200&q=80'),
    ],
    reviews: [
      const Review(userName: 'Priya S.', userAvatar: 'P', rating: 4.5, comment: 'Authentic flavours elevated beautifully. The Dal Makhani is the best I\'ve had outside Mumbai.', date: 'Feb 2025'),
    ],
  ),
];

final List<String> cuisineCategories = [
  'All', 'French', 'Japanese', 'Italian', 'American', 'Indian', 'Chinese', 'Mediterranean',
];

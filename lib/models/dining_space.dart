class SpaceFeature {
  final String emoji;
  final String label;
  final String value;
  const SpaceFeature(this.emoji, this.label, this.value);
}

class DiningSpace {
  final String id;
  final String title;
  final String tag;
  final String shortDesc;
  final String longDesc;
  final String heroUrl;
  final List<String> galleryUrls;
  final List<SpaceFeature> features;
  final String tableId; // links to RestaurantTable.id
  final String capacity;
  final String ambiance;
  final String dressCode;
  final String openHours;

  const DiningSpace({
    required this.id,
    required this.title,
    required this.tag,
    required this.shortDesc,
    required this.longDesc,
    required this.heroUrl,
    required this.galleryUrls,
    required this.features,
    required this.tableId,
    required this.capacity,
    required this.ambiance,
    required this.dressCode,
    required this.openHours,
  });
}

final List<DiningSpace> diningSpaces = [
  DiningSpace(
    id: 's1',
    title: 'Skyline Suite',
    tag: 'Private',
    shortDesc: 'Panoramic city views from our 28th floor private dining room.',
    longDesc:
        'Perched atop the city, the Skyline Suite is our most exclusive offering — a fully private dining room enveloped in floor-to-ceiling glass. Watch the city shimmer below as our dedicated butler curates an evening tailored entirely to you. Reserved for the most discerning of guests, this space accommodates intimate gatherings and grand celebrations alike, with access to our private wine vault and a dedicated sommelier on hand throughout the evening.',
    heroUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=1200&q=85',
    galleryUrls: [
      'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600&q=80',
      'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?w=600&q=80',
      'https://images.unsplash.com/photo-1551632436-cbf8dd35adfa?w=600&q=80',
      'https://images.unsplash.com/photo-1559329007-40df8a9345d8?w=600&q=80',
    ],
    features: const [
      SpaceFeature('👥', 'Capacity', '4 – 8 guests'),
      SpaceFeature('🕖', 'Hours', '6:00 PM – 11:00 PM'),
      SpaceFeature('👔', 'Dress Code', 'Black tie encouraged'),
      SpaceFeature('🍾', 'Includes', 'Dedicated sommelier'),
      SpaceFeature('🔒', 'Privacy', 'Fully private room'),
      SpaceFeature('🌃', 'View', 'City panorama, 28th floor'),
    ],
    tableId: 't3',
    capacity: '4 – 8 guests',
    ambiance: 'Ultra-private, panoramic, intimate',
    dressCode: 'Black tie encouraged',
    openHours: '6:00 PM – 11:00 PM',
  ),
  DiningSpace(
    id: 's2',
    title: 'Garden Terrace',
    tag: 'Outdoor',
    shortDesc: 'Al fresco dining in our manicured rooftop garden sanctuary.',
    longDesc:
        'Step out onto our rooftop garden and leave the city behind. The Garden Terrace is a verdant oasis of sculpted hedgerows, trailing jasmine, and the soft flicker of candlelight. Designed for evenings when the sky is your ceiling, it offers an unhurried al fresco experience where seasonal French cuisine meets the gentle warmth of summer air. A favourite for romantic dinners and intimate celebrations under the stars.',
    heroUrl: 'https://images.unsplash.com/photo-1424847651672-bf20a4b0982b?w=1200&q=85',
    galleryUrls: [
      'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?w=600&q=80',
      'https://images.unsplash.com/photo-1424847651672-bf20a4b0982b?w=600&q=80',
      'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600&q=80',
      'https://images.unsplash.com/photo-1551632436-cbf8dd35adfa?w=600&q=80',
    ],
    features: const [
      SpaceFeature('👥', 'Capacity', '2 – 4 guests'),
      SpaceFeature('🕖', 'Hours', '6:30 PM – 10:30 PM'),
      SpaceFeature('👔', 'Dress Code', 'Smart casual'),
      SpaceFeature('🌿', 'Setting', 'Rooftop garden, open-air'),
      SpaceFeature('🕯', 'Ambiance', 'Candlelit, seasonal florals'),
      SpaceFeature('🌧', 'Weather', 'Heated canopy available'),
    ],
    tableId: 't2',
    capacity: '2 – 4 guests',
    ambiance: 'Romantic, open-air, candlelit',
    dressCode: 'Smart casual',
    openHours: '6:30 PM – 10:30 PM',
  ),
  DiningSpace(
    id: 's3',
    title: 'The Wine Cellar',
    tag: 'Exclusive',
    shortDesc: 'An intimate cave dining experience among 12,000 curated bottles.',
    longDesc:
        'Descend into our legendary cellar and dine among one of Europe\'s finest private wine collections. The Wine Cellar is a subterranean sanctuary of stone arches, warm candlelight, and 12,000 carefully curated bottles that line the walls from floor to vaulted ceiling. Our head sommelier will personally guide your wine journey through the evening, pairing each course with selections drawn directly from the cellar around you. An experience reserved for true connoisseurs.',
    heroUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=1200&q=85',
    galleryUrls: [
      'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=600&q=80',
      'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600&q=80',
      'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?w=600&q=80',
      'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?w=600&q=80',
    ],
    features: const [
      SpaceFeature('👥', 'Capacity', '4 – 12 guests'),
      SpaceFeature('🕖', 'Hours', '7:00 PM – 11:30 PM'),
      SpaceFeature('👔', 'Dress Code', 'Smart formal'),
      SpaceFeature('🍷', 'Cellar', '12,000+ curated bottles'),
      SpaceFeature('🧑‍🍳', 'Service', 'Personal head sommelier'),
      SpaceFeature('🏛', 'Setting', 'Stone vaulted cellar'),
    ],
    tableId: 't5',
    capacity: '4 – 12 guests',
    ambiance: 'Subterranean, dramatic, exclusive',
    dressCode: 'Smart formal',
    openHours: '7:00 PM – 11:30 PM',
  ),
];

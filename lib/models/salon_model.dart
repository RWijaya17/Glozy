class SalonModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String imageUrl;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final String ownerId;
  final List<ServiceModel> services;
  final Map<String, String> openingHours;
  final bool isActive;
  final bool homeService;
  final double baseServiceFee;
  double? distance; // Distance from user's current location

  SalonModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.imageUrl,
    this.images = const [],
    required this.rating,
    required this.reviewCount,
    required this.ownerId,
    this.services = const [],
    this.openingHours = const {},
    this.isActive = true,
    this.homeService = false,
    this.baseServiceFee = 0.0,
    this.distance,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'imageUrl': imageUrl,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'ownerId': ownerId,
      'services': services.map((e) => e.toJson()).toList(),
      'openingHours': openingHours,
      'isActive': isActive,
      'homeService': homeService,
      'baseServiceFee': baseServiceFee,
    };
  }

  factory SalonModel.fromJson(Map<String, dynamic> json) {
    return SalonModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      phone: json['phone'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      ownerId: json['ownerId'] ?? '',
      services: (json['services'] as List?)
              ?.map((e) => ServiceModel.fromJson(e))
              .toList() ??
          [],
      openingHours: Map<String, String>.from(json['openingHours'] ?? {}),
      isActive: json['isActive'] ?? true,
      homeService: json['homeService'] ?? false,
      baseServiceFee: (json['baseServiceFee'] ?? 0.0).toDouble(),
    );
  }
}

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int duration; // in minutes
  final String imageUrl;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    this.imageUrl = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'imageUrl': imageUrl,
    };
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      duration: json['duration'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

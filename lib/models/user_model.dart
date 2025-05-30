import 'package:flutter/foundation.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final List<String> favorites;
  final String? address; // Ubah menjadi nullable dengan String?
  final double? latitude;
  final double? longitude;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.profileImage = '',
    this.favorites = const [],
    this.address, // Hapus nilai default
    this.latitude,
    this.longitude,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle favorites dengan sangat hati-hati
    List<String> favorites = [];
    if (json.containsKey('favorites')) {
      if (json['favorites'] is List) {
        try {
          favorites = (json['favorites'] as List)
              .where((e) => e != null)
              .map((e) => e.toString())
              .toList();
        } catch (e) {
          debugPrint('Error parsing favorites: $e');
        }
      }
    }

    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profileImage'] ?? '',
      favorites: favorites,
      address: json['address'], // Terima null
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'favorites': favorites,
      'address': address, // Bisa null
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

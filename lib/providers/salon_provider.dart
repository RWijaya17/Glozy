import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/salon_model.dart';
import '../utils/location_helper.dart';

class SalonProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<SalonModel> _salons = [];
  List<SalonModel> get salons => _salons;

  List<SalonModel> _filteredSalons = [];
  List<SalonModel> get filteredSalons => _filteredSalons;

  set filteredSalons(List<SalonModel> salons) {
    _filteredSalons = salons;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Fetch all salons
  Future<void> fetchSalons() async {
    try {
      _isLoading = true;
      notifyListeners();

      final QuerySnapshot snapshot = await _firestore
          .collection('salons')
          .where('isActive', isEqualTo: true)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint(
            'Warning: No salons found in Firestore. Did you run seed data?');
      }

      _salons = snapshot.docs.map((doc) {
        debugPrint('Loaded salon: ${doc.id}');
        return SalonModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();

      // Calculate distances if current position is available
      if (_currentPosition != null) {
        await _calculateDistances();
      }

      _filteredSalons = List.from(_salons);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching salons: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search salons
  void searchSalons(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredSalons = List.from(_salons);
    } else {
      _filteredSalons = _salons.where((salon) {
        final nameLower = salon.name.toLowerCase();
        final addressLower = salon.address.toLowerCase();
        final queryLower = query.toLowerCase();

        return nameLower.contains(queryLower) ||
            addressLower.contains(queryLower);
      }).toList();
    }

    notifyListeners();
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    try {
      _currentPosition = await LocationHelper.getCurrentPosition();

      if (_currentPosition != null && _salons.isNotEmpty) {
        await _calculateDistances();
      }

      notifyListeners();
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  // Calculate distances for all salons
  Future<void> _calculateDistances() async {
    if (_currentPosition == null) return;

    for (var salon in _salons) {
      salon.distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        salon.latitude,
        salon.longitude,
      );
    }

    // Sort by distance
    _salons.sort((a, b) => (a.distance ?? double.infinity)
        .compareTo(b.distance ?? double.infinity));

    // Update filtered salons
    searchSalons(_searchQuery);
  }

  // Filter salons
  void filterSalons({
    double? maxDistance,
    double? minRating,
    List<String>? services,
    bool? homeService,
    String sortBy = 'distance',
  }) {
    // First filter based on criteria
    _filteredSalons = _salons.where((salon) {
      bool matchesDistance = maxDistance == null ||
          (salon.distance != null && salon.distance! <= maxDistance * 1000);

      bool matchesRating = minRating == null || salon.rating >= minRating;

      bool matchesHomeService =
          homeService == null || salon.homeService == homeService;

      bool matchesServices = services == null ||
          services.isEmpty ||
          salon.services.any((service) =>
              services.contains(service.id) || services.contains(service.name));

      return matchesDistance &&
          matchesRating &&
          matchesHomeService &&
          matchesServices;
    }).toList();

    // Then sort based on sortBy parameter
    switch (sortBy) {
      case 'distance':
        _filteredSalons.sort((a, b) => (a.distance ?? double.infinity)
            .compareTo(b.distance ?? double.infinity));
        break;
      case 'rating':
        _filteredSalons.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'price_low':
        _filteredSalons.sort((a, b) {
          double aMinPrice = a.services.isEmpty
              ? 0
              : a.services
                  .map((s) => s.price)
                  .reduce((min, price) => price < min ? price : min);
          double bMinPrice = b.services.isEmpty
              ? 0
              : b.services
                  .map((s) => s.price)
                  .reduce((min, price) => price < min ? price : min);
          return aMinPrice.compareTo(bMinPrice);
        });
        break;
      case 'price_high':
        _filteredSalons.sort((a, b) {
          double aMaxPrice = a.services.isEmpty
              ? 0
              : a.services
                  .map((s) => s.price)
                  .reduce((max, price) => price > max ? price : max);
          double bMaxPrice = b.services.isEmpty
              ? 0
              : b.services
                  .map((s) => s.price)
                  .reduce((max, price) => price > max ? price : max);
          return bMaxPrice.compareTo(aMaxPrice);
        });
        break;
      case 'name':
        _filteredSalons.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    notifyListeners();
  }

  // Method untuk filter cepat berdasarkan kategori
  void quickFilter(String filterType) {
    switch (filterType) {
      case 'all':
        _filteredSalons = List.from(_salons);
        break;
      case 'home_service':
        filterSalons(homeService: true);
        break;
      case 'high_rated':
        filterSalons(minRating: 4.0);
        break;
      default:
        _filteredSalons = List.from(_salons);
    }
    notifyListeners();
  }

  // Get nearby salons
  List<SalonModel> getNearbySalons({int limit = 10}) {
    if (_currentPosition == null) return _salons.take(limit).toList();

    final nearbySalons = List<SalonModel>.from(_salons);
    nearbySalons.sort((a, b) => (a.distance ?? double.infinity)
        .compareTo(b.distance ?? double.infinity));

    return nearbySalons.take(limit).toList();
  }

  // Get featured salons
  List<SalonModel> getFeaturedSalons({int limit = 5}) {
    final featuredSalons = List<SalonModel>.from(_salons);
    featuredSalons.sort((a, b) => b.rating.compareTo(a.rating));

    return featuredSalons.take(limit).toList();
  }

  // Get salon by ID
  SalonModel? getSalonById(String salonId) {
    try {
      return _salons.firstWhere((salon) => salon.id == salonId);
    } catch (e) {
      return null;
    }
  }

  // Refresh salons
  Future<void> refreshSalons() async {
    try {
      _isLoading = true;
      notifyListeners();

      await fetchSalons();

      if (_currentPosition == null) {
        await getCurrentLocation();
      }

      if (_salons.isNotEmpty && _currentPosition != null) {
        await _calculateDistances();
      }
    } catch (e) {
      debugPrint('Error refreshing salons: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

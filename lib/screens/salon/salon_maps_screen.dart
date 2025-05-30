import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../providers/salon_provider.dart';
import '../../models/salon_model.dart';
import '../salon/salon_detail_screen.dart';
import '../../widgets/filter_dialog.dart';

class SalonMapsScreen extends StatefulWidget {
  const SalonMapsScreen({Key? key}) : super(key: key);

  @override
  State<SalonMapsScreen> createState() => _SalonMapsScreenState();
}

class _SalonMapsScreenState extends State<SalonMapsScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  SalonModel? _selectedSalon;
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = 'distance';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final salonProvider = Provider.of<SalonProvider>(context, listen: false);
      // Force refresh data when opening map
      salonProvider.refreshSalons().then((_) {
        _setupMarkers();
      });
    });
  }

  void _setupMarkers() async {
    final salonProvider = Provider.of<SalonProvider>(context, listen: false);

    // Force fetch salons if empty
    if (salonProvider.salons.isEmpty) {
      await salonProvider.fetchSalons();
    }

    final salons = salonProvider.filteredSalons.isNotEmpty
        ? salonProvider.filteredSalons
        : salonProvider.salons;
    final currentPosition = salonProvider.currentPosition;

    Set<Marker> markers = {};

    // Add user location marker if available
    if (currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(currentPosition.latitude, currentPosition.longitude),
          icon: await BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Your Location',
          ),
        ),
      );
    }

    // Add salon markers with full details
    for (final salon in salons) {
      String snippetText =
          '⭐ ${salon.rating} | ${salon.services.length} services';
      if (salon.distance != null) {
        snippetText += ' | ${(salon.distance! / 1000).toStringAsFixed(1)} km';
      }

      markers.add(
        Marker(
          markerId: MarkerId(salon.id),
          position: LatLng(salon.latitude, salon.longitude),
          icon: await BitmapDescriptor.defaultMarkerWithHue(
            salon.homeService
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(
            title: salon.name,
            snippet: snippetText,
            onTap: () {
              _selectSalon(salon);
            },
          ),
          onTap: () {
            _selectSalon(salon);
          },
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });

      // Center map on a good spot to see most salons
      if (salons.isNotEmpty) {
        // Calculate center point of all salons
        double avgLat = salons.fold(0.0, (sum, salon) => sum + salon.latitude) /
            salons.length;
        double avgLng =
            salons.fold(0.0, (sum, salon) => sum + salon.longitude) /
                salons.length;

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(avgLat, avgLng),
            13.0,
          ),
        );
      }
    }
  }

  void _selectSalon(SalonModel salon) {
    setState(() {
      _selectedSalon = salon;
    });

    // Center map on selected salon
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(salon.latitude, salon.longitude),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        initialSort: _selectedSort,
        initialFilter: _selectedFilter,
        onApply: (sort, filter) {
          setState(() {
            _selectedSort = sort;
            _selectedFilter = filter;
          });
          _applyFilters();
        },
      ),
    );
  }

  void _applyFilters() {
    final salonProvider = Provider.of<SalonProvider>(context, listen: false);
    final salons = List.from(salonProvider.salons);

    // Apply filter
    List<SalonModel> filteredSalons;
    switch (_selectedFilter) {
      case 'home_service':
        filteredSalons = salons
            .where((salon) => salon.homeService)
            .toList()
            .cast<SalonModel>();
        break;
      case 'high_rated':
        filteredSalons = salons
            .where((salon) => salon.rating >= 4.0)
            .toList()
            .cast<SalonModel>();
        break;
      default:
        filteredSalons = salons.cast<SalonModel>();
    }

    // Apply sort - In map view, sorting only affects which salons are displayed most prominently
    switch (_selectedSort) {
      case 'distance':
        filteredSalons.sort((a, b) => (a.distance ?? double.infinity)
            .compareTo(b.distance ?? double.infinity));
        break;
      case 'rating':
        filteredSalons.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
        filteredSalons.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    salonProvider.filteredSalons = filteredSalons;
    _setupMarkers(); // Refresh markers on map
  }

  @override
  Widget build(BuildContext context) {
    final salonProvider = Provider.of<SalonProvider>(context);

    return Stack(
      children: [
        // Google Map
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            // Koordinat tengah Jakarta, dekat dengan salon-salon dari seed data
            target: LatLng(-6.2088, 106.8456), // Koordinat Glozy Beauty Salon
            zoom: 13.0, // Zoom yang sedikit lebih dekat untuk melihat detail
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            _setupMarkers();
          },
          onTap: (_) {
            // Deselect salon when map is tapped
            setState(() {
              _selectedSalon = null;
            });
          },
        ),

        // Search Bar
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: 'Search nearby salons...',
                hintStyle: TextStyle(color: AppColors.grey),
                prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune, color: AppColors.grey),
                  onPressed: _showFilterDialog,
                ),
                filled: true,
                fillColor: AppColors.primary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                salonProvider.searchSalons(value);
                _setupMarkers();
              },
            ),
          ),
        ),

        // Selected Salon Card
        if (_selectedSalon != null)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Material(
              borderRadius: BorderRadius.circular(16),
              elevation: 8,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _selectedSalon!.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 60,
                              height: 60,
                              color: AppColors.darkGrey,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedSalon!.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      color: AppColors.text,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: AppColors.secondary, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    _selectedSalon!.rating.toStringAsFixed(1),
                                    style:
                                        const TextStyle(color: AppColors.text),
                                  ),
                                  if (_selectedSalon!.distance != null) ...[
                                    const SizedBox(width: 8),
                                    const Icon(Icons.location_on,
                                        size: 16, color: AppColors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${(_selectedSalon!.distance! / 1000).toStringAsFixed(1)} km',
                                      style: const TextStyle(
                                          color: AppColors.grey),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.grey),
                          onPressed: () {
                            setState(() {
                              _selectedSalon = null;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(
                              () => SalonDetailScreen(salon: _selectedSalon!));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('View Details'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Legend
        Positioned(
          top: 80,
          right: 16,
          child: Material(
            borderRadius: BorderRadius.circular(8),
            elevation: 4,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('You',
                          style:
                              TextStyle(color: AppColors.text, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('Salon',
                          style:
                              TextStyle(color: AppColors.text, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('Home Service',
                          style:
                              TextStyle(color: AppColors.text, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Floating Action Button
        Positioned(
          bottom: _selectedSalon != null ? 220 : 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.primary,
            onPressed: () {
              // Calculate center point of all salons to fit them all in view
              if (salonProvider.salons.isNotEmpty) {
                final salons = salonProvider.salons;

                // Get bounds
                double minLat = salons
                    .map((s) => s.latitude)
                    .reduce((a, b) => a < b ? a : b);
                double maxLat = salons
                    .map((s) => s.latitude)
                    .reduce((a, b) => a > b ? a : b);
                double minLng = salons
                    .map((s) => s.longitude)
                    .reduce((a, b) => a < b ? a : b);
                double maxLng = salons
                    .map((s) => s.longitude)
                    .reduce((a, b) => a > b ? a : b);

                // Add some padding
                final latPadding = (maxLat - minLat) * 0.1;
                final lngPadding = (maxLng - minLng) * 0.1;

                _mapController?.animateCamera(
                  CameraUpdate.newLatLngBounds(
                    LatLngBounds(
                      southwest:
                          LatLng(minLat - latPadding, minLng - lngPadding),
                      northeast:
                          LatLng(maxLat + latPadding, maxLng + lngPadding),
                    ),
                    50, // padding in pixels
                  ),
                );
              }
            },
            child: const Icon(Icons.map),
            tooltip: 'Show all salons',
          ),
        ),
      ],
    );
  }
}

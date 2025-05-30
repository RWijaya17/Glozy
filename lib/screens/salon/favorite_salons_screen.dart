import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/salon_provider.dart';
import '../../models/salon_model.dart';
import '../../widgets/salon_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../salon/salon_detail_screen.dart';

class FavoriteSalonsScreen extends StatefulWidget {
  const FavoriteSalonsScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteSalonsScreen> createState() => _FavoriteSalonsScreenState();
}

class _FavoriteSalonsScreenState extends State<FavoriteSalonsScreen> {
  List<SalonModel> _favoriteSalons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteSalons();

    // Add listener here instead of in build
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    // Remove listener when widget is disposed
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }

  // Separate callback for auth changes
  void _onAuthChanged() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userModel != null && mounted) {
      _loadFavoriteSalons();
    }
  }

  Future<void> _loadFavoriteSalons() async {
    // Check if mounted before continuing
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final salonProvider = Provider.of<SalonProvider>(context, listen: false);

    final user = authProvider.userModel;
    if (user != null && user.favorites.isNotEmpty) {
      if (mounted) setState(() => _isLoading = true);

      // Get all salons
      await salonProvider.fetchSalons();

      // Check if still mounted after async operation
      if (!mounted) return;

      // Filter favorite salons
      final favoriteSalons = salonProvider.salons
          .where((salon) => user.favorites.contains(salon.id))
          .toList();

      if (mounted) {
        setState(() {
          _favoriteSalons = favoriteSalons;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Remove the listener from build method

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Favorite Salons'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (context, index) => const ShimmerSalonCard(),
            )
          : _favoriteSalons.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: AppColors.secondary,
                  backgroundColor: AppColors.primary,
                  onRefresh: () async {
                    await _loadFavoriteSalons();
                  },
                  child: ListView.builder(
                    itemCount: _favoriteSalons.length,
                    itemBuilder: (context, index) {
                      final salon = _favoriteSalons[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: SalonCard(
                          salon: salon,
                          onTap: () {
                            Get.to(() => SalonDetailScreen(salon: salon))
                                ?.then((_) => _loadFavoriteSalons());
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 64,
            color: AppColors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No Favorite Salons',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: AppColors.grey,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding salons to your favorites\nand they will appear here.',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.grey,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Go to home tab
              DefaultTabController.of(context)?.animateTo(0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Browse Salons'),
          ),
        ],
      ),
    );
  }
}

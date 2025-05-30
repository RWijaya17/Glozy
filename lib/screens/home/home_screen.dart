import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/salon_provider.dart';
import '../../models/salon_model.dart'; // Tambahkan import ini untuk SalonModel
import '../../widgets/custom_text_field.dart';
import '../../widgets/icon_text_button.dart';
import '../../widgets/filter_dialog.dart';
import '../salon/salon_list_screen.dart';
import '../salon/salon_maps_screen.dart';
import '../salon/salon_detail_screen.dart';
import '../../widgets/salon_card.dart';
import '../../widgets/shimmer_loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _selectedView = 'list'; // 'list' atau 'map'
  String _selectedSort = 'distance';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final salonProvider = Provider.of<SalonProvider>(context, listen: false);
      salonProvider.fetchSalons();
      salonProvider.getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

    // Ambil data salon yang sudah ada
    final salons = List<SalonModel>.from(salonProvider.salons);

    // Apply filter
    List<SalonModel> filteredSalons;
    switch (_selectedFilter) {
      case 'home_service':
        filteredSalons = salons.where((salon) => salon.homeService).toList();
        break;
      case 'high_rated':
        filteredSalons = salons.where((salon) => salon.rating >= 4.0).toList();
        break;
      default:
        filteredSalons = List<SalonModel>.from(salons);
    }

    // Apply sort dengan null safety
    switch (_selectedSort) {
      case 'distance':
        filteredSalons.sort((a, b) {
          final aDistance = a.distance ?? double.infinity;
          final bDistance = b.distance ?? double.infinity;
          return aDistance.compareTo(bDistance);
        });
        break;
      case 'rating':
        filteredSalons.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
        filteredSalons.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    // Update filtered salons di provider
    salonProvider.filteredSalons = filteredSalons;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.userModel;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Text(
                  'GLOZY',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // TODO: Navigate to notifications
                  },
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Welcome Section dengan nama user
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.name?.isNotEmpty == true ? user!.name : "User"}!',
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                color: AppColors.text,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(
                      'Find your perfect salon',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: AppColors.grey,
                          ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _searchController,
                        label: 'Search salons...',
                        prefixIcon: Icons.search,
                        onChanged: (value) {
                          final salonProvider = Provider.of<SalonProvider>(
                              context,
                              listen: false);
                          salonProvider.searchSalons(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune, color: AppColors.text),
                        onPressed: _showFilterDialog,
                      ),
                    ),
                  ],
                ),
              ),

              // View Toggle
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconTextButton(
                          icon: Icons.list,
                          text: 'List',
                          isSelected: _selectedView == 'list',
                          onPressed: () {
                            setState(() => _selectedView = 'list');
                          },
                        ),
                        const SizedBox(width: 16),
                        IconTextButton(
                          icon: Icons.map,
                          text: 'Map',
                          isSelected: _selectedView == 'map',
                          onPressed: () {
                            setState(() => _selectedView = 'map');
                          },
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Get.to(() => const SalonListScreen());
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(color: AppColors.secondary),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedSort != 'distance' || _selectedFilter != 'all')
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        color: AppColors.primary.withOpacity(0.5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Sorted by: ${_formatSortName(_selectedSort)} | Filter: ${_formatFilterName(_selectedFilter)}',
                                style: TextStyle(
                                    color: AppColors.grey, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedSort = 'distance';
                                  _selectedFilter = 'all';
                                });
                                _applyFilters();
                              },
                              child: Text('Reset',
                                  style: TextStyle(color: AppColors.accent)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Salon List or Map
              Expanded(
                child: Consumer<SalonProvider>(
                  builder: (context, salonProvider, _) {
                    return _selectedView == 'list'
                        ? _buildSalonList(salonProvider)
                        : _buildSalonMap(salonProvider);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSalonList(SalonProvider salonProvider) {
    if (salonProvider.isLoading) {
      return ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) => const ShimmerSalonCard(),
      );
    }

    if (salonProvider.filteredSalons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.grey),
            const SizedBox(height: 16),
            Text(
              'No salons found',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: salonProvider.filteredSalons.length,
      itemBuilder: (context, index) {
        final salon = salonProvider.filteredSalons[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SalonCard(
            salon: salon,
            onTap: () => Get.to(() => SalonDetailScreen(salon: salon)),
          ),
        );
      },
    );
  }

  Widget _buildSalonMap(SalonProvider salonProvider) {
    if (salonProvider.salons.isEmpty && salonProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      );
    }

    // Pastikan SalonMapsScreen menerima data yang dibutuhkan
    return const SalonMapsScreen();
  }

  String _formatSortName(String sort) {
    switch (sort) {
      case 'distance':
        return 'Distance';
      case 'rating':
        return 'Rating';
      case 'name':
        return 'Name';
      default:
        return 'Default';
    }
  }

  String _formatFilterName(String filter) {
    switch (filter) {
      case 'all':
        return 'All Salons';
      case 'home_service':
        return 'Home Service';
      case 'high_rated':
        return 'Highly Rated';
      default:
        return 'All';
    }
  }
}

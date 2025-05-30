import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../providers/salon_provider.dart';
import '../../widgets/salon_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../../models/salon_model.dart';
import '../salon/salon_detail_screen.dart';

class SalonListScreen extends StatefulWidget {
  const SalonListScreen({Key? key}) : super(key: key);

  @override
  State<SalonListScreen> createState() => _SalonListScreenState();
}

class _SalonListScreenState extends State<SalonListScreen> {
  final _searchController = TextEditingController();
  String _selectedSort = 'distance';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final salonProvider = Provider.of<SalonProvider>(context, listen: false);
      if (salonProvider.salons.isEmpty) {
        salonProvider.fetchSalons();
      }
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
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primary,
        title: Text(
          'Filter & Sort',
          style: TextStyle(color: AppColors.text),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sort Options
              Text(
                'Sort By',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ..._buildSortOptions(),
              const SizedBox(height: 16),

              // Filter Options
              Text(
                'Filter',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ..._buildFilterOptions(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () {
              _applyFilters();
              Get.back();
            },
            child: Text('Apply', style: TextStyle(color: AppColors.secondary)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSortOptions() {
    return [
      RadioListTile<String>(
        title: Text('Distance', style: TextStyle(color: AppColors.text)),
        value: 'distance',
        groupValue: _selectedSort,
        activeColor: AppColors.secondary,
        onChanged: (value) => setState(() => _selectedSort = value!),
      ),
      RadioListTile<String>(
        title: Text('Rating', style: TextStyle(color: AppColors.text)),
        value: 'rating',
        groupValue: _selectedSort,
        activeColor: AppColors.secondary,
        onChanged: (value) => setState(() => _selectedSort = value!),
      ),
      RadioListTile<String>(
        title: Text('Name', style: TextStyle(color: AppColors.text)),
        value: 'name',
        groupValue: _selectedSort,
        activeColor: AppColors.secondary,
        onChanged: (value) => setState(() => _selectedSort = value!),
      ),
    ];
  }

  List<Widget> _buildFilterOptions() {
    return [
      RadioListTile<String>(
        title: Text('All Salons', style: TextStyle(color: AppColors.text)),
        value: 'all',
        groupValue: _selectedFilter,
        activeColor: AppColors.secondary,
        onChanged: (value) => setState(() => _selectedFilter = value!),
      ),
      RadioListTile<String>(
        title: Text('Home Service Available',
            style: TextStyle(color: AppColors.text)),
        value: 'home_service',
        groupValue: _selectedFilter,
        activeColor: AppColors.secondary,
        onChanged: (value) => setState(() => _selectedFilter = value!),
      ),
      RadioListTile<String>(
        title:
            Text('Highly Rated (4+)', style: TextStyle(color: AppColors.text)),
        value: 'high_rated',
        groupValue: _selectedFilter,
        activeColor: AppColors.secondary,
        onChanged: (value) => setState(() => _selectedFilter = value!),
      ),
    ];
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

    // Apply sort
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
  }

  @override
  Widget build(BuildContext context) {
    final salonProvider = Provider.of<SalonProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('All Salons'),
        actions: [
          IconButton(
            icon: Icon(Icons.tune),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: 'Search salons...',
                hintStyle: TextStyle(color: AppColors.grey),
                prefixIcon: Icon(Icons.search, color: AppColors.grey),
                filled: true,
                fillColor: AppColors.primary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.lightGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.lightGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.secondary),
                ),
              ),
              onChanged: (value) {
                salonProvider.searchSalons(value);
              },
            ),
          ),

          // Sort and Filter Info
          if (_selectedSort != 'distance' || _selectedFilter != 'all')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.primary.withOpacity(0.5),
              child: Row(
                children: [
                  Text(
                    'Sorted by: $_selectedSort | Filter: $_selectedFilter',
                    style: TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                  const Spacer(),
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

          // Salon List
          Expanded(
            child: salonProvider.isLoading
                ? ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => const ShimmerSalonCard(),
                  )
                : salonProvider.filteredSalons.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: AppColors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No salons found',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    color: AppColors.grey,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filters',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: AppColors.grey,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.secondary,
                        backgroundColor: AppColors.primary,
                        onRefresh: salonProvider.refreshSalons,
                        child: ListView.builder(
                          itemCount: salonProvider.filteredSalons.length,
                          itemBuilder: (context, index) {
                            final salon = salonProvider.filteredSalons[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: SalonCard(
                                salon: salon,
                                onTap: () {
                                  Get.to(() => SalonDetailScreen(salon: salon));
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

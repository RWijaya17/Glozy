import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/booking_model.dart';
import '../../widgets/booking_card.dart';
import '../../widgets/shimmer_loading.dart';
import 'booking_detail_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Gunakan Future.delayed untuk menghindari setState during build
    Future.delayed(Duration.zero, () {
      if (mounted) _loadBookings();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Perhatikan: jangan memanggil fetchUserBookings di sini
    // karena dapat menyebabkan loop tak terbatas
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        final userId = authProvider.currentUser!.uid;
        setState(() {
          _currentUserId = userId;
        });
        debugPrint('Loading bookings for user: $userId');
        await Provider.of<BookingProvider>(context, listen: false)
            .fetchUserBookings(userId);
      } else {
        debugPrint('No current user found!');
      }
    } catch (e) {
      debugPrint('Error in _loadBookings: $e');
    }
  }

  // Modifikasi fungsi _filterUserBookings
  List<BookingModel> _filterUserBookings(List<BookingModel> bookings) {
    // Karena fetchUserBookings sudah mengambil booking berdasarkan userId,
    // filter tambahan ini seharusnya tidak diperlukan.
    // Tapi untuk keamanan, kita tetap filter lagi

    if (_currentUserId == null) return [];

    final filteredBookings =
        bookings.where((booking) => booking.userId == _currentUserId).toList();

    debugPrint(
        'Filtered ${bookings.length} bookings to ${filteredBookings.length}');
    return filteredBookings;
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.grey,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Active'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingOrders(bookingProvider),
          _buildActiveOrders(bookingProvider),
          _buildPastOrders(bookingProvider),
        ],
      ),
    );
  }

  Widget _buildUpcomingOrders(BookingProvider bookingProvider) {
    // Debug info
    debugPrint('Building upcoming orders...');
    debugPrint('Total bookings: ${bookingProvider.bookings.length}');

    final allUpcoming = bookingProvider.getUpcomingBookings();
    debugPrint('Total upcoming bookings: ${allUpcoming.length}');

    final upcomingBookings = _filterUserBookings(allUpcoming);
    debugPrint('Filtered upcoming bookings: ${upcomingBookings.length}');

    if (bookingProvider.isLoading) {
      return ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) => const ShimmerSalonCard(),
      );
    }

    if (upcomingBookings.isEmpty) {
      return _buildEmptyState('No upcoming bookings');
    }

    return RefreshIndicator(
      color: AppColors.secondary,
      backgroundColor: AppColors.primary,
      onRefresh: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.currentUser != null) {
          await bookingProvider
              .fetchUserBookings(authProvider.currentUser!.uid);
        }
      },
      child: ListView.builder(
        itemCount: upcomingBookings.length,
        itemBuilder: (context, index) {
          final booking = upcomingBookings[index];
          return BookingCard(
            booking: booking,
            onTap: () {
              Get.to(() => BookingDetailScreen(booking: booking));
            },
          );
        },
      ),
    );
  }

  Widget _buildActiveOrders(BookingProvider bookingProvider) {
    // Filter untuk memastikan hanya booking milik user yang ditampilkan
    final allActive = bookingProvider.activeBookings;
    final activeBookings = _filterUserBookings(allActive);

    if (bookingProvider.isLoading) {
      return ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) => const ShimmerSalonCard(),
      );
    }

    if (activeBookings.isEmpty) {
      return _buildEmptyState('No active bookings');
    }

    return RefreshIndicator(
      color: AppColors.secondary,
      backgroundColor: AppColors.primary,
      onRefresh: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.currentUser != null) {
          await bookingProvider
              .fetchUserBookings(authProvider.currentUser!.uid);
        }
      },
      child: ListView.builder(
        itemCount: activeBookings.length,
        itemBuilder: (context, index) {
          final booking = activeBookings[index];
          return BookingCard(
            booking: booking,
            onTap: () {
              Get.to(() => BookingDetailScreen(booking: booking));
            },
          );
        },
      ),
    );
  }

  Widget _buildPastOrders(BookingProvider bookingProvider) {
    // Filter untuk memastikan hanya booking milik user yang ditampilkan
    final allPast = bookingProvider.getPastBookings();
    final pastBookings = _filterUserBookings(allPast);

    if (bookingProvider.isLoading) {
      return ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) => const ShimmerSalonCard(),
      );
    }

    if (pastBookings.isEmpty) {
      return _buildEmptyState('No past bookings');
    }

    return RefreshIndicator(
      color: AppColors.secondary,
      backgroundColor: AppColors.primary,
      onRefresh: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.currentUser != null) {
          await bookingProvider
              .fetchUserBookings(authProvider.currentUser!.uid);
        }
      },
      child: ListView.builder(
        itemCount: pastBookings.length,
        itemBuilder: (context, index) {
          final booking = pastBookings[index];
          return BookingCard(
            booking: booking,
            onTap: () {
              Get.to(() => BookingDetailScreen(booking: booking));
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 64,
            color: AppColors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: AppColors.grey,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your bookings will appear here',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.grey,
                ),
          ),
        ],
      ),
    );
  }
}

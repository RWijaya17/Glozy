import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<BookingModel> _bookings = [];
  List<BookingModel> get bookings => _bookings;

  List<BookingModel> get activeBookings {
    if (_bookings.isEmpty) return [];

    debugPrint('Total bookings before getting active: ${_bookings.length}');

    final now = DateTime.now();
    final active = _bookings
        .where((booking) =>
            booking.status == BookingStatus.confirmed ||
            booking.status == BookingStatus.inProgress ||
            booking.status == BookingStatus.onTheWay)
        .toList();

    debugPrint('Found ${active.length} active bookings');
    return active;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTime _lastFetchTime = DateTime(2000); // Default old time
  DateTime get lastFetchTime => _lastFetchTime;

  // Create a new booking
  Future<bool> createBooking(BookingModel booking) async {
    try {
      // Konversi services ke format yang dapat disimpan di Firestore
      final List<Map<String, dynamic>> servicesMap = booking.services
          .map((service) => {
                'id': service.id,
                'name': service.name,
                'price': service.price,
                'duration': service.duration,
              })
          .toList();

      // Data yang akan disimpan di Firestore
      final Map<String, dynamic> bookingData = {
        'id': booking.id,
        'userId': booking.userId,
        'salonId': booking.salonId,
        'salonName': booking.salonName,
        'salonAddress': booking.salonAddress,
        'salonImage': booking.salonImage,
        'services': servicesMap,
        'bookingDate': booking.bookingDate.toIso8601String(),
        'timeSlot': booking.timeSlot,
        'isHomeService': booking.isHomeService,
        'totalPrice': booking.totalPrice,
        'status': booking.status.toString().split('.').last,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Hanya tambahkan field nullable jika nilainya tidak null
      if (booking.notes != null) bookingData['notes'] = booking.notes;
      if (booking.customerAddress != null)
        bookingData['customerAddress'] = booking.customerAddress;
      if (booking.customerLatitude != null)
        bookingData['customerLatitude'] = booking.customerLatitude;
      if (booking.customerLongitude != null)
        bookingData['customerLongitude'] = booking.customerLongitude;
      if (booking.barberId != null) bookingData['barberId'] = booking.barberId;
      if (booking.barberName != null)
        bookingData['barberName'] = booking.barberName;

      await _firestore.collection('bookings').doc(booking.id).set(bookingData);

      // Tambahkan booking ke daftar lokal
      _bookings.add(booking);
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error creating booking: $e');
      return false;
    }
  }

  // Fetch user's bookings
  Future<void> fetchUserBookings(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('Fetching bookings for user: $userId');

      // Ubah query untuk tidak menggunakan orderBy, menghindari error composite index
      final QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .get();

      debugPrint('Found ${snapshot.docs.length} bookings for user: $userId');

      if (snapshot.docs.isEmpty) {
        _bookings = [];
        _isLoading = false;
        _lastFetchTime = DateTime.now();
        notifyListeners();
        return;
      }

      // Process bookings data
      List<BookingModel> loadedBookings = [];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          loadedBookings.add(BookingModel.fromJson({
            'id': doc.id,
            ...data,
          }));
        } catch (e) {
          debugPrint('Error parsing booking: ${doc.id}, Error: $e');
        }
      }

      // Sort after loading
      loadedBookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));

      _bookings = loadedBookings;
      _isLoading = false;
      _lastFetchTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user bookings: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus(
      String bookingId, BookingStatus status) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(bookingId)
          .update({'status': status.toString()});

      // Update local bookings
      final bookingIndex = _bookings.indexWhere((b) => b.id == bookingId);
      if (bookingIndex != -1) {
        final updatedBooking = BookingModel(
          id: _bookings[bookingIndex].id,
          userId: _bookings[bookingIndex].userId,
          salonId: _bookings[bookingIndex].salonId,
          salonName: _bookings[bookingIndex].salonName,
          salonAddress: _bookings[bookingIndex].salonAddress,
          salonImage: _bookings[bookingIndex].salonImage,
          services: _bookings[bookingIndex].services,
          bookingDate: _bookings[bookingIndex].bookingDate,
          timeSlot: _bookings[bookingIndex].timeSlot,
          isHomeService: _bookings[bookingIndex].isHomeService,
          customerAddress: _bookings[bookingIndex].customerAddress,
          customerLatitude: _bookings[bookingIndex].customerLatitude,
          customerLongitude: _bookings[bookingIndex].customerLongitude,
          totalPrice: _bookings[bookingIndex].totalPrice,
          status: status,
          createdAt: _bookings[bookingIndex].createdAt,
          notes: _bookings[bookingIndex].notes,
          barberId: _bookings[bookingIndex].barberId,
          barberName: _bookings[bookingIndex].barberName,
        );

        _bookings[bookingIndex] = updatedBooking;

        notifyListeners();
      }

      return true;
    } catch (e) {
      print('Error updating booking status: $e');
      return false;
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      debugPrint('Attempting to cancel booking: $bookingId');

      // Update status booking di Firestore
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'updatedAt': Timestamp.now(),
      });

      // Update status booking di local state juga
      final index = _bookings.indexWhere((booking) => booking.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          status: BookingStatus.cancelled,
        );
        debugPrint(
            'Booking cancelled successfully both in Firestore and local state');
        notifyListeners();
      } else {
        debugPrint(
            'Warning: Booking updated in Firestore but not found in local state');
        // Refresh data jika tidak ditemukan di local state
        final userId = _bookings.isNotEmpty ? _bookings[0].userId : null;
        if (userId != null) {
          await fetchUserBookings(userId);
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error cancelling booking: $e');
      return false;
    }
  }

  // Get booking by ID
  BookingModel? getBookingById(String bookingId) {
    try {
      return _bookings.firstWhere((booking) => booking.id == bookingId);
    } catch (e) {
      return null;
    }
  }

  // Get bookings by status
  List<BookingModel> getBookingsByStatus(BookingStatus status) {
    return _bookings.where((booking) => booking.status == status).toList();
  }

  // Get upcoming bookings
  List<BookingModel> getUpcomingBookings() {
    if (_bookings.isEmpty) return [];

    debugPrint('Total bookings before getting upcoming: ${_bookings.length}');

    final now = DateTime.now();
    final upcomingBookings = _bookings.where((booking) {
      // Perbaikan logika untuk mengidentifikasi "upcoming" bookings
      return booking.status == BookingStatus.pending ||
          (booking.status == BookingStatus.confirmed &&
              booking.bookingDate.isAfter(now));
    }).toList();

    debugPrint('Found ${upcomingBookings.length} upcoming bookings');
    return upcomingBookings;
  }

  // Get past bookings
  List<BookingModel> getPastBookings() {
    if (_bookings.isEmpty) return [];

    debugPrint('Total bookings before getting past: ${_bookings.length}');

    final pastBookings = _bookings
        .where((booking) =>
            booking.status == BookingStatus.completed ||
            booking.status == BookingStatus.cancelled)
        .toList();

    debugPrint('Found ${pastBookings.length} past bookings');
    return pastBookings;
  }

  // Listen to booking updates (for real-time status updates)
  Stream<BookingModel> listenToBooking(String bookingId) {
    return _firestore
        .collection('bookings')
        .doc(bookingId)
        .snapshots()
        .map((doc) => BookingModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }));
  }

  // Add review to booking
  Future<bool> addReview(
      String bookingId, double rating, String comment) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'review': {
          'rating': rating,
          'comment': comment,
          'createdAt': DateTime.now().toIso8601String(),
        }
      });

      return true;
    } catch (e) {
      print('Error adding review: $e');
      return false;
    }
  }

  // Schedule booking notification (for future implementation with push notifications)
  void scheduleBookingReminder(BookingModel booking) {
    // This will be implemented when adding push notification support
    // For now, it's a placeholder
  }

  // Calculate estimated travel time for home service
  Future<int?> calculateTravelTime(
    double salonLat,
    double salonLng,
    double customerLat,
    double customerLng,
  ) async {
    try {
      // Implement Google Directions API call here
      // For now, return a placeholder value
      // This should be implemented with actual Google Directions API
      return 30; // 30 minutes placeholder
    } catch (e) {
      print('Error calculating travel time: $e');
      return null;
    }
  }

  // Clear bookings (useful for logout)
  void clearBookings() {
    _bookings = [];
    notifyListeners();
  }
}

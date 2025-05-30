import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/booking_model.dart';
import '../../utils/app_colors.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart'; // Tambahkan import ini
import '../../widgets/custom_button.dart';

class BookingDetailScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailScreen({
    Key? key,
    required this.booking,
  }) : super(key: key);

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.confirmed:
        return AppColors.info;
      case BookingStatus.inProgress:
        return AppColors.secondary;
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.cancelled:
        return AppColors.error;
      case BookingStatus.onTheWay:
        return AppColors.accent;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending Confirmation';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.onTheWay:
        return 'Barber on the Way';
    }
  }

  void _showCancelDialog(BuildContext context) {
    // Cek apakah booking boleh dicancel (hanya status pending dan confirmed)
    if (booking.status != BookingStatus.pending &&
        booking.status != BookingStatus.confirmed) {
      Get.snackbar(
        'Cannot Cancel',
        'This booking can no longer be cancelled',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primary,
        title: Text(
          'Cancel Booking',
          style: TextStyle(color: AppColors.text),
        ),
        content: Text(
          'Are you sure you want to cancel this booking?',
          style: TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('No', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () async {
              // Tutup dialog konfirmasi
              Get.back();

              // Tampilkan loading indicator
              Get.dialog(
                Center(
                  child: CircularProgressIndicator(
                    color: AppColors.secondary,
                  ),
                ),
                barrierDismissible: false,
              );

              final bookingProvider =
                  Provider.of<BookingProvider>(context, listen: false);
              final success = await bookingProvider.cancelBooking(booking.id);

              // Tutup loading indicator
              Get.back();

              if (success) {
                // Tampilkan snackbar
                Get.snackbar(
                  'Success',
                  'Booking cancelled successfully',
                  backgroundColor: AppColors.success,
                  colorText: AppColors.white,
                );

                // Kembali ke halaman sebelumnya
                Get.back();

                // Tunggu sejenak lalu refresh booking data
                Future.delayed(Duration(milliseconds: 300), () {
                  if (Get.context != null) {
                    final authProvider =
                        Provider.of<AuthProvider>(Get.context!, listen: false);
                    final bookingProvider = Provider.of<BookingProvider>(
                        Get.context!,
                        listen: false);
                    if (authProvider.currentUser != null) {
                      bookingProvider
                          .fetchUserBookings(authProvider.currentUser!.uid);
                    }
                  }
                });
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to cancel booking',
                  backgroundColor: AppColors.error,
                  colorText: AppColors.white,
                );
              }
            },
            child: Text('Yes', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    final statusText = _getStatusText(booking.status);
    final statusColor = _getStatusColor(booking.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (booking.status == BookingStatus.onTheWay)
            const SizedBox(height: 12),
          if (booking.status == BookingStatus.onTheWay)
            Row(
              children: [
                Icon(Icons.directions_car, size: 16, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  'Estimated arrival: 15-20 minutes',
                  style: TextStyle(color: AppColors.grey),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, y');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Booking Details'),
        actions: [
          if (booking.status == BookingStatus.completed)
            IconButton(
              icon: const Icon(Icons.rate_review),
              onPressed: () {
                // TODO: Implement review functionality
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Section
            _buildStatusSection(),

            const SizedBox(height: 24),

            // Booking Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: booking.salonImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
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
                              booking.salonName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              booking.isHomeService
                                  ? 'Home Service'
                                  : booking.salonAddress,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: AppColors.grey,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.lightGrey),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                      'Booking ID', booking.id.substring(0, 8).toUpperCase()),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Date & Time',
                    '${dateFormat.format(booking.bookingDate)} at ${booking.timeSlot}',
                  ),
                  if (booking.isHomeService &&
                      booking.customerAddress != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Service Address', booking.customerAddress!),
                  ],
                  if (booking.barberName != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Barber', booking.barberName!),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Services Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Services',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...booking.services.map((service) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: TextStyle(color: AppColors.text),
                              ),
                              Text(
                                '${service.duration} min',
                                style: TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Rp ${service.price.toStringAsFixed(0)}',
                            style: TextStyle(color: AppColors.text),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  if (booking.isHomeService) ...[
                    const Divider(color: AppColors.lightGrey),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Home Service Fee',
                            style: TextStyle(color: AppColors.text),
                          ),
                          Text(
                            'Rp ${(booking.totalPrice - booking.services.fold(0, (sum, service) => sum + service.price)).toStringAsFixed(0)}',
                            style: TextStyle(color: AppColors.text),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Divider(color: AppColors.lightGrey),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'Rp ${booking.totalPrice.toStringAsFixed(0)}',
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      booking.notes!,
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Action Buttons
            if (booking.status == BookingStatus.pending) ...[
              CustomButton(
                text: 'Cancel Booking',
                onPressed: () => _showCancelDialog(context),
                backgroundColor: AppColors.error,
                textColor: AppColors.white,
              ),
            ] else if (booking.status == BookingStatus.completed) ...[
              CustomButton(
                text: 'Book Again',
                onPressed: () {
                  // TODO: Navigate to booking form with same services
                },
                icon: Icons.refresh,
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(color: AppColors.grey),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: AppColors.text),
          ),
        ),
      ],
    );
  }
}

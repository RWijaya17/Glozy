import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/seed_data.dart';
import '../../utils/app_colors.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final seedService = FirestoreSeedService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Database Management',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await seedService.seedAllData();
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Failed to seed data: $e',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      icon: Icon(Icons.dataset),
                      label: Text('Seed All Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await seedService.seedUsers();
                                Get.snackbar(
                                  'Success',
                                  'User data has been added',
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              } catch (e) {
                                Get.snackbar(
                                  'Error',
                                  'Failed to seed users: $e',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            },
                            icon: Icon(Icons.person_add),
                            label: Text('Add Users'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await seedService.seedSalons();
                                Get.snackbar(
                                  'Success',
                                  'Salon data has been added',
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              } catch (e) {
                                Get.snackbar(
                                  'Error',
                                  'Failed to seed salons: $e',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            },
                            icon: Icon(Icons.store),
                            label: Text('Add Salons'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await seedService.seedBookings();
                          Get.snackbar(
                            'Success',
                            'Booking data has been added',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Failed to seed bookings: $e',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      icon: Icon(Icons.calendar_today),
                      label: Text('Add Bookings'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tambahan UI lainnya di halaman admin bisa ditambahkan di sini
          ],
        ),
      ),
    );
  }
}

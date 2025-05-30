import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  Widget _buildInfoSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: AppColors.text,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.secondary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('About Glozy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo and Name
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      'GLOZY',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Salon & Barber Service',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // About Section
            _buildInfoSection(
              'About Us',
              'Glozy is your ultimate destination for premium salon and barber services. We connect you with the best salons in your area and bring professional grooming services directly to your doorstep.',
            ),

            // Mission Section
            _buildInfoSection(
              'Our Mission',
              'To revolutionize the beauty and grooming industry by making professional services accessible to everyone, anytime, anywhere. We believe that looking good should be convenient and hassle-free.',
            ),

            // Features Section
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
                    'Key Features',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    Icons.location_on_outlined,
                    'Find Nearby Salons',
                    'Discover the best salons in your area with real-time location tracking.',
                  ),
                  _buildFeatureItem(
                    Icons.home_outlined,
                    'Home Service',
                    'Get professional grooming services at your home or office.',
                  ),
                  _buildFeatureItem(
                    Icons.star_outline,
                    'Reviews & Ratings',
                    'Read authentic reviews from other customers and rate your experience.',
                  ),
                  _buildFeatureItem(
                    Icons.calendar_today_outlined,
                    'Easy Booking',
                    'Book your appointment with just a few taps, anytime, anywhere.',
                  ),
                  _buildFeatureItem(
                    Icons.favorite_outline,
                    'Save Favorites',
                    'Keep track of your favorite salons for quick future bookings.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Contact Section
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
                    'Get in Touch',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.email_outlined,
                          color: AppColors.grey, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'support@glozy.com',
                        style: TextStyle(color: AppColors.text),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined,
                          color: AppColors.grey, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '+62 812-3456-7890',
                        style: TextStyle(color: AppColors.text),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: AppColors.grey, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cimahi, West Java, Indonesia',
                          style: TextStyle(color: AppColors.text),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Copyright
            Text(
              '© 2025 Glozy. All rights reserved.',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

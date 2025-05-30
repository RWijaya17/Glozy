import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      iconColor: AppColors.secondary,
      collapsedIconColor: AppColors.grey,
      title: Text(
        question,
        style: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: TextStyle(
              color: AppColors.grey,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactOption(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.secondary),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.grey),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: AppColors.grey, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help Center'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildFAQItem(
                    'How to book a salon service?',
                    'You can book a salon service by browsing the salons in the app, selecting the service you want, choosing a time slot, and confirming your booking.',
                  ),
                  _buildFAQItem(
                    'Can I cancel my booking?',
                    'Yes, you can cancel your booking from the My Orders screen. Please note that cancellation policies may apply.',
                  ),
                  _buildFAQItem(
                    'How does home service work?',
                    'Home service allows a barber to come to your location. Simply select the home service option when booking, provide your address, and the barber will arrive at your specified time.',
                  ),
                  _buildFAQItem(
                    'What payment methods are accepted?',
                    'Currently, we accept cash payments. Online payment options will be available soon.',
                  ),
                  _buildFAQItem(
                    'How do I add a salon to favorites?',
                    'You can add a salon to favorites by tapping the heart icon on the salon detail screen or on the salon card.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Contact Support Section
            Text(
              'Still Need Help?',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildContactOption(
                    'Email Support',
                    'Get a response within 24 hours',
                    Icons.email_outlined,
                    () async {
                      final Uri emailUri = Uri(
                        scheme: 'mailto',
                        path: 'support@glozy.com',
                        query: 'subject=Glozy App Support',
                      );
                      if (await canLaunchUrl(emailUri)) {
                        await launchUrl(emailUri);
                      }
                    },
                  ),
                  _buildContactOption(
                    'WhatsApp Support',
                    'Chat with us directly',
                    Icons.chat_outlined,
                    () async {
                      final Uri whatsappUri =
                          Uri.parse('https://wa.me/6281234567890');
                      if (await canLaunchUrl(whatsappUri)) {
                        await launchUrl(whatsappUri);
                      }
                    },
                  ),
                  _buildContactOption(
                    'Call Us',
                    'Available 9 AM - 6 PM',
                    Icons.phone_outlined,
                    () async {
                      final Uri phoneUri =
                          Uri(scheme: 'tel', path: '+6281234567890');
                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(phoneUri);
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // App Version Info
            Center(
              child: Column(
                children: [
                  Text(
                    'Glozy v1.0.0',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppColors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2025 Glozy. All rights reserved.',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppColors.grey,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

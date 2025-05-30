import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_colors.dart';
import '../admin/admin_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../salon/favorite_salons_screen.dart';
import '../booking/my_orders_screen.dart';
import '../support/help_screen.dart';
import '../support/about_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        Provider.of<UserProvider>(context, listen: false)
            .getUserData()
            .timeout(const Duration(seconds: 5), onTimeout: () {
          debugPrint('⚠️ Timeout getting user data');
          return;
        }),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        if (snapshot.hasError) {
          return _buildErrorScreen(context);
        }

        return Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            final user = userProvider.user;

            if (user == null) {
              return _buildNotSignedInScreen();
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('My Profile'),
                backgroundColor: AppColors.primary,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      userProvider.getUserData(forceRefresh: true);
                    },
                  ),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: user.profileImage.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: user.profileImage,
                            imageBuilder: (context, imageProvider) =>
                                CircleAvatar(
                              radius: 50,
                              backgroundImage: imageProvider,
                              backgroundColor: AppColors.secondary,
                            ),
                            placeholder: (context, url) => const CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.secondary,
                              child: CircularProgressIndicator(
                                color: AppColors.accent,
                                strokeWidth: 2,
                              ),
                            ),
                            errorWidget: (context, url, error) => CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.secondary,
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.white,
                              ),
                            ),
                          )
                        : const CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.secondary,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.grey),
                  ),
                  const SizedBox(height: 24),
                  _buildMenuCard(context),
                  if (user.email == 'admin@glozysalon.com' ||
                      user.email == 'john@example.com')
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ElevatedButton(
                        onPressed: () => Get.to(() => const AdminScreen()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Admin Dashboard'),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Failed to load profile data',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Provider.of<UserProvider>(context, listen: false)
                    .getUserData(forceRefresh: true);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotSignedInScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Please sign in to view profile'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.toNamed('/login'),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context) {
    return Card(
      color: AppColors.primary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Edit Profile
            ListTile(
              leading: Icon(Icons.person_outline, color: AppColors.grey),
              title:
                  Text('Edit Profile', style: TextStyle(color: AppColors.text)),
              trailing: Icon(Icons.chevron_right, color: AppColors.grey),
              onTap: () => Get.toNamed('/edit-profile'),
            ),

            // My Favorites - Fix untuk navigasi ke halaman favorit
            ListTile(
              leading: Icon(Icons.favorite_outline, color: AppColors.grey),
              title:
                  Text('My Favorites', style: TextStyle(color: AppColors.text)),
              trailing: Icon(Icons.chevron_right, color: AppColors.grey),
              onTap: () => Get.to(() => const FavoriteSalonsScreen()),
            ),

            // Booking History - Fix untuk navigasi ke riwayat pemesanan
            ListTile(
              leading: Icon(Icons.history, color: AppColors.grey),
              title: Text('Booking History',
                  style: TextStyle(color: AppColors.text)),
              trailing: Icon(Icons.chevron_right, color: AppColors.grey),
              onTap: () => Get.toNamed('/my-orders'),
            ),

            const Divider(color: AppColors.lightGrey),

            Text(
              'Support',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Help & Support - Fix untuk navigasi ke halaman bantuan
            ListTile(
              leading: Icon(Icons.help_outline, color: AppColors.grey),
              title: Text('Help & Support',
                  style: TextStyle(color: AppColors.text)),
              trailing: Icon(Icons.chevron_right, color: AppColors.grey),
              onTap: () => Get.toNamed('/help'),
            ),

            // About App
            ListTile(
              leading: Icon(Icons.info_outline, color: AppColors.grey),
              title: Text('About App', style: TextStyle(color: AppColors.text)),
              trailing: Icon(Icons.chevron_right, color: AppColors.grey),
              onTap: () => Get.toNamed('/about'),
            ),

            // Privacy Policy
            ListTile(
              leading: Icon(Icons.privacy_tip_outlined, color: AppColors.grey),
              title: Text('Privacy Policy',
                  style: TextStyle(color: AppColors.text)),
              trailing: Icon(Icons.chevron_right, color: AppColors.grey),
              onTap: () {
                // Implementasi bisa menggunakan webview atau browser eksternal
                // untuk sementara arahkan ke about page
                Get.toNamed('/about');
              },
            ),

            const Divider(color: AppColors.lightGrey),

            // Sign Out
            ListTile(
              leading: Icon(Icons.logout, color: AppColors.grey),
              title: Text('Sign Out', style: TextStyle(color: AppColors.grey)),
              onTap: () async {
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                await authProvider.signOut();
                Get.offAll(() => const LoginScreen());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.text),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? AppColors.text),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.grey,
      ),
      onTap: onTap,
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  final Color? textColor;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.route,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.text),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? AppColors.text),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.grey,
      ),
      onTap: () => Get.toNamed(route),
    );
  }
}

class _LogoutMenuItem extends StatelessWidget {
  const _LogoutMenuItem();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return ListTile(
      leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
      title: const Text(
        'Logout',
        style: TextStyle(color: Colors.redAccent),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.grey,
      ),
      onTap: () async {
        final result = await Get.dialog(
          AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (result == true) {
          await authProvider.signOut();
          Get.offAllNamed('/login');
        }
      },
    );
  }
}

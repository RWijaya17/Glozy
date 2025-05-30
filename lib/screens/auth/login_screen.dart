import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../../utils/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../home/main_navigation.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      debugPrint(
          'Initiating login with email: ${_emailController.text.trim()}');

      // Timeout yang lebih lama untuk koneksi lambat
      final result = await authProvider
          .signIn(
        _emailController.text.trim(),
        _passwordController.text,
      )
          .timeout(
        const Duration(seconds: 20), // Tambah timeout jadi 20 detik
        onTimeout: () {
          debugPrint('Login timeout after 20 seconds');
          Get.snackbar(
            'Login Timeout',
            'The operation took too long. Please check your connection and try again.',
            backgroundColor: AppColors.warning,
            colorText: Colors.white,
          );
          return null;
        },
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result != null) {
        debugPrint('Login successful, navigating to MainNavigation');
        Get.offAll(() => const MainNavigation());
      }
      // AuthProvider sudah menangani error messaging
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      debugPrint('Error in login method: $e');

      // PENTING: Jika error PigeonUserDetails, tetap arahkan ke halaman utama
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('List<Object?>') ||
          e.toString().contains('type \'List<Object?>\'')) {
        debugPrint('PigeonUserDetails error but attempting to continue');

        // Tambahkan snackbar yang informatif
        Get.snackbar(
          'Login Berhasil',
          'Sedang memuat profil Anda...',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Force refresh user data di background
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.forceRefreshUserData();

        // Tetap navigasi ke halaman utama
        Get.offAll(() => const MainNavigation());
        return;
      }

      // Tampilkan error umum dengan pesan yang lebih ramah
      Get.snackbar(
        'Login Error',
        'Gagal masuk ke aplikasi. Silakan coba lagi nanti.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: AppColors.grey,
                      ),
                ),
                const SizedBox(height: 48),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.grey,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Sign In',
                  isLoading: _isLoading,
                  onPressed: _login,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: AppColors.grey,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => const RegisterScreen());
                      },
                      child: Text(
                        'Sign Up',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

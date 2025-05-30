import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isLoading = false;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();

    // Inisialisasi controller kosong terlebih dulu
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();

    // Load data setelah widget diinisialisasi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;

    if (user != null) {
      setState(() {
        _nameController.text = user.name;
        _phoneController.text = user.phone;
        _addressController.text = user.address ?? ''; // Handle jika null
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // TODO: Upload image to Firebase Storage if selected
    String? profileImageUrl;

    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      profileImage: profileImageUrl,
    );

    setState(() => _isLoading = false);

    if (success) {
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
      Get.back();
    } else {
      Get.snackbar(
        'Error',
        'Failed to update profile',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    }
  }

  Widget _buildProfileImage() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.secondary,
            backgroundImage: _selectedImagePath != null
                ? FileImage(File(_selectedImagePath!)) as ImageProvider<Object>
                : (user?.profileImage.isNotEmpty ?? false)
                    ? NetworkImage(user!.profileImage) as ImageProvider<Object>
                    : null,
            child: (user?.profileImage.isEmpty ?? true) &&
                    _selectedImagePath == null
                ? Text(
                    user?.name.isNotEmpty ?? false
                        ? user!.name[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: AppColors.primary),
                onPressed: _pickImage,
                iconSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan Consumer agar UI diperbarui saat data berubah
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.userModel;

        // Isi controller dengan data yang ada saat user tersedia
        if (user != null && _nameController.text.isEmpty) {
          _nameController.text = user.name;
          _phoneController.text = user.phone;
          _addressController.text = user.address ?? ''; // Handle jika null
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Edit Profile'),
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Profile Image
                  _buildProfileImage(),

                  const SizedBox(height: 32),

                  // Name Field
                  CustomTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Phone Field
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Address Field
                  CustomTextField(
                    controller: _addressController,
                    label: 'Address',
                    prefixIcon: Icons.location_on_outlined,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 48),

                  // Save Button
                  CustomButton(
                    text: 'Save Changes',
                    onPressed: _saveProfile,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

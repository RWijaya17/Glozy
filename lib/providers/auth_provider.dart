import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../utils/app_colors.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _fetchUserData();
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<bool> checkAuthStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _fetchUserData();
      return true;
    }
    return false;
  }

  Future<void> _fetchUserData() async {
    try {
      debugPrint('Fetching user data...');
      final user = _auth.currentUser;
      if (user == null) {
        _userModel = null;
        debugPrint('No current user found');
        return;
      }

      debugPrint('Fetching data for user ${user.uid}');
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        debugPrint('User document exists with data: ${data.keys.join(', ')}');

        // Handle favorites safely
        List<String> favorites = [];
        try {
          if (data['favorites'] != null && data['favorites'] is List) {
            favorites = (data['favorites'] as List)
                .where((item) => item != null)
                .map((item) => item.toString())
                .toList();
          }
        } catch (e) {
          debugPrint('Error processing favorites: $e');
        }

        _userModel = UserModel(
          uid: user.uid,
          name: data['name']?.toString() ?? user.displayName ?? '',
          email: data['email']?.toString() ?? user.email ?? '',
          phone: data['phone']?.toString() ?? '',
          profileImage: data['profileImage']?.toString() ?? '',
          favorites: favorites,
          address: data['address']?.toString(), // Terima nilai null
          latitude: data['latitude'] != null
              ? double.tryParse(data['latitude'].toString())
              : null,
          longitude: data['longitude'] != null
              ? double.tryParse(data['longitude'].toString())
              : null,
        );

        debugPrint(
            'UserModel created with name: ${_userModel?.name}, phone: ${_userModel?.phone}');
      } else {
        // Jika data tidak ada di Firestore, buat dokumen baru
        debugPrint('User document does not exist, creating new one');

        _userModel = UserModel(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          phone: '',
          favorites: [],
          // address sudah null by default
        );

        // Buat dokumen dengan data dasar
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(_userModel!.toJson());
        debugPrint('New user document created');
      }

      // Notify listeners agar UI diupdate
      notifyListeners();
    } catch (e) {
      debugPrint('Error in _fetchUserData: $e');
    }
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('Attempting login for email: $email');

      // BAGIAN 1: PROSES AUTENTIKASI
      try {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (authError) {
        debugPrint('❌ Authentication error: $authError');
        _handleAuthError(authError);
        _isLoading = false;
        notifyListeners();
        return null;
      }

      // BAGIAN 2: AMBIL DATA USER DENGAN SAFE HANDLING
      try {
        // Tunggu sebentar agar token tersimpan dengan baik
        await Future.delayed(const Duration(milliseconds: 800));
        final currentUser = _auth.currentUser;

        if (currentUser == null) {
          _isLoading = false;
          notifyListeners();
          return null;
        }

        // Buat model user dasar yang valid terlepas dari apapun yang terjadi
        _userModel = UserModel(
          uid: currentUser.uid,
          name: currentUser.displayName ?? '',
          email: currentUser.email ?? '',
          phone: '',
          favorites: [],
        );

        // Beri tahu UI bahwa login sudah berhasil dengan data dasar
        notifyListeners();

        // Coba ambil data lengkap - TAPI JANGAN GAGALKAN LOGIN JIKA ERROR
        try {
          final userDoc =
              await _firestore.collection('users').doc(currentUser.uid).get();

          if (userDoc.exists && userDoc.data() != null) {
            final data = userDoc.data()!;

            // Handle favorites dengan aman
            List<String> favorites = [];
            try {
              if (data['favorites'] != null && data['favorites'] is List) {
                favorites = (data['favorites'] as List)
                    .map((e) => e.toString())
                    .toList();
              }
            } catch (favError) {
              debugPrint('Error converting favorites: $favError');
              // Tetap lanjutkan dengan array kosong
            }

            // Update model dengan data lengkap
            _userModel = UserModel(
              uid: currentUser.uid,
              name: data['name']?.toString() ?? currentUser.displayName ?? '',
              email: data['email']?.toString() ?? currentUser.email ?? '',
              phone: data['phone']?.toString() ?? '',
              profileImage: data['profileImage']?.toString() ?? '',
              favorites: favorites,
              address: data['address']?.toString() ?? '',
            );
          }
        } catch (dataError) {
          // KUNCI SOLUSI: Biarkan error ini terjadi, tetap gunakan model dasar
          debugPrint('Error getting detailed user data: $dataError');
          // JANGAN throw error - biarkan login tetap berjalan
        }

        // Jangan lupa update state login dan notify UI
        _isLoading = false;
        notifyListeners();
        return _userModel;
      } catch (e) {
        // Penanganan error yang lebih baik - jika PigeonUserDetails error
        if (e.toString().contains('PigeonUserDetails') ||
            e.toString().contains('List<Object?>')) {
          debugPrint('⚠️ PigeonUserDetails error but login successful');

          // Pastikan user model tetap valid
          if (_userModel == null && _auth.currentUser != null) {
            _userModel = UserModel(
              uid: _auth.currentUser!.uid,
              name: _auth.currentUser!.displayName ?? '',
              email: _auth.currentUser!.email ?? '',
              phone: '',
              favorites: [],
            );
          }

          _isLoading = false;
          notifyListeners();
          return _userModel; // Return model valid meskipun minimal
        }

        // Error umum lainnya
        debugPrint('❌ Error during user data fetch: $e');
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      // Catastrophic error (seharusnya tidak terjadi)
      debugPrint('❌ Catastrophic error during login: $e');
      _isLoading = false;
      notifyListeners();

      // PENTING: Jika ini PigeonUserDetails error, tetap return userModel valid
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('List<Object?>')) {
        if (_auth.currentUser != null) {
          return UserModel(
            uid: _auth.currentUser!.uid,
            name: _auth.currentUser!.displayName ?? '',
            email: _auth.currentUser!.email ?? '',
            phone: '',
            favorites: [],
          );
        }
      }
      return null;
    }
  }

  // Helper method untuk menangani error autentikasi
  void _handleAuthError(dynamic error) {
    String message = 'Authentication failed';

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          message = 'No user found with this email address';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        case 'invalid-credential':
          message = 'Invalid login credentials';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        default:
          message = error.message ?? 'Authentication failed';
      }
    }

    Get.snackbar(
      'Login Failed',
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
    );
  }

  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      User? firebaseUser;

      // BAGIAN 1: BUAT USER DI FIREBASE AUTH
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        firebaseUser = userCredential.user;
        if (firebaseUser != null) {
          // Update display name langsung di Firebase Auth
          await firebaseUser.updateDisplayName(name);

          // Tunggu sebentar untuk memastikan display name terupdate
          await Future.delayed(Duration(milliseconds: 500));
          await firebaseUser.reload();
        }
      } on FirebaseAuthException catch (e) {
        debugPrint(
            'Firebase Auth Error during registration: ${e.code} - ${e.message}');
        _isLoading = false;
        notifyListeners();

        String message;
        switch (e.code) {
          case 'email-already-in-use':
            message = 'Email ini sudah terdaftar';
            break;
          default:
            message = e.message ?? 'Registrasi gagal';
        }

        Get.snackbar(
          'Registration Error',
          message,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );

        return null;
      }

      // BAGIAN 2: BUAT DATA USER DI FIRESTORE
      try {
        // Buat dokumen user dengan data lengkap
        final userData = {
          'uid': firebaseUser!.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
          'favorites': [],
          'address': null,
          'profileImage': '',
        };

        // Simpan ke Firestore
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(userData);

        // Buat model user
        _userModel = UserModel(
          uid: firebaseUser.uid,
          name: name,
          email: email,
          phone: phone,
          favorites: [],
        );
      } catch (e) {
        debugPrint('Error creating user document: $e');
        // Tetap lanjutkan meski error, karena auth sudah berhasil
      }

      // PENTING: Tangani error PigeonUserDetails dengan benar
      try {
        await _fetchUserData();
      } catch (e) {
        debugPrint('Error fetching user data after signup: $e');
        // Jika error PigeonUserDetails, tetap kembalikan user
        if (e.toString().contains('PigeonUserDetails') ||
            e.toString().contains('List<Object?>')) {
          debugPrint('PigeonUserDetails error but continuing registration...');
        }
      }

      _isLoading = false;
      notifyListeners();
      return firebaseUser; // Selalu kembalikan user jika registrasi berhasil
    } catch (e) {
      // Penanganan error lainnya
      debugPrint('Unexpected error during signup: $e');

      // Jika error PigeonUserDetails, tetap kembalikan user yang berhasil dibuat
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('List<Object?>')) {
        _isLoading = false;
        notifyListeners();
        return _auth.currentUser; // Kembalikan user yang berhasil dibuat
      }

      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _userModel = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
      Get.snackbar(
        'Error',
        'Failed to sign out. Please try again.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint('Error resetting password: $e');
      Get.snackbar(
        'Error',
        'Failed to send password reset email. Please check your email address.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? profileImage,
    double? latitude,
    double? longitude,
  }) async {
    if (_userModel == null || _auth.currentUser == null) return false;

    try {
      final updatedUser = UserModel(
        uid: _userModel!.uid,
        name: name ?? _userModel!.name,
        email: _userModel!.email,
        phone: phone ?? _userModel!.phone,
        profileImage: profileImage ?? _userModel!.profileImage,
        favorites: _userModel!.favorites,
        latitude: latitude ?? _userModel!.latitude,
        longitude: longitude ?? _userModel!.longitude,
        address: address, // Bisa null
      );

      final dataToUpdate = {
        'name': updatedUser.name,
        'phone': updatedUser.phone,
        if (address != null) 'address': address,
        if (profileImage != null) 'profileImage': profileImage,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

      await _firestore
          .collection('users')
          .doc(_userModel!.uid)
          .update(dataToUpdate);

      _userModel = updatedUser;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      Get.snackbar(
        'Error',
        'Failed to update profile. Please try again.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> toggleFavorite(String salonId) async {
    try {
      if (_userModel == null) return false;

      final favorites = List<String>.from(_userModel!.favorites);
      if (favorites.contains(salonId)) {
        favorites.remove(salonId);
      } else {
        favorites.add(salonId);
      }

      final updatedUser = UserModel(
        uid: _userModel!.uid,
        email: _userModel!.email,
        name: _userModel!.name,
        phone: _userModel!.phone,
        profileImage: _userModel!.profileImage,
        favorites: favorites,
        latitude: _userModel!.latitude,
        longitude: _userModel!.longitude,
        address: _userModel!.address,
      );

      await _firestore
          .collection('users')
          .doc(_userModel!.uid)
          .update({'favorites': favorites});
      _userModel = updatedUser;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return false;
    }
  }

  Future<void> forceRefreshUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      debugPrint('Forcing refresh of user data');

      // Pastikan ada model dasar
      if (_userModel == null) {
        _userModel = UserModel(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          phone: '',
          favorites: [],
        );
        notifyListeners();
      }

      try {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data()!;

          // Handle favorites dengan aman
          List<String> favorites = [];
          try {
            if (data['favorites'] != null && data['favorites'] is List) {
              favorites =
                  (data['favorites'] as List).map((e) => e.toString()).toList();
            }
          } catch (e) {
            debugPrint('Error converting favorites: $e');
          }

          _userModel = UserModel(
            uid: user.uid,
            name: data['name']?.toString() ?? user.displayName ?? '',
            email: data['email']?.toString() ?? user.email ?? '',
            phone: data['phone']?.toString() ?? '',
            profileImage: data['profileImage']?.toString() ?? '',
            favorites: favorites,
            address: data['address']?.toString() ?? '',
          );
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error refreshing user data: $e');
        // Biarkan model dasar tetap digunakan
      }
    } catch (e) {
      debugPrint('Error in forceRefreshUserData: $e');
    }
  }
}

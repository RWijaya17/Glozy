import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constructor dengan auto-fetch data
  UserProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        getUserData();
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  // Optimized getUserData method dengan caching
  Future<void> getUserData({bool forceRefresh = false}) async {
    // Jika data sudah ada dan tidak dipaksa refresh, gunakan data yang ada
    if (_user != null && !forceRefresh) {
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      _user = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Gunakan cache untuk mempercepat loading
      final userDoc = await _firestore.collection('users').doc(user.uid).get(
          GetOptions(
              source: forceRefresh ? Source.server : Source.serverAndCache));

      if (userDoc.exists) {
        _user = UserModel.fromJson({
          'uid': user.uid,
          ...userDoc.data() ?? {},
        });
      } else {
        // Jika tidak ada data, buat user baru
        final newUser = UserModel(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          phone: '',
          favorites: [],
        );

        // Simpan ke Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(newUser.toJson());
        _user = newUser;
      }
    } catch (e) {
      debugPrint('Error getting user data: $e');
      _error = 'Failed to load user data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile dengan optimasi
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('users').doc(_user!.uid).update(data);

      // Update local model tanpa perlu fetch ulang
      _user = UserModel.fromJson({
        ..._user!.toJson(),
        ...data,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      _isLoading = false;
      _error = 'Failed to update profile';
      notifyListeners();
      return false;
    }
  }

  // Method untuk clear cache jika diperlukan
  void clearCache() {
    _user = null;
    notifyListeners();
  }
}

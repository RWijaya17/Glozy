import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

class FirestoreSeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Random _random = Random();

  // Fungsi untuk membantu membuat ID unik
  String _generateId(String prefix) =>
      '$prefix-${DateTime.now().millisecondsSinceEpoch}-${_random.nextInt(10000)}';

  // Fungsi utama untuk menjalankan semua seed data
  Future<void> seedAllData() async {
    try {
      await seedUsers();
      await seedSalons();
      await seedBookings();

      Get.snackbar(
        'Success',
        'All seed data has been added to Firestore',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to seed data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      debugPrint('Error seeding data: $e');
    }
  }

  // Seed data untuk Users
  Future<void> seedUsers() async {
    // Password standard untuk semua user seed
    const String defaultPassword = "Password123";

    // Daftar contoh user untuk testing
    final users = [
      {
        'uid': _generateId('user'),
        'name': 'John Doe',
        'email': 'john@example.com',
        'password':
            defaultPassword, // Hanya untuk referensi, tidak disimpan di Firestore
        'phone': '08123456789',
        'profileImage': 'https://randomuser.me/api/portraits/men/32.jpg',
        'favorites': [],
        'address': 'Jl. Kebon Jeruk No. 10, Jakarta Barat',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'uid': _generateId('user'),
        'name': 'Jane Smith',
        'email': 'jane@example.com',
        'password':
            defaultPassword, // Hanya untuk referensi, tidak disimpan di Firestore
        'phone': '08234567890',
        'profileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
        'favorites': [],
        'address': 'Jl. Sudirman No. 25, Jakarta Pusat',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    // Tambahkan user dummy ke Firebase Auth dan Firestore
    for (var user in users) {
      try {
        // Buat akun otentikasi
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: user['email'] as String,
          password: user['password'] as String,
        );

        final uid = userCredential.user!.uid;

        // Update user map dengan UID yang benar dari Firebase Auth
        final userData = {...user};
        userData['uid'] = uid;
        userData.remove('password'); // Hapus password dari data yang disimpan

        // Simpan ke Firestore
        await _firestore.collection('users').doc(uid).set(userData);

        debugPrint(
            '✅ User created with email: ${user['email']} and password: ${user['password']}');
      } catch (e) {
        debugPrint('❌ Error creating user ${user['email']}: $e');
      }
    }

    debugPrint('✅ Users seed data added successfully');
  }

  // Seed data untuk Salons
  Future<void> seedSalons() async {
    final salons = [
      {
        'id': 'salon-1',
        'name': 'Glozy Beauty Salon',
        'imageUrl':
            'https://images.unsplash.com/photo-1560066984-138dadb4c035?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
        'address': 'Jl. Kemang Raya No. 10, Jakarta Selatan',
        'rating': 4.5,
        'reviewCount': 120,
        'description':
            'Glozy Beauty Salon adalah tempat terbaik untuk semua kebutuhan kecantikan dan perawatan Anda. Terletak di pusat Jakarta dengan suasana mewah dan pelayanan premium.',
        'latitude': -6.2088,
        'longitude': 106.8456,
        'phoneNumber': '021-12345678',
        'openHours': '08:00 - 20:00',
        'services': [
          {
            'id': 'service-1-1',
            'name': 'Haircut & Blow Dry',
            'price': 150000,
            'duration': 60,
            'description': 'Potongan rambut profesional dengan blow styling.'
          },
          {
            'id': 'service-1-2',
            'name': 'Hair Coloring',
            'price': 350000,
            'duration': 120,
            'description': 'Pewarnaan rambut dengan produk premium.'
          },
          {
            'id': 'service-1-3',
            'name': 'Facial Treatment',
            'price': 250000,
            'duration': 90,
            'description': 'Perawatan wajah dengan produk organik.'
          }
        ],
        'homeService': false,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'salon-2',
        'name': 'Elysium Spa & Salon',
        'imageUrl':
            'https://images.unsplash.com/photo-1600948836101-f9ffda59d250?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
        'address': 'Jl. Sudirman No. 45, Jakarta Pusat',
        'rating': 4.8,
        'reviewCount': 250,
        'description':
            'Elysium Spa & Salon menawarkan pengalaman spa mewah dan layanan salon premium. Rileksasi dan perawatan dalam satu tempat.',
        'latitude': -6.2000,
        'longitude': 106.8200,
        'phoneNumber': '021-87654321',
        'openHours': '10:00 - 22:00',
        'services': [
          {
            'id': 'service-2-1',
            'name': 'Full Body Massage',
            'price': 400000,
            'duration': 120,
            'description': 'Pijat seluruh tubuh untuk relaksasi maksimal.'
          },
          {
            'id': 'service-2-2',
            'name': 'Facial Rejuvenation',
            'price': 350000,
            'duration': 90,
            'description':
                'Perawatan wajah untuk kulit lebih cerah dan awet muda.'
          },
          {
            'id': 'service-2-3',
            'name': 'Hair Spa',
            'price': 250000,
            'duration': 60,
            'description': 'Perawatan rambut mendalam untuk rambut lebih sehat.'
          }
        ],
        'homeService': true,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'salon-3',
        'name': 'Zenith Barbershop',
        'imageUrl':
            'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
        'address': 'Jl. Gatot Subroto No. 22, Jakarta Selatan',
        'rating': 4.7,
        'reviewCount': 180,
        'description':
            'Barbershop premium khusus untuk pria. Dapatkan gaya rambut trendi dari tangan barber profesional kami.',
        'latitude': -6.2300,
        'longitude': 106.8100,
        'phoneNumber': '021-55667788',
        'openHours': '09:00 - 21:00',
        'services': [
          {
            'id': 'service-3-1',
            'name': 'Haircut & Styling',
            'price': 100000,
            'duration': 45,
            'description': 'Potongan rambut pria dengan styling.'
          },
          {
            'id': 'service-3-2',
            'name': 'Shave & Beard Trim',
            'price': 80000,
            'duration': 30,
            'description':
                'Cukur dan rapikan jenggot dengan teknik tradisional.'
          },
          {
            'id': 'service-3-3',
            'name': 'Hair Color',
            'price': 200000,
            'duration': 90,
            'description': 'Warnai rambut dengan warna trendi.'
          }
        ],
        'homeService': true,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      }
    ];

    // Tulis data ke Firestore secara individual, dengan error handling per salon
    for (var salon in salons) {
      try {
        // Gunakan ID yang sudah ditentukan atau generate baru kalau tidak ada
        final String salonId = (salon['id'] as String?) ?? _generateId('salon');
        await _firestore.collection('salons').doc(salonId).set(salon);
        debugPrint('✅ Salon created: ${salon['name']}');
      } catch (e) {
        debugPrint('❌ Error creating salon ${salon['name']}: $e');
        // Lanjutkan ke salon berikutnya meskipun ada error
        continue;
      }
    }

    debugPrint('✅ ${salons.length} salons seeded successfully');
  }

  // Seed data untuk Bookings
  Future<void> seedBookings() async {
    // Ambil data user dan salon yang sudah ada
    final usersSnapshot = await _firestore.collection('users').limit(2).get();
    final salonsSnapshot = await _firestore.collection('salons').limit(2).get();

    if (usersSnapshot.docs.isEmpty || salonsSnapshot.docs.isEmpty) {
      debugPrint('⚠️ No users or salons found. Cannot create bookings.');
      return;
    }

    final users = usersSnapshot.docs;
    final salons = salonsSnapshot.docs;

    // Status booking yang mungkin
    final statuses = ['pending', 'confirmed', 'completed', 'cancelled'];

    // Buat beberapa booking
    final bookings = [
      {
        'id': _generateId('booking'),
        'userId': users[0].id,
        'userName': users[0].data()['name'],
        'userPhone': users[0].data()['phone'],
        'salonId': salons[0].id,
        'salonName': salons[0].data()['name'],
        'serviceId': (salons[0].data()['services'] as List)[0]['id'],
        'serviceName': (salons[0].data()['services'] as List)[0]['name'],
        'servicePrice': (salons[0].data()['services'] as List)[0]['price'],
        'serviceDuration': (salons[0].data()['services'] as List)[0]
            ['duration'],
        'bookingDate':
            Timestamp.fromDate(DateTime.now().add(Duration(days: 1))),
        'bookingTime': '14:00',
        'status': statuses[1], // confirmed
        'isHomeService': false,
        'notes': 'Pertama kali mencoba salon ini, mohon pelayanan terbaik',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': _generateId('booking'),
        'userId': users[1].id,
        'userName': users[1].data()['name'],
        'userPhone': users[1].data()['phone'],
        'salonId': salons[0].id,
        'salonName': salons[0].data()['name'],
        'serviceId': (salons[0].data()['services'] as List)[1]['id'],
        'serviceName': (salons[0].data()['services'] as List)[1]['name'],
        'servicePrice': (salons[0].data()['services'] as List)[1]['price'],
        'serviceDuration': (salons[0].data()['services'] as List)[1]
            ['duration'],
        'bookingDate':
            Timestamp.fromDate(DateTime.now().add(Duration(days: 2))),
        'bookingTime': '10:30',
        'status': statuses[0], // pending
        'isHomeService': true,
        'address': users[1].data()['address'],
        'notes': 'Mohon tepat waktu ya, terima kasih',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': _generateId('booking'),
        'userId': users[0].id,
        'userName': users[0].data()['name'],
        'userPhone': users[0].data()['phone'],
        'salonId': salons[1].id,
        'salonName': salons[1].data()['name'],
        'serviceId': (salons[1].data()['services'] as List)[0]['id'],
        'serviceName': (salons[1].data()['services'] as List)[0]['name'],
        'servicePrice': (salons[1].data()['services'] as List)[0]['price'],
        'serviceDuration': (salons[1].data()['services'] as List)[0]
            ['duration'],
        'bookingDate':
            Timestamp.fromDate(DateTime.now().subtract(Duration(days: 7))),
        'bookingTime': '16:00',
        'status': statuses[2], // completed
        'isHomeService': false,
        'rating': 5,
        'review': 'Pelayanan sangat memuaskan! Saya akan datang lagi.',
        'createdAt': FieldValue.serverTimestamp(),
      }
    ];

    for (var booking in bookings) {
      await _firestore
          .collection('bookings')
          .doc(booking['id'] as String)
          .set(booking);
    }

    debugPrint('✅ Bookings seed data added successfully');
  }
}

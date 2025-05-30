import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String salonId;
  final String salonName;
  final String salonAddress;
  final String salonImage;
  final List<ServiceModel> services;
  final DateTime bookingDate;
  final String timeSlot;
  final bool isHomeService;
  final String? customerAddress;
  final double? customerLatitude;
  final double? customerLongitude;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;
  final String? notes;
  final String? barberId;
  final String? barberName;

  BookingModel({
    required this.id,
    required this.userId,
    required this.salonId,
    required this.salonName,
    required this.salonAddress,
    required this.salonImage,
    required this.services,
    required this.bookingDate,
    required this.timeSlot,
    required this.isHomeService,
    this.customerAddress,
    this.customerLatitude,
    this.customerLongitude,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.notes,
    this.barberId,
    this.barberName,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle services conversion
      List<ServiceModel> services = [];
      if (json['services'] != null && json['services'] is List) {
        services = (json['services'] as List)
            .map((service) => ServiceModel.fromJson(service))
            .toList();
      }

      // Handle date parsing
      DateTime bookingDate;
      try {
        bookingDate = DateTime.parse(json['bookingDate']);
      } catch (e) {
        debugPrint('Error parsing bookingDate: $e');
        bookingDate = DateTime.now(); // Fallback
      }

      // Improved status handling
      BookingStatus status;
      final statusStr = json['status'] as String? ?? 'pending';
      switch (statusStr) {
        case 'pending':
          status = BookingStatus.pending;
          break;
        case 'confirmed':
          status = BookingStatus.confirmed;
          break;
        case 'inProgress':
          status = BookingStatus.inProgress;
          break;
        case 'completed':
          status = BookingStatus.completed;
          break;
        case 'cancelled':
          status = BookingStatus.cancelled;
          break;
        case 'onTheWay':
          status = BookingStatus.onTheWay;
          break;
        default:
          debugPrint(
              'Unknown booking status: $statusStr, defaulting to pending');
          status = BookingStatus.pending;
      }

      // Handle createdAt parsing
      DateTime createdAt;
      try {
        if (json['createdAt'] is Timestamp) {
          createdAt = (json['createdAt'] as Timestamp).toDate();
        } else if (json['createdAt'] is String) {
          createdAt = DateTime.parse(json['createdAt']);
        } else {
          createdAt = DateTime.now();
        }
      } catch (e) {
        debugPrint('Error parsing createdAt: $e');
        createdAt = DateTime.now(); // Fallback
      }

      return BookingModel(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        salonId: json['salonId'] ?? '',
        salonName: json['salonName'] ?? '',
        salonAddress: json['salonAddress'] ?? '',
        salonImage: json['salonImage'] ?? '',
        services: services,
        bookingDate: bookingDate,
        timeSlot: json['timeSlot'] ?? '',
        isHomeService: json['isHomeService'] ?? false,
        customerAddress: json['customerAddress'],
        customerLatitude: json['customerLatitude'] != null
            ? double.tryParse(json['customerLatitude'].toString())
            : null,
        customerLongitude: json['customerLongitude'] != null
            ? double.tryParse(json['customerLongitude'].toString())
            : null,
        totalPrice: json['totalPrice'] != null
            ? double.tryParse(json['totalPrice'].toString()) ?? 0
            : 0,
        status: status,
        createdAt: createdAt,
        notes: json['notes'],
        barberId: json['barberId'],
        barberName: json['barberName'],
      );
    } catch (e) {
      debugPrint('Error creating BookingModel from JSON: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'userId': userId,
      'salonId': salonId,
      'salonName': salonName,
      'salonAddress': salonAddress,
      'salonImage': salonImage,
      'services': services.map((s) => s.toJson()).toList(),
      'bookingDate': bookingDate.toIso8601String(),
      'timeSlot': timeSlot,
      'isHomeService': isHomeService,
      'totalPrice': totalPrice,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
    };

    // Hanya tambahkan field nullable jika nilainya tidak null
    if (customerAddress != null) data['customerAddress'] = customerAddress;
    if (customerLatitude != null) data['customerLatitude'] = customerLatitude;
    if (customerLongitude != null)
      data['customerLongitude'] = customerLongitude;
    if (notes != null) data['notes'] = notes;
    if (barberId != null) data['barberId'] = barberId;
    if (barberName != null) data['barberName'] = barberName;

    return data;
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? salonId,
    String? salonName,
    String? salonAddress,
    String? salonImage,
    List<ServiceModel>? services,
    DateTime? bookingDate,
    String? timeSlot,
    bool? isHomeService,
    String? customerAddress,
    double? totalPrice,
    BookingStatus? status,
    DateTime? createdAt,
    String? notes,
    String? barberName,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      salonId: salonId ?? this.salonId,
      salonName: salonName ?? this.salonName,
      salonAddress: salonAddress ?? this.salonAddress,
      salonImage: salonImage ?? this.salonImage,
      services: services ?? this.services,
      bookingDate: bookingDate ?? this.bookingDate,
      timeSlot: timeSlot ?? this.timeSlot,
      isHomeService: isHomeService ?? this.isHomeService,
      customerAddress: customerAddress ?? this.customerAddress,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      barberName: barberName ?? this.barberName,
    );
  }

  static BookingStatus _stringToBookingStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'inprogress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'ontheway':
        return BookingStatus.onTheWay;
      default:
        return BookingStatus.pending;
    }
  }
}

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  onTheWay,
  completed,
  cancelled,
}

class ServiceModel {
  final String id;
  final String name;
  final double price;
  final int duration;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] != null
          ? double.tryParse(json['price'].toString()) ?? 0
          : 0,
      duration: json['duration'] != null
          ? int.tryParse(json['duration'].toString()) ?? 0
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration': duration,
    };
  }
}

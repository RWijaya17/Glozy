class AppConstants {
  // App Info
  static const String appName = 'Glozy';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Salon & Barber Service';

  // Contact Info
  static const String supportEmail = 'support@glozy.com';
  static const String supportPhone = '+62 812-3456-7890';
  static const String whatsappNumber = '6281234567890';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String salonsCollection = 'salons';
  static const String bookingsCollection = 'bookings';
  static const String reviewsCollection = 'reviews';

  // Booking Constants
  static const int maxAdvanceBookingDays = 30;
  static const int cancelBookingHours = 2;
  static const double baseHomeServiceFee = 10000;

  // Map Constants
  static const double defaultLatitude = -6.2088;
  static const double defaultLongitude = 106.8456; // Jakarta coordinates
  static const double defaultMapZoom = 14.0;

  // Pagination
  static const int itemsPerPage = 20;
  static const int salonsPerPage = 10;

  // Image Constants
  static const int maxImageWidth = 800;
  static const int maxImageHeight = 800;
  static const int imageQuality = 85;

  // Time Constants
  static const List<String> timeSlots = [
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
  ];

  // Business Hours
  static const String defaultOpeningTime = '09:00';
  static const String defaultClosingTime = '18:00';

  // URLs
  static const String termsUrl = 'https://glozy.com/terms';
  static const String privacyUrl = 'https://glozy.com/privacy';
  static const String aboutUrl = 'https://glozy.com/about';

  // Regex Patterns
  static final RegExp emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  static final RegExp phoneRegex = RegExp(
    r'^[\+]?[(]?[0-9]{3,4}[)]?[-\s\.]?[0-9]{3,4}[-\s\.]?[0-9]{4,6}$',
  );

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError =
      'Network error. Please check your connection.';
  static const String authError = 'Authentication failed. Please login again.';
  static const String locationError =
      'Unable to get your location. Please enable location services.';

  // Success Messages
  static const String bookingSuccess = 'Booking created successfully!';
  static const String updateSuccess = 'Updated successfully!';
  static const String deleteSuccess = 'Deleted successfully!';
  static const String loginSuccess = 'Login successful!';
  static const String logoutSuccess = 'Logout successful!';
}

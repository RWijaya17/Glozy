class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String salonId;
  final String bookingId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String> images;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImage = '',
    required this.salonId,
    required this.bookingId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.images = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'salonId': salonId,
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'images': images,
    };
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userImage: json['userImage'] ?? '',
      salonId: json['salonId'] ?? '',
      bookingId: json['bookingId'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      images: List<String>.from(json['images'] ?? []),
    );
  }
}

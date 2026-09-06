import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج "طلب خدمة" - كيتخزن فـ Firestore داخل collection اسمها "requests"
/// هاد النموذج كيطابق البطاقات فشاشة "الطلبات" (العنوان، الصنف، صاحب الطلب، الوقت)
/// وكيطابق أيضا الحقول فشاشة "نشر خدمة".
class ServiceRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String title;
  final String city;
  final String? region;
  final String category; // نوع العمل (نظافة، بيع، صيانة، تصميم، مطاعم...)
  final String description;
  final String? extraDetails;
  final DateTime createdAt;

  ServiceRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.title,
    required this.city,
    this.region,
    required this.category,
    required this.description,
    this.extraDetails,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ServiceRequestModel.fromMap(String id, Map<String, dynamic> map) {
    return ServiceRequestModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      title: map['title'] ?? '',
      city: map['city'] ?? '',
      region: map['region'],
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      extraDetails: map['extraDetails'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'title': title,
      'city': city,
      'region': region,
      'category': category,
      'description': description,
      'extraDetails': extraDetails,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

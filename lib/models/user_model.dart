import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج بيانات المستخدم - كيتخزن فـ Firestore داخل collection اسمها "users"
/// كل حقل هنا كيطابق حقل فشاشة "حسابي".
class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String? photoUrl;
  final DateTime? birthDate;
  final String? gender;
  final String? city;
  final String? address;
  final String? bio;
  final List<String> skills;
  final String? language;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phone = '',
    this.photoUrl,
    this.birthDate,
    this.gender,
    this.city,
    this.address,
    this.bio,
    this.skills = const [],
    this.language,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// كيبني UserModel فارغ (بلا أي بيانات وهمية) مباشرة بعد التسجيل
  factory UserModel.empty({
    required String uid,
    required String email,
  }) {
    return UserModel(
      uid: uid,
      fullName: '',
      email: email,
      phone: '',
      skills: const [],
    );
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'],
      birthDate: map['birthDate'] != null
          ? (map['birthDate'] as Timestamp).toDate()
          : null,
      gender: map['gender'],
      city: map['city'],
      address: map['address'],
      bio: map['bio'],
      skills: List<String>.from(map['skills'] ?? []),
      language: map['language'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'gender': gender,
      'city': city,
      'address': address,
      'bio': bio,
      'skills': skills,
      'language': language,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? fullName,
    String? phone,
    String? photoUrl,
    DateTime? birthDate,
    String? gender,
    String? city,
    String? address,
    String? bio,
    List<String>? skills,
    String? language,
  }) {
    return UserModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      city: city ?? this.city,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      language: language ?? this.language,
      createdAt: createdAt,
    );
  }
}

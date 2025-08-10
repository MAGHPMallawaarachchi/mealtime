import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? householdId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.householdId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      householdId: data['householdId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'householdId': householdId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? householdId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserModel &&
      other.uid == uid &&
      other.email == email &&
      other.displayName == displayName &&
      other.photoURL == photoURL &&
      other.householdId == householdId &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      photoURL.hashCode ^
      householdId.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, photoURL: $photoURL, householdId: $householdId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
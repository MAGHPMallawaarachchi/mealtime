import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum DietaryType { vegetarian, vegan, pescatarian, nonVegetarian }
enum Allergen { dairy, eggs, fishSeafood, nuts, gluten }
enum SpicePreference { mild, medium, spicy }
enum SriLankanRegion { western, southern, central, northern, eastern, uva, northWestern, sabaragamuwa, northCentral }
enum SpecialDiet { diabeticFriendly, lowSodium, highProtein }

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? customProfilePicture; // base64 encoded custom profile picture
  final String? householdId;
  final DateTime createdAt;
  final DateTime updatedAt;
  // New fields for recommendations
  final DietaryType? dietaryType;
  final List<Allergen> allergens;
  final SpicePreference? spicePreference;
  final List<SriLankanRegion> preferredRegions;
  final List<SpecialDiet> specialDiets;
  final bool enableRecommendations;
  final bool prioritizePantryItems;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.customProfilePicture,
    this.householdId,
    required this.createdAt,
    required this.updatedAt,
    this.dietaryType,
    this.allergens = const [],
    this.spicePreference,
    this.preferredRegions = const [],
    this.specialDiets = const [],
    this.enableRecommendations = true,
    this.prioritizePantryItems = true,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      customProfilePicture: data['customProfilePicture'],
      householdId: data['householdId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dietaryType: _parseDietaryType(data['dietaryType']),
      allergens: _parseAllergens(data['allergens']),
      spicePreference: _parseSpicePreference(data['spicePreference']),
      preferredRegions: _parseRegions(data['preferredRegions']),
      specialDiets: _parseSpecialDiets(data['specialDiets']),
      enableRecommendations: data['enableRecommendations'] ?? true,
      prioritizePantryItems: data['prioritizePantryItems'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'customProfilePicture': customProfilePicture,
      'householdId': householdId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'dietaryType': dietaryType?.name,
      'allergens': allergens.map((a) => a.name).toList(),
      'spicePreference': spicePreference?.name,
      'preferredRegions': preferredRegions.map((r) => r.name).toList(),
      'specialDiets': specialDiets.map((d) => d.name).toList(),
      'enableRecommendations': enableRecommendations,
      'prioritizePantryItems': prioritizePantryItems,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? customProfilePicture,
    String? householdId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DietaryType? dietaryType,
    List<Allergen>? allergens,
    SpicePreference? spicePreference,
    List<SriLankanRegion>? preferredRegions,
    List<SpecialDiet>? specialDiets,
    bool? enableRecommendations,
    bool? prioritizePantryItems,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      customProfilePicture: customProfilePicture ?? this.customProfilePicture,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dietaryType: dietaryType ?? this.dietaryType,
      allergens: allergens ?? this.allergens,
      spicePreference: spicePreference ?? this.spicePreference,
      preferredRegions: preferredRegions ?? this.preferredRegions,
      specialDiets: specialDiets ?? this.specialDiets,
      enableRecommendations: enableRecommendations ?? this.enableRecommendations,
      prioritizePantryItems: prioritizePantryItems ?? this.prioritizePantryItems,
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
      other.customProfilePicture == customProfilePicture &&
      other.householdId == householdId &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.dietaryType == dietaryType &&
      listEquals(other.allergens, allergens) &&
      other.spicePreference == spicePreference &&
      listEquals(other.preferredRegions, preferredRegions) &&
      listEquals(other.specialDiets, specialDiets) &&
      other.enableRecommendations == enableRecommendations &&
      other.prioritizePantryItems == prioritizePantryItems;
  }

  @override
  int get hashCode {
    return Object.hash(
      uid,
      email,
      displayName,
      photoURL,
      customProfilePicture,
      householdId,
      createdAt,
      updatedAt,
      dietaryType,
      Object.hashAll(allergens),
      spicePreference,
      Object.hashAll(preferredRegions),
      Object.hashAll(specialDiets),
      enableRecommendations,
      prioritizePantryItems,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, photoURL: $photoURL, customProfilePicture: ${customProfilePicture != null ? '[base64 data]' : 'null'}, householdId: $householdId, createdAt: $createdAt, updatedAt: $updatedAt, dietaryType: $dietaryType, allergens: $allergens, spicePreference: $spicePreference, preferredRegions: $preferredRegions, specialDiets: $specialDiets)';
  }

  static DietaryType? _parseDietaryType(dynamic value) {
    if (value == null) return null;
    try {
      return DietaryType.values.firstWhere((e) => e.name == value.toString());
    } catch (e) {
      return null;
    }
  }

  static List<Allergen> _parseAllergens(dynamic value) {
    if (value == null) return [];
    try {
      return (value as List).map((e) => 
        Allergen.values.firstWhere((allergen) => allergen.name == e.toString())
      ).toList();
    } catch (e) {
      return [];
    }
  }

  static SpicePreference? _parseSpicePreference(dynamic value) {
    if (value == null) return null;
    try {
      return SpicePreference.values.firstWhere((e) => e.name == value.toString());
    } catch (e) {
      return null;
    }
  }

  static List<SriLankanRegion> _parseRegions(dynamic value) {
    if (value == null) return [];
    try {
      return (value as List).map((e) => 
        SriLankanRegion.values.firstWhere((region) => region.name == e.toString())
      ).toList();
    } catch (e) {
      return [];
    }
  }

  static List<SpecialDiet> _parseSpecialDiets(dynamic value) {
    if (value == null) return [];
    try {
      return (value as List).map((e) => 
        SpecialDiet.values.firstWhere((diet) => diet.name == e.toString())
      ).toList();
    } catch (e) {
      return [];
    }
  }
}
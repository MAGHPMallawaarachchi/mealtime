import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserPreferencesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> updateDietaryPreference(DietaryType? dietaryType) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'dietaryType': dietaryType?.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update dietary preference: ${e.toString()}');
    }
  }

  Future<void> updatePantryPrioritization(bool prioritizePantryItems) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'prioritizePantryItems': prioritizePantryItems,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update pantry prioritization: ${e.toString()}');
    }
  }

  Future<void> updateUserPreferences({
    DietaryType? dietaryType,
    bool? prioritizePantryItems,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      final Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (dietaryType != null) {
        updateData['dietaryType'] = dietaryType.name;
      }

      if (prioritizePantryItems != null) {
        updateData['prioritizePantryItems'] = prioritizePantryItems;
      }

      await _firestore.collection('users').doc(user.uid).update(updateData);
    } catch (e) {
      throw Exception('Failed to update user preferences: ${e.toString()}');
    }
  }

}
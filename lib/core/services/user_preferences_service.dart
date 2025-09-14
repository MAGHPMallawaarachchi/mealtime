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
      await _ensureUserDocumentExists(user);
      await _firestore.collection('users').doc(user.uid).set({
        'dietaryType': dietaryType?.name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
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
      await _ensureUserDocumentExists(user);
      await _firestore.collection('users').doc(user.uid).set({
        'prioritizePantryItems': prioritizePantryItems,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update pantry prioritization: ${e.toString()}');
    }
  }

  Future<void> updateHouseholdSize(int householdSize) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      await _ensureUserDocumentExists(user);
      await _firestore.collection('users').doc(user.uid).set({
        'household': householdSize,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update household size: ${e.toString()}');
    }
  }

  Future<void> updateUserPreferences({
    DietaryType? dietaryType,
    bool? prioritizePantryItems,
    int? householdSize,
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

      if (householdSize != null) {
        updateData['household'] = householdSize;
      }

      // First ensure user document exists
      await _ensureUserDocumentExists(user);

      // Then update with merge to avoid overwriting existing data
      await _firestore.collection('users').doc(user.uid).set(updateData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update user preferences: ${e.toString()}');
    }
  }

  Future<void> _ensureUserDocumentExists(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'household': 4, // default household size
        'enableRecommendations': true,
        'prioritizePantryItems': true,
      });
    }
  }

}
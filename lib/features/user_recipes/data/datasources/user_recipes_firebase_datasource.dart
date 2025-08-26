import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../domain/models/user_recipe.dart';

class UserRecipesFirebaseDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  UserRecipesFirebaseDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> _getUserRecipesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('user_recipes');
  }

  Future<List<UserRecipe>> getUserRecipes(String userId) async {
    try {
      debugPrint('UserRecipesFirebaseDataSource: Getting user recipes for $userId');
      
      final querySnapshot = await _getUserRecipesCollection(userId)
          .orderBy('updatedAt', descending: true)
          .get();
      
      final recipes = querySnapshot.docs
          .map((doc) => UserRecipe.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      
      debugPrint('UserRecipesFirebaseDataSource: Found ${recipes.length} user recipes');
      return recipes;
    } catch (e) {
      debugPrint('UserRecipesFirebaseDataSource: Error getting user recipes: $e');
      throw Exception('Failed to load user recipes: $e');
    }
  }

  Stream<List<UserRecipe>> getUserRecipesStream(String userId) {
    try {
      return _getUserRecipesCollection(userId)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => UserRecipe.fromJson({...doc.data(), 'id': doc.id}))
            .toList();
      });
    } catch (e) {
      debugPrint('UserRecipesFirebaseDataSource: Error getting user recipes stream: $e');
      throw Exception('Failed to stream user recipes: $e');
    }
  }

  Future<UserRecipe?> getUserRecipe(String userId, String recipeId) async {
    try {
      debugPrint('UserRecipesFirebaseDataSource: Getting user recipe $recipeId for $userId');
      
      final docSnapshot = await _getUserRecipesCollection(userId).doc(recipeId).get();
      
      if (!docSnapshot.exists) {
        debugPrint('UserRecipesFirebaseDataSource: Recipe $recipeId not found');
        return null;
      }
      
      final data = docSnapshot.data()!;
      return UserRecipe.fromJson({...data, 'id': docSnapshot.id});
    } catch (e) {
      debugPrint('UserRecipesFirebaseDataSource: Error getting user recipe: $e');
      throw Exception('Failed to load user recipe: $e');
    }
  }

  Future<String> createUserRecipe(UserRecipe recipe) async {
    try {
      debugPrint('UserRecipesFirebaseDataSource: Creating user recipe for ${recipe.userId}');
      
      final docRef = await _getUserRecipesCollection(recipe.userId).add(recipe.toJson());
      
      debugPrint('UserRecipesFirebaseDataSource: Created user recipe with ID ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('UserRecipesFirebaseDataSource: Error creating user recipe: $e');
      throw Exception('Failed to create user recipe: $e');
    }
  }

  Future<void> updateUserRecipe(UserRecipe recipe) async {
    try {
      debugPrint('UserRecipesFirebaseDataSource: Updating user recipe ${recipe.id} for ${recipe.userId}');
      
      await _getUserRecipesCollection(recipe.userId).doc(recipe.id).update(recipe.toJson());
      
      debugPrint('UserRecipesFirebaseDataSource: Updated user recipe ${recipe.id}');
    } catch (e) {
      debugPrint('UserRecipesFirebaseDataSource: Error updating user recipe: $e');
      throw Exception('Failed to update user recipe: $e');
    }
  }

  Future<void> deleteUserRecipe(String userId, String recipeId) async {
    try {
      debugPrint('UserRecipesFirebaseDataSource: Deleting user recipe $recipeId for $userId');
      
      await _getUserRecipesCollection(userId).doc(recipeId).delete();
      
      debugPrint('UserRecipesFirebaseDataSource: Deleted user recipe $recipeId');
    } catch (e) {
      debugPrint('UserRecipesFirebaseDataSource: Error deleting user recipe: $e');
      throw Exception('Failed to delete user recipe: $e');
    }
  }

  Future<List<UserRecipe>> searchUserRecipes(String userId, String query) async {
    try {
      debugPrint('UserRecipesFirebaseDataSource: Searching user recipes for "$query" (user: $userId)');
      
      final querySnapshot = await _getUserRecipesCollection(userId)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .orderBy('title')
          .get();
      
      final recipes = querySnapshot.docs
          .map((doc) => UserRecipe.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      
      debugPrint('UserRecipesFirebaseDataSource: Found ${recipes.length} matching recipes');
      return recipes;
    } catch (e) {
      debugPrint('UserRecipesFirebaseDataSource: Error searching user recipes: $e');
      throw Exception('Failed to search user recipes: $e');
    }
  }

  Future<String?> uploadRecipeImage(String userId, String recipeId, File imageFile) async {
    try {
      debugPrint('UserRecipesFirebaseDataSource: Uploading image for recipe $recipeId');
      
      final ref = _storage.ref().child('user_recipes/$userId/$recipeId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('UserRecipesFirebaseDataSource: Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('UserRecipesFirebaseDataSource: Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteRecipeImage(String imageUrl) async {
    try {
      debugPrint('UserRecipesFirebaseDataSource: Deleting image: $imageUrl');
      
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      
      debugPrint('UserRecipesFirebaseDataSource: Image deleted successfully');
    } catch (e) {
      debugPrint('UserRecipesFirebaseDataSource: Error deleting image: $e');
    }
  }
}
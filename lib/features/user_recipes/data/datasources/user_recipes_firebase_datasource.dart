import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;
import '../../domain/models/user_recipe.dart';

class UserRecipesFirebaseDataSource {
  final FirebaseFirestore _firestore;

  UserRecipesFirebaseDataSource({
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getUserRecipesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('user_recipes');
  }

  Future<List<UserRecipe>> getUserRecipes(String userId) async {
    try {
      
      final collection = _getUserRecipesCollection(userId);
      
      // Try simple get first, then try with orderBy if that works
      QuerySnapshot<Map<String, dynamic>> querySnapshot;
      
      try {
        querySnapshot = await collection.get();
        
        // If simple query works and we have documents, try ordering
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot = await collection
              .orderBy('updatedAt', descending: true)
              .get();
        }
      } catch (orderError) {
        querySnapshot = await collection.get();
      }
      
      final recipes = querySnapshot.docs
          .map((doc) => UserRecipe.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      
      return recipes;
    } catch (e) {
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
      throw Exception('Failed to stream user recipes: $e');
    }
  }

  Future<UserRecipe?> getUserRecipe(String userId, String recipeId) async {
    try {
      
      final docSnapshot = await _getUserRecipesCollection(userId).doc(recipeId).get();
      
      if (!docSnapshot.exists) {
        return null;
      }
      
      final data = docSnapshot.data()!;
      return UserRecipe.fromJson({...data, 'id': docSnapshot.id});
    } catch (e) {
      throw Exception('Failed to load user recipe: $e');
    }
  }

  Future<String> createUserRecipe(UserRecipe recipe) async {
    try {
      
      final docRef = await _getUserRecipesCollection(recipe.userId).add(recipe.toJson());
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create user recipe: $e');
    }
  }

  Future<void> updateUserRecipe(UserRecipe recipe) async {
    try {
      
      await _getUserRecipesCollection(recipe.userId).doc(recipe.id).update(recipe.toJson());
      
    } catch (e) {
      throw Exception('Failed to update user recipe: $e');
    }
  }

  Future<void> deleteUserRecipe(String userId, String recipeId) async {
    try {
      
      await _getUserRecipesCollection(userId).doc(recipeId).delete();
      
    } catch (e) {
      throw Exception('Failed to delete user recipe: $e');
    }
  }

  Future<List<UserRecipe>> searchUserRecipes(String userId, String query) async {
    try {
      
      final querySnapshot = await _getUserRecipesCollection(userId)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .orderBy('title')
          .get();
      
      final recipes = querySnapshot.docs
          .map((doc) => UserRecipe.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      
      return recipes;
    } catch (e) {
      throw Exception('Failed to search user recipes: $e');
    }
  }

  Future<String?> uploadRecipeImage(String userId, String recipeId, File imageFile) async {
    try {
      // Process image to base64
      final base64Image = await _processRecipeImageToBase64(imageFile);
      
      // Create data URL
      final dataURL = 'data:image/jpeg;base64,$base64Image';
      
      return dataURL;
    } catch (e) {
      throw Exception('Failed to process image: $e');
    }
  }

  Future<String> _processRecipeImageToBase64(File imageFile) async {
    try {
      // Read and decode image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Invalid image file');
      }

      // Resize to 512x512 and compress (larger for recipe images)
      final resized = img.copyResize(image, width: 512, height: 512);
      final processedBytes = img.encodeJpg(resized, quality: 85);
      
      // Convert to base64
      final base64Image = base64Encode(processedBytes);
      
      return base64Image;
    } catch (e) {
      throw Exception('Failed to process image: ${e.toString()}');
    }
  }

  Future<void> deleteRecipeImage(String imageUrl) async {
    // With base64 storage, no separate cleanup needed
    // Image data is part of the recipe document
    return;
  }
}
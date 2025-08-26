import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      
      final ref = _storage.ref().child('user_recipes/$userId/$recipeId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteRecipeImage(String imageUrl) async {
    try {
      
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      
    } catch (e) {
    }
  }
}
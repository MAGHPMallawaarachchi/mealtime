import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/recipe.dart';

class RecipesLocalDataSource {
  static const String _cacheKey = 'cached_recipes';
  static const String _cacheTimeKey = 'recipes_cache_time';
  static const String _cacheFileKey = 'recipes_cache.json';
  static const int _cacheValidityMinutes = 15;

  Future<List<Recipe>> getRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Try to get from shared preferences first (smaller data)
      final cachedData = prefs.getString(_cacheKey);
      if (cachedData != null) {
        final List<dynamic> jsonList = json.decode(cachedData);
        return jsonList.map((jsonItem) => Recipe.fromJson(jsonItem)).toList();
      }

      // Fallback to file storage for larger datasets
      final cacheFile = await _getCacheFile();
      if (await cacheFile.exists()) {
        final fileContents = await cacheFile.readAsString();
        final List<dynamic> jsonList = json.decode(fileContents);
        return jsonList.map((jsonItem) => Recipe.fromJson(jsonItem)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> cacheRecipes(List<Recipe> recipes) async {
    try {
      final jsonString = json.encode(recipes.map((recipe) => recipe.toJson()).toList());
      final prefs = await SharedPreferences.getInstance();
      
      // Store timestamp
      await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);

      // Try to store in shared preferences first
      try {
        await prefs.setString(_cacheKey, jsonString);
      } catch (e) {
        // If shared preferences fails (data too large), use file storage
        final cacheFile = await _getCacheFile();
        await cacheFile.writeAsString(jsonString);
        await prefs.remove(_cacheKey); // Remove from shared prefs to avoid confusion
      }
    } catch (e) {
      throw RecipesLocalDataSourceException('Failed to cache recipes: ${e.toString()}');
    }
  }

  Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheTime = prefs.getInt(_cacheTimeKey);
      
      if (cacheTime == null) return false;
      
      final cacheDate = DateTime.fromMillisecondsSinceEpoch(cacheTime);
      final now = DateTime.now();
      final difference = now.difference(cacheDate).inMinutes;
      
      final isValid = difference < _cacheValidityMinutes;
      return isValid;
    } catch (e) {
      return false;
    }
  }

  Future<Recipe?> getRecipe(String id) async {
    try {
      final recipes = await getRecipes();
      final matchingRecipes = recipes.where((recipe) => recipe.id == id);
      return matchingRecipes.isEmpty ? null : matchingRecipes.first;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimeKey);
      
      final cacheFile = await _getCacheFile();
      if (await cacheFile.exists()) {
        await cacheFile.delete();
      }
      
    } catch (e) {
    }
  }

  Future<File> _getCacheFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_cacheFileKey');
  }
}

class RecipesLocalDataSourceException implements Exception {
  final String message;

  RecipesLocalDataSourceException(this.message);

  @override
  String toString() => 'RecipesLocalDataSourceException: $message';
}
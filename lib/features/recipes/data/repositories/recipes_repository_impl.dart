import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/models/recipe.dart';
import '../../domain/repositories/recipes_repository.dart';
import '../datasources/recipes_datasource.dart';
import '../datasources/recipes_firebase_datasource.dart';
import '../datasources/recipes_local_datasource.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/dietary_filter_service.dart';

class RecipesRepositoryImpl implements RecipesRepository {
  final RecipesDataSource _remoteDataSource;
  final RecipesLocalDataSource _localDataSource;

  RecipesRepositoryImpl({
    RecipesDataSource? remoteDataSource,
    RecipesLocalDataSource? localDataSource,
  })  : _remoteDataSource = remoteDataSource ?? RecipesFirebaseDataSource(),
        _localDataSource = localDataSource ?? RecipesLocalDataSource();

  @override
  Future<List<Recipe>> getRecipes({
    bool forceRefresh = false,
    DietaryType? dietaryType,
  }) async {
    try {
      if (!forceRefresh && await _localDataSource.isCacheValid()) {
        final cachedRecipes = await _localDataSource.getRecipes();
        if (cachedRecipes.isNotEmpty) {
          return DietaryFilterService.filterRecipesByDietaryType(cachedRecipes, dietaryType);
        }
      }

      final remoteRecipes = await _remoteDataSource.getRecipes();
      
      await _localDataSource.cacheRecipes(remoteRecipes);
      
      return DietaryFilterService.filterRecipesByDietaryType(remoteRecipes, dietaryType);
    } catch (e) {
      
      try {
        final cachedRecipes = await _localDataSource.getRecipes();
        if (cachedRecipes.isNotEmpty) {
          return DietaryFilterService.filterRecipesByDietaryType(cachedRecipes, dietaryType);
        }
      } catch (cacheError) {
      }
      
      throw RecipesRepositoryException(
        'Failed to fetch recipes: ${e.toString()}',
      );
    }
  }

  @override
  Stream<List<Recipe>> getRecipesStream({DietaryType? dietaryType}) {
    try {
      return _remoteDataSource.getRecipesStream()
          .map((recipes) => DietaryFilterService.filterRecipesByDietaryType(recipes, dietaryType))
          .handleError((error) {
        throw RecipesRepositoryException(
          'Failed to stream recipes: ${error.toString()}',
        );
      });
    } catch (e) {
      throw RecipesRepositoryException(
        'Failed to create recipes stream: ${e.toString()}',
      );
    }
  }

  @override
  Future<Recipe?> getRecipe(String id) async {
    try {
      final recipe = await _remoteDataSource.getRecipe(id);
      if (recipe != null) {
        return recipe;
      }

      return await _localDataSource.getRecipe(id);
    } catch (e) {
      
      try {
        return await _localDataSource.getRecipe(id);
      } catch (cacheError) {
      }
      
      throw RecipesRepositoryException(
        'Failed to fetch recipe with id $id: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<Recipe>> getRecipesByTags(
    List<String> tags, {
    bool forceRefresh = false,
    DietaryType? dietaryType,
  }) async {
    try {
      final allRecipes = await getRecipes(forceRefresh: forceRefresh, dietaryType: dietaryType);
      
      if (tags.isEmpty) {
        return allRecipes;
      }

      return allRecipes.where((recipe) {
        return tags.any((tag) => recipe.tags.contains(tag));
      }).toList();
    } catch (e) {
      throw RecipesRepositoryException(
        'Failed to get recipes by tags: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<Recipe>> searchRecipes(
    String query, {
    bool forceRefresh = false,
    DietaryType? dietaryType,
  }) async {
    try {
      final allRecipes = await getRecipes(forceRefresh: forceRefresh, dietaryType: dietaryType);
      
      if (query.trim().isEmpty) {
        return allRecipes;
      }

      final lowerQuery = query.toLowerCase().trim();

      return allRecipes.where((recipe) {
        // Search in title
        if (recipe.title.toLowerCase().contains(lowerQuery)) {
          return true;
        }

        // Search in description
        if (recipe.description?.toLowerCase().contains(lowerQuery) == true) {
          return true;
        }

        // Search in tags
        if (recipe.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))) {
          return true;
        }

        // Search in ingredients
        final hasMatchingIngredient = recipe.ingredients.any((ingredient) {
          return ingredient.name.toLowerCase().contains(lowerQuery);
        });

        if (hasMatchingIngredient) {
          return true;
        }

        // Search in legacy ingredients for backward compatibility
        if (recipe.legacyIngredients.any((ingredient) => 
            ingredient.toLowerCase().contains(lowerQuery))) {
          return true;
        }

        return false;
      }).toList();
    } catch (e) {
      throw RecipesRepositoryException(
        'Failed to search recipes: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<String>> getAvailableCategories({DietaryType? dietaryType}) async {
    try {
      final allRecipes = await getRecipes(dietaryType: dietaryType);
      final Set<String> categories = {};

      for (final recipe in allRecipes) {
        categories.addAll(recipe.tags);
      }

      final sortedCategories = categories.toList()..sort();
      return sortedCategories;
    } catch (e) {
      throw RecipesRepositoryException(
        'Failed to get available categories: ${e.toString()}',
      );
    }
  }

  @override
  Future<RecipesPagination> getRecipesByIngredient(
    String ingredientName, {
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
    DietaryType? dietaryType,
  }) async {
    try {
      final allRecipes = await getRecipes(forceRefresh: forceRefresh, dietaryType: dietaryType);
      
      if (ingredientName.trim().isEmpty) {
        return RecipesPagination(
          recipes: const [],
          hasMore: false,
          totalCount: 0,
        );
      }

      final lowerIngredientName = ingredientName.toLowerCase().trim();

      // Filter recipes that contain the ingredient
      final matchingRecipes = allRecipes.where((recipe) {
        // Search in structured ingredients
        final hasMatchingStructuredIngredient = recipe.ingredients.any((ingredient) {
          return ingredient.name.toLowerCase().contains(lowerIngredientName);
        });

        if (hasMatchingStructuredIngredient) return true;

        // Search in ingredient sections
        final hasMatchingIngredientInSections = recipe.ingredientSections.any((section) {
          return section.ingredients.any((ingredient) {
            return ingredient.name.toLowerCase().contains(lowerIngredientName);
          });
        });

        if (hasMatchingIngredientInSections) return true;

        // Search in legacy ingredients for backward compatibility
        final hasMatchingLegacyIngredient = recipe.legacyIngredients.any((ingredient) {
          return ingredient.toLowerCase().contains(lowerIngredientName);
        });

        return hasMatchingLegacyIngredient;
      }).toList();

      // Calculate pagination
      final totalCount = matchingRecipes.length;
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;

      final paginatedRecipes = matchingRecipes.skip(startIndex).take(limit).toList();
      final hasMore = endIndex < totalCount;

      return RecipesPagination(
        recipes: paginatedRecipes,
        hasMore: hasMore,
        totalCount: totalCount,
      );
    } catch (e) {
      throw RecipesRepositoryException(
        'Failed to get recipes by ingredient: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> refreshRecipes() async {
    try {
      await getRecipes(forceRefresh: true);
    } catch (e) {
      throw RecipesRepositoryException(
        'Failed to refresh recipes: ${e.toString()}',
      );
    }
  }
}

class RecipesRepositoryException implements Exception {
  final String message;

  RecipesRepositoryException(this.message);

  @override
  String toString() => 'RecipesRepositoryException: $message';
}
import '../models/pantry_item.dart';

abstract class PantryRepository {
  
  Future<List<PantryItem>> getUserPantryItems(String userId);
  
  Stream<List<PantryItem>> getUserPantryItemsStream(String userId);
  
  Future<PantryItem?> getPantryItem(String userId, String itemId);
  
  Future<String> addPantryItem(PantryItem item);
  
  Future<void> updatePantryItem(PantryItem item);
  
  Future<void> deletePantryItem(String userId, String itemId);
  
  Future<void> deleteAllUserPantryItems(String userId);
  
  Future<List<String>> searchIngredients(String query, {int limit = 10});
  
  Future<List<PantryItem>> getPantryItemsByCategory(String userId, PantryCategory category);
  
  Future<bool> hasIngredient(String userId, String ingredientName);
  
  Future<List<String>> getPantryIngredientNames(String userId);
}
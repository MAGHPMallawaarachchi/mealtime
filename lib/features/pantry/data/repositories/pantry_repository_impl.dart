import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/pantry_item.dart';
import '../../domain/repositories/pantry_repository.dart';
import '../../../../core/services/firestore_service.dart';
import '../sri_lankan_ingredients.dart';

class PantryRepositoryImpl implements PantryRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Common Sri Lankan ingredients for autocomplete
  static const List<String> _commonIngredients = [
    // Sri Lankan staples
    'Rice',
    'Coconut',
    'Coconut Milk',
    'Curry Leaves',
    'Karapincha',
    'Pandan Leaves',
    'Rampe',
    'Lemongrass',
    'Cinnamon',
    'Cardamom',
    'Cloves',
    'Black Pepper',
    'Turmeric',
    'Chili Powder',
    'Coriander',
    'Cumin',
    'Fenugreek',
    'Mustard Seeds',
    'Fennel Seeds',
    'Onions',
    'Garlic',
    'Ginger',
    'Green Chilies',
    'Red Chilies',
    'Tomatoes',
    'Lime',
    'Tamarind',
    'Fish',
    'Chicken',
    'Beef',
    'Prawns',
    'Eggs',
    'Dhal',
    'Lentils',
    'Chickpeas',
    'Green Beans',
    'Okra',
    'Eggplant',
    'Brinjal',
    'Potatoes',
    'Sweet Potatoes',
    'Pumpkin',
    'Bottle Gourd',
    'Ridge Gourd',
    'Bitter Gourd',
    'Drumsticks',
    'Jack Fruit',
    'Plantain',
    'Coconut Oil',
    'Sesame Oil',
    'Ghee',
    'Jaggery',
    'Palm Sugar',
    'Treacle',
    // Common international ingredients
    'Salt',
    'Sugar',
    'Oil',
    'Flour',
    'Bread',
    'Milk',
    'Butter',
    'Cheese',
    'Yogurt',
    'Vinegar',
    'Soy Sauce',
    'Honey',
    'Vanilla',
  ];

  String _getPantryCollectionPath(String userId) {
    return 'users/$userId/pantry_items';
  }

  @override
  Future<List<PantryItem>> getUserPantryItems(String userId) async {
    try {
      final items = await _firestoreService.getCollectionWithQuery(
        _getPantryCollectionPath(userId),
        orderBy: 'updatedAt',
        descending: true,
      );
      
      return items.map((item) => PantryItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to get pantry items: ${e.toString()}');
    }
  }

  @override
  Stream<List<PantryItem>> getUserPantryItemsStream(String userId) {
    try {
      return _firestore
          .collection(_getPantryCollectionPath(userId))
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return PantryItem.fromJson(data);
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to get pantry items stream: ${e.toString()}');
    }
  }

  @override
  Future<PantryItem?> getPantryItem(String userId, String itemId) async {
    try {
      final item = await _firestoreService.getDocument(
        _getPantryCollectionPath(userId),
        itemId,
      );
      
      return item != null ? PantryItem.fromJson(item) : null;
    } catch (e) {
      throw Exception('Failed to get pantry item: ${e.toString()}');
    }
  }

  @override
  Future<String> addPantryItem(PantryItem item) async {
    try {
      // Check if ingredient already exists for this user
      final existingItems = await getUserPantryItems(item.userId);
      final normalizedName = item.name.toLowerCase().trim();
      
      for (final existingItem in existingItems) {
        if (existingItem.name.toLowerCase().trim() == normalizedName) {
          throw Exception('This ingredient is already in your pantry');
        }
      }

      final docRef = await _firestore
          .collection(_getPantryCollectionPath(item.userId))
          .add({
        ...item.toJson()..remove('id'),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add pantry item: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePantryItem(PantryItem item) async {
    try {
      // Check if updated name already exists for this user (excluding current item)
      final existingItems = await getUserPantryItems(item.userId);
      final normalizedName = item.name.toLowerCase().trim();
      
      for (final existingItem in existingItems) {
        if (existingItem.id != item.id && 
            existingItem.name.toLowerCase().trim() == normalizedName) {
          throw Exception('An ingredient with this name already exists in your pantry');
        }
      }

      await _firestore
          .collection(_getPantryCollectionPath(item.userId))
          .doc(item.id)
          .update({
        ...item.toJson()..remove('id'),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update pantry item: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePantryItem(String userId, String itemId) async {
    try {
      await _firestore
          .collection(_getPantryCollectionPath(userId))
          .doc(itemId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete pantry item: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAllUserPantryItems(String userId) async {
    try {
      final collection = _firestore.collection(_getPantryCollectionPath(userId));
      final snapshot = await collection.get();
      
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all pantry items: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> searchIngredients(String query, {int limit = 10}) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      // First try Sri Lankan ingredients database
      final sriLankanResults = SriLankanIngredients.searchIngredients(query);
      
      // Then fall back to common ingredients
      final lowerQuery = query.toLowerCase();
      final commonResults = _commonIngredients
          .where((ingredient) => ingredient.toLowerCase().contains(lowerQuery))
          .toList();

      // Combine and deduplicate
      final combinedResults = <String>{};
      combinedResults.addAll(sriLankanResults);
      combinedResults.addAll(commonResults);

      return combinedResults.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to search ingredients: ${e.toString()}');
    }
  }

  @override
  Future<List<PantryItem>> getPantryItemsByCategory(
    String userId, 
    PantryCategory category,
  ) async {
    try {
      final items = await _firestoreService.getCollectionWithQuery(
        _getPantryCollectionPath(userId),
        where: {'category': category.name},
        orderBy: 'name',
      );
      
      return items.map((item) => PantryItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to get pantry items by category: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasIngredient(String userId, String ingredientName) async {
    try {
      final items = await getUserPantryItems(userId);
      final normalizedName = ingredientName.toLowerCase().trim();
      
      return items.any((item) => 
        item.name.toLowerCase().trim() == normalizedName);
    } catch (e) {
      throw Exception('Failed to check ingredient availability: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getPantryIngredientNames(String userId) async {
    try {
      final items = await getUserPantryItems(userId);
      return items.map((item) => item.name).toList();
    } catch (e) {
      throw Exception('Failed to get pantry ingredient names: ${e.toString()}');
    }
  }
}
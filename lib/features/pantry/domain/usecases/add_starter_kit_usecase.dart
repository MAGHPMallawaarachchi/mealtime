import '../models/pantry_item.dart';
import '../repositories/pantry_repository.dart';
import '../../data/sri_lankan_ingredients.dart';

class AddStarterKitUseCase {
  final PantryRepository repository;

  const AddStarterKitUseCase(this.repository);

  Future<List<String>> execute(String userId) async {
    try {
      if (userId.trim().isEmpty) {
        throw Exception('User ID is required');
      }

      final starterIngredients = SriLankanIngredients.getStarterKit();
      final addedIngredients = <String>[];

      for (final ingredientData in starterIngredients) {
        try {
          final item = PantryItem(
            id: '',
            name: ingredientData['name'] as String,
            category: ingredientData['category'] as PantryCategory,
            tags: ['starter-kit', 'essential'],
            userId: userId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          final itemId = await repository.addPantryItem(item);
          addedIngredients.add(item.name);
        } catch (e) {
          // Skip if ingredient already exists, continue with others
          continue;
        }
      }

      if (addedIngredients.isEmpty) {
        throw Exception('No new ingredients were added. You might already have these items in your pantry.');
      }

      return addedIngredients;
    } catch (e) {
      throw Exception('Failed to add starter kit: ${e.toString()}');
    }
  }

  List<Map<String, dynamic>> getStarterKitPreview() {
    return SriLankanIngredients.getStarterKit();
  }
}
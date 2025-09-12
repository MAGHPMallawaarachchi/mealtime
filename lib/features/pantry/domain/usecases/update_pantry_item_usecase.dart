import '../models/pantry_item.dart';
import '../repositories/pantry_repository.dart';

class UpdatePantryItemUseCase {
  final PantryRepository repository;

  const UpdatePantryItemUseCase(this.repository);

  Future<void> execute(PantryItem item) async {
    try {
      if (item.id.trim().isEmpty) {
        throw Exception('Item ID is required');
      }

      if (item.name.trim().isEmpty) {
        throw Exception('Ingredient name cannot be empty');
      }

      if (item.userId.trim().isEmpty) {
        throw Exception('User ID is required');
      }

      final updatedItem = item.copyWith(
        name: _normalizeIngredientName(item.name),
        updatedAt: DateTime.now(),
      );

      await repository.updatePantryItem(updatedItem);
    } catch (e) {
      throw Exception('Failed to update pantry item: ${e.toString()}');
    }
  }

  String _normalizeIngredientName(String name) {
    return name.trim().toLowerCase().split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
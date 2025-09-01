import '../models/pantry_item.dart';
import '../repositories/pantry_repository.dart';

class AddPantryItemUseCase {
  final PantryRepository repository;

  const AddPantryItemUseCase(this.repository);

  Future<String> execute(PantryItem item) async {
    try {
      if (item.name.trim().isEmpty) {
        throw Exception('Ingredient name cannot be empty');
      }

      if (item.userId.trim().isEmpty) {
        throw Exception('User ID is required');
      }

      final normalizedItem = item.copyWith(
        name: _normalizeIngredientName(item.name),
        updatedAt: DateTime.now(),
      );

      return await repository.addPantryItem(normalizedItem);
    } catch (e) {
      throw Exception('Failed to add pantry item: ${e.toString()}');
    }
  }

  Future<String> executeWithDetails({
    required String userId,
    required String name,
    required PantryCategory category,
    List<String>? tags,
  }) async {
    final item = PantryItem(
      id: '',
      name: name,
      category: category,
      tags: tags ?? [],
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return execute(item);
  }

  String _normalizeIngredientName(String name) {
    return name.trim().toLowerCase().split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
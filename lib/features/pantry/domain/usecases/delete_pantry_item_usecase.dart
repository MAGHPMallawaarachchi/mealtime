import '../repositories/pantry_repository.dart';

class DeletePantryItemUseCase {
  final PantryRepository repository;

  const DeletePantryItemUseCase(this.repository);

  Future<void> execute(String userId, String itemId) async {
    try {
      if (userId.trim().isEmpty) {
        throw Exception('User ID is required');
      }

      if (itemId.trim().isEmpty) {
        throw Exception('Item ID is required');
      }

      await repository.deletePantryItem(userId, itemId);
    } catch (e) {
      throw Exception('Failed to delete pantry item: ${e.toString()}');
    }
  }

  Future<void> executeAll(String userId) async {
    try {
      if (userId.trim().isEmpty) {
        throw Exception('User ID is required');
      }

      await repository.deleteAllUserPantryItems(userId);
    } catch (e) {
      throw Exception('Failed to delete all pantry items: ${e.toString()}');
    }
  }
}
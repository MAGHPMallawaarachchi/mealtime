import '../models/pantry_item.dart';
import '../repositories/pantry_repository.dart';

class GetPantryItemsUseCase {
  final PantryRepository repository;

  const GetPantryItemsUseCase(this.repository);

  Future<List<PantryItem>> execute(String userId) async {
    try {
      return await repository.getUserPantryItems(userId);
    } catch (e) {
      throw Exception('Failed to get pantry items: ${e.toString()}');
    }
  }

  Stream<List<PantryItem>> executeStream(String userId) {
    try {
      return repository.getUserPantryItemsStream(userId);
    } catch (e) {
      throw Exception('Failed to get pantry items stream: ${e.toString()}');
    }
  }
}
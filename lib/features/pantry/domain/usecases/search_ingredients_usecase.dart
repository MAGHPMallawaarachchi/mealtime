import '../repositories/pantry_repository.dart';

class SearchIngredientsUseCase {
  final PantryRepository repository;

  const SearchIngredientsUseCase(this.repository);

  Future<List<String>> execute(String query, {int limit = 10}) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      return await repository.searchIngredients(query, limit: limit);
    } catch (e) {
      throw Exception('Failed to search ingredients: ${e.toString()}');
    }
  }
}
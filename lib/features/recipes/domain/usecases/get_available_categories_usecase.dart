import '../repositories/recipes_repository.dart';

class GetAvailableCategoriesUseCase {
  final RecipesRepository _repository;

  GetAvailableCategoriesUseCase(this._repository);

  Future<List<String>> execute() {
    return _repository.getAvailableCategories();
  }
}
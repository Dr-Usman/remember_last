abstract class CategoryRepository {
  Stream<List<String>> watchCategoryNames();

  Future<List<String>> getAllCategoryNames();

  Future<int> addCategory(String name);

  Future<void> deleteCategory(int id);

  Future<void> renameCategory(int id, String newName);
}

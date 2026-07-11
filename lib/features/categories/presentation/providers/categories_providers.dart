import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(databaseProvider));
});

final categoryListRepositoryProvider = Provider<CategoryListRepository>((ref) {
  return CategoryListRepository(ref.watch(databaseProvider));
});

final managedCategoriesProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchCategoryNames();
});

final mergedCategoriesProvider = StreamProvider<List<String>>((ref) {
  return ref
      .watch(categoryListRepositoryProvider)
      .watchMergedCategoryNames();
});

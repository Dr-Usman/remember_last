import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_last/features/activities/presentation/widgets/home_filters_bar.dart';
import 'package:remember_last/features/categories/presentation/providers/categories_providers.dart';

import 'helpers/l10n_wrap.dart';

void main() {
  testWidgets('HomeFiltersBar pumps without render assertions', (tester) async {
    final errors = <String>[];
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      errors.add(details.exceptionAsString());
      previous?.call(details);
    };
    addTearDown(() => FlutterError.onError = previous);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mergedCategoriesProvider.overrideWith(
            (ref) => Stream.value(const <String>['Work']),
          ),
        ],
        child: wrapApp(
          const Scaffold(
            body: Padding(padding: EdgeInsets.all(16), child: HomeFiltersBar()),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(HomeFiltersBar), findsOneWidget);
    expect(find.byIcon(Icons.sort), findsOneWidget);
    expect(
      errors.where(
        (e) =>
            e.contains('debugFrameWasSentToEngine') ||
            e.contains('parentDataDirty'),
      ),
      isEmpty,
      reason: 'Unexpected render/semantics assertions: $errors',
    );
  });
}

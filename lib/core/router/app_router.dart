import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activities/presentation/screens/activity_form_screen.dart';
import '../../features/activities/presentation/screens/home_screen.dart';
import '../../features/insights/presentation/screens/insights_screen.dart';
import '../../features/occurrences/presentation/screens/activity_detail_screen.dart';
import '../../features/settings/presentation/screens/about_screen.dart';
import '../../features/settings/presentation/screens/categories_management_screen.dart';
import '../../features/settings/presentation/screens/privacy_policy_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/activity/new',
        name: 'activityNew',
        builder: (context, state) => const ActivityFormScreen(),
      ),
      GoRoute(
        path: '/activity/:id/edit',
        name: 'activityEdit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ActivityFormScreen(activityId: id);
        },
      ),
      GoRoute(
        path: '/activity/:id',
        name: 'activityDetail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ActivityDetailScreen(activityId: id);
        },
      ),
      GoRoute(
        path: '/insights',
        name: 'insights',
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'categories',
            builder: (context, state) => const CategoriesManagementScreen(),
          ),
          GoRoute(
            path: 'about',
            builder: (context, state) => const AboutScreen(),
          ),
          GoRoute(
            path: 'privacy',
            builder: (context, state) => const PrivacyPolicyScreen(),
          ),
        ],
      ),
    ],
  );
});

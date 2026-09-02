import 'package:flutter/material.dart';

import '../services/analytics_service.dart';

/// Tracks [AnalyticsConstants.screenViewed] on route pushes.
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver(this._analytics);

  final AnalyticsService _analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final screenName = route.settings.name;
    if (screenName == null || screenName.isEmpty) return;
    _analytics.trackScreenViewed(screenName);
  }
}

import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_routes.dart';

class AppRouter {
  // Prevent instantiation
  AppRouter._();

  static void toSortingSurveys(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.sortingSurveys);
  }

  static void toCreateSortingSurvey(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.createSortingSurvey);
  }

  static void toUserManagement(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.userManagement);
  }

  static void toSortingSurveyDetails(BuildContext context,
      {required String surveyId}) {
    // Set survey ID before navigation
    ProviderScope.containerOf(context)
        .read(selectedSortingSurveyIdProvider.notifier)
        .state = surveyId;

    // Define a dedicated loading state provider for smoother transitions
    ProviderScope.containerOf(context)
        .read(surveyLoadingStateProvider.notifier)
        .state = true;

    // Simply navigate with standard route - the page will show skeletons by default
    Navigator.pushNamed(
      context,
      AppRoutes.sortingSurveyDetails,
      arguments: surveyId,
    );
  }
}

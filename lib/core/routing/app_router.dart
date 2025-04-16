import 'package:flutter/material.dart';
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

  static void toSortingSurveyDetails(BuildContext context,
      {required String surveyId}) {
    Navigator.pushNamed(
      context,
      AppRoutes.sortingSurveyDetails,
      arguments: surveyId,
    );
  }
}

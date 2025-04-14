import 'package:edconnect_admin/presentation/pages/sorting_module_pages/create_sorting_survey_page.dart';
import 'package:flutter/material.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module_pages/sorting_surveys_page.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module_pages/sorting_survey_details.dart';

class AppRoutes {
  // Prevent instantiation
  AppRoutes._();

  // Route names
  static const String sortingSurveys = '/sorting-surveys';
  static const String createSortingSurvey = '/sorting-surveys/create';
  static const String sortingSurveyDetails = '/sorting-surveys/details';

  // Route generator
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case sortingSurveys:
        return MaterialPageRoute(
          builder: (_) => const SortingSurveysPage(),
          settings: settings,
        );

      case createSortingSurvey:
        return MaterialPageRoute(
          builder: (_) => const SortingSurveyCreatePage(),
          settings: settings,
        );

      case sortingSurveyDetails:
        return MaterialPageRoute(
          builder: (_) => const SortingSurveyDetailsPage(),
          settings: settings,
        );

      default:
        // Handle unknown routes
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }
}

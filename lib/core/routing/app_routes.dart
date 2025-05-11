import 'package:edconnect_admin/presentation/pages/sorting_module/pages/create/create_sorting_survey_page.dart';
import 'package:flutter/material.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/pages/list/sorting_surveys_page.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/pages/details/sorting_survey_details.dart';

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
        final surveyId = settings.arguments as String;
        return PageRouteBuilder(
          transitionDuration: Duration.zero,
          pageBuilder: (context, animation, secondaryAnimation) {
            return SortingSurveyDetailsPage(surveyId: surveyId);
          },
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

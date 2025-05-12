import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/domain/entities/group.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/pages/create/create_sorting_survey_page.dart';
import 'package:edconnect_admin/presentation/pages/user_management/create_group.dart';
import 'package:edconnect_admin/presentation/pages/user_management/group_details.dart';
import 'package:edconnect_admin/presentation/pages/user_management/user_details.dart';
import 'package:edconnect_admin/presentation/pages/user_management/user_management_page.dart';
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
  static const String userManagement = '/user-management';
  static const String userDetails = '/user-management/details';
  static const String createGroup = '/user-management/create-group';
  static const String groupDetails = '/user-management/group-details';
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

      case userManagement:
        return MaterialPageRoute(
          builder: (_) => const UserManagementPage(),
          settings: settings,
        );
      case userDetails:
        final user = settings.arguments as AppUser;
        return PageRouteBuilder(
          transitionDuration: Duration.zero,
          pageBuilder: (context, animation, secondaryAnimation) {
            return UserDetails(user: user);
          },
        );
      case createGroup:
        return MaterialPageRoute(
          builder: (_) => const CreateGroupPage(),
          settings: settings,
        );
      case groupDetails:
        final group = settings.arguments as Group;
        return MaterialPageRoute(
          builder: (_) => GroupDetailsPage(group: group),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Center(
            child: Column(
              children: [
                Text('Route ${settings.name} not found'),
              ],
            ),
          ),
        );
    }
  }
}

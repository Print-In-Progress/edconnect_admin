import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/domain/entities/group.dart';
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

  static void toUserDetails(BuildContext context, {required AppUser user}) {
    Navigator.pushNamed(
      context,
      AppRoutes.userDetails,
      arguments: user,
    );
  }

  static void toGroupDetails(BuildContext context, {required Group group}) {
    Navigator.pushNamed(
      context,
      AppRoutes.groupDetails,
      arguments: group,
    );
  }

  static void toCreateGroup(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.createGroup);
  }

  static void toSortingSurveyDetails(BuildContext context,
      {required String surveyId}) {
    ProviderScope.containerOf(context)
        .read(selectedSortingSurveyIdProvider.notifier)
        .state = surveyId;

    ProviderScope.containerOf(context)
        .read(surveyLoadingStateProvider.notifier)
        .state = true;

    Navigator.pushNamed(
      context,
      AppRoutes.sortingSurveyDetails,
      arguments: surveyId,
    );
  }
}

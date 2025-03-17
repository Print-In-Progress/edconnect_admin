import 'package:edconnect_admin/domain/entities/permissions.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/navigation_item.dart';

abstract class NavigationRepository {
  /// Get the list of all navigation items
  List<NavigationItem> getNavigationItems();

  /// Get the appropriate widget for a navigation item ID
  Widget getScreenForNavigationItem(
      String navigationItemId, List<String> userPermissions);

  /// Check if user has access to a screen based on permissions
  bool checkAccess(
      List<String> requiredPermissionIds, List<String> userPermissions);

  /// Get feature permissions by ID
  List<Permission> getFeaturePermissions(String featureId);
}

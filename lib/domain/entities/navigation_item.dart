import 'package:edconnect_admin/domain/entities/permissions.dart';
import 'package:flutter/material.dart';

class NavigationItem {
  final String id;
  final String titleKey;
  final IconData icon;
  final IconData selectedIcon;
  final List<Permission> requiredPermissions;

  const NavigationItem({
    required this.id,
    required this.titleKey,
    required this.icon,
    required this.selectedIcon,
    required this.requiredPermissions,
  });

  // Helper method to get permission IDs
  List<String> get requiredPermissionIds =>
      requiredPermissions.map((p) => p.id).toList();
}

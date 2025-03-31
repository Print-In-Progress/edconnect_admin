import 'package:edconnect_admin/domain/entities/permissions.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget that only shows its child if user has required permission
class SinglePermissionAwareWidget extends ConsumerWidget {
  final Permission permission;
  final Widget child;
  final Widget? fallback;

  const SinglePermissionAwareWidget({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) {
      return fallback ?? const SizedBox.shrink();
    }

    return user.hasPermission(permission.id)
        ? child
        : (fallback ?? const SizedBox.shrink());
  }
}

/// Widget that checks for multiple permissions
class MultiplePermissionsAwareWidget extends ConsumerWidget {
  final List<Permission> permissions;
  final Widget child;
  final Widget? fallback;
  final bool requireAll;

  const MultiplePermissionsAwareWidget({
    super.key,
    required this.permissions,
    required this.child,
    this.fallback,
    this.requireAll = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) {
      return fallback ?? const SizedBox.shrink();
    }

    final permissionIds = permissions.map((p) => p.id).toList();

    final hasAccess = requireAll
        ? permissionIds.every(user.hasPermission)
        : user.hasAnyPermission(permissionIds);

    return hasAccess ? child : (fallback ?? const SizedBox.shrink());
  }
}

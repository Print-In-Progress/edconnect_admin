import 'package:edconnect_admin/models/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PermissionWidget extends ConsumerWidget {
  final List<String> requiredPermissions;
  final Widget child;
  final Widget? fallback;

  const PermissionWidget({
    super.key,
    required this.requiredPermissions,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPermissions =
        ref.watch(currentUserProvider).value?.permissions ?? [];

    final hasAccess = requiredPermissions
        .any((permission) => userPermissions.contains(permission));

    return hasAccess ? child : (fallback ?? const SizedBox.shrink());
  }
}

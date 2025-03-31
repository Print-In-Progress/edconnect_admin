// import 'package:edconnect_admin/presentation/providers/state_providers.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../domain/entities/permissions.dart';
// import '../../providers/navigation_providers.dart';

// /// Widget that only shows its child if user has required permission
// class PermissionAwareWidget extends ConsumerWidget {
//   /// The permission from Permissions class
//   final Permission permission;

//   /// Widget to show if user has permission
//   final Widget child;

//   /// Optional widget to show if permission is denied
//   final Widget? fallback;

//   const PermissionAwareWidget({
//     super.key,
//     required this.permission,
//     required this.child,
//     this.fallback,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final permissionService = ref.watch(permissionServiceProvider);
//     final userPermissions =
//         ref.watch(authStateProvider).valueOrNull?.permissions ?? [];

//     final hasAccess =
//         permissionService.hasPermission(permission.id, userPermissions);

//     return hasAccess ? child : (fallback ?? const SizedBox.shrink());
//   }
// }

// /// Widget that only shows its child if user has at least one required permission
// class PermissionsAwareWidget extends ConsumerWidget {
//   /// The permissions to check
//   final List<Permission> requiredPermissions;

//   /// Widget to show if user has permission
//   final Widget child;

//   /// Optional widget to show if permission is denied
//   final Widget? fallback;

//   /// If true, user must have ALL permissions. If false, ANY permission is sufficient.
//   final bool requireAll;

//   const PermissionsAwareWidget({
//     super.key,
//     required this.requiredPermissions,
//     required this.child,
//     this.fallback,
//     this.requireAll = false,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final permissionService = ref.watch(permissionServiceProvider);
//     final userPermissions =
//         ref.watch(authStateProvider).valueOrNull?.permissions ?? [];

//     // Extract permission IDs
//     final requiredPermissionIds = requiredPermissions.map((p) => p.id).toList();

//     bool hasAccess;

//     if (requireAll) {
//       // User needs ALL permissions (or admin)
//       hasAccess = userPermissions.contains(Permissions.admin.id) ||
//           requiredPermissionIds.every((p) => userPermissions.contains(p));
//     } else {
//       // User needs ANY permission
//       hasAccess = permissionService.hasAnyPermission(
//           requiredPermissionIds, userPermissions);
//     }

//     return hasAccess ? child : (fallback ?? const SizedBox.shrink());
//   }
// }


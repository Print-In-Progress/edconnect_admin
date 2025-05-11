import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/domain/entities/group.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NamedItem {
  final String id;
  final String name;

  NamedItem({required this.id, required this.name});
}

class MultiValueRow extends ConsumerStatefulWidget {
  final List<String> ids;
  final String label;
  final bool isUserIds;
  const MultiValueRow({
    super.key,
    required this.ids,
    required this.label,
    this.isUserIds = false,
  });

  @override
  ConsumerState<MultiValueRow> createState() => _MultiValueRowState();
}

class _MultiValueRowState extends ConsumerState<MultiValueRow> {
  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(allGroupsStreamProvider).value ?? [];
    final users = ref.watch(allUsersStreamProvider).value ?? [];
    final theme = ref.watch(appThemeProvider);

    final List<NamedItem> items = widget.ids.map((id) {
      if (widget.ids.isEmpty || widget.ids[0].startsWith('No ')) {
        return NamedItem(id: id, name: id);
      }

      if (widget.isUserIds) {
        final user = users.firstWhere((u) => u.id == id,
            orElse: () => AppUser(
                id: id,
                firstName: 'Unknown',
                lastName: 'User',
                email: '',
                fcmTokens: [],
                groupIds: [],
                permissions: [],
                deviceIds: {},
                accountType: ''));
        return NamedItem(id: id, name: user.fullName);
      } else {
        // Find matching group
        final group = groups.firstWhere((g) => g.id == id,
            orElse: () => Group(
                  id: id,
                  name: 'Unknown Group',
                  memberIds: [],
                  permissions: [],
                ));
        return NamedItem(id: id, name: group.name);
      }
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 160,
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: Foundations.typography.base,
              fontWeight: Foundations.typography.medium,
              color: theme.isDarkMode
                  ? Foundations.darkColors.textSecondary
                  : Foundations.colors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: Foundations.spacing.sm,
            runSpacing: Foundations.spacing.sm,
            children: items.map((item) {
              return Tooltip(
                message: item.name,
                textStyle: TextStyle(
                  color: theme.isDarkMode
                      ? Foundations.darkColors.textPrimary
                      : Foundations.colors.textPrimary,
                ),
                decoration: BoxDecoration(
                  color: theme.isDarkMode
                      ? Foundations.darkColors.backgroundMuted
                      : Foundations.colors.backgroundMuted,
                  borderRadius: Foundations.borders.md,
                ),
                child: BaseChip(
                  label: item.name,
                  variant: ChipVariant.default_,
                  size: ChipSize.medium,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

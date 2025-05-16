import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/app_bar.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/presentation/pages/user_management/users_tab.dart';

import 'package:edconnect_admin/presentation/pages/user_management/groups_tab.dart';

class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: theme.isDarkMode
          ? Foundations.darkColors.background
          : Foundations.colors.background,
      appBar: BaseAppBar(
        title: l10n.userManagementUserManagementLabel,
      ),
      body: Padding(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: Tabs(
          tabs: [
            TabItem(
              label: l10n.globalUserLabel(0),
              icon: Icons.people_outline,
              content: const UsersTab(),
            ),
            TabItem(
              label: l10n.globalGroupLabel(0),
              icon: Icons.group_work_outlined,
              content: const GroupsTab(),
            ),
          ],
          currentValue: _selectedTabIndex,
          onChanged: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
        ),
      ),
    );
  }
}

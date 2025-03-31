import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/presentation/pages/settings_pages/settings_main_page.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/card.dart';
import 'package:edconnect_admin/domain/services/url_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PIPCancelButton extends StatelessWidget {
  const PIPCancelButton({super.key});
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        Navigator.of(context).pop();
      },
      label: Text(
        AppLocalizations.of(context)!.globalCancelButtonLabel,
        style: const TextStyle(
          color: Color(0xFFFF0000),
          fontWeight: FontWeight.w600,
        ),
      ),
      icon: const Icon(
        Icons.block,
        color: Color(0xFFFF0000),
      ),
    );
  }
}

class PIPDialogTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const PIPDialogTextButton(
      {super.key, required this.label, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          onPressed();
        },
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ));
  }
}

class PIPResponsiveRaisedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final dynamic width;
  final IconData? icon;
  final dynamic height;
  final FontWeight? fontWeight;
  final double fontSize;
  const PIPResponsiveRaisedButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.height,
      this.fontWeight = FontWeight.normal,
      this.fontSize = 18,
      this.icon,
      required this.width});
  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      if (height != null) {
        return ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: Size(width, height)),
            onPressed: () {
              onPressed();
            },
            child: Text(
              label,
              style: TextStyle(fontWeight: fontWeight, fontSize: fontSize),
            ));
      } else {
        return SizedBox(
          width: width,
          child: ElevatedButton(
              onPressed: () {
                onPressed();
              },
              child: Text(
                label,
                style: TextStyle(fontWeight: fontWeight, fontSize: fontSize),
              )),
        );
      }
    } else {
      if (height != null) {
        return ElevatedButton.icon(
            style: ElevatedButton.styleFrom(minimumSize: Size(width, height)),
            onPressed: () {
              onPressed();
            },
            icon: Icon(icon!),
            label: Text(
              label,
              style: TextStyle(fontWeight: fontWeight, fontSize: fontSize),
            ));
      } else {
        return SizedBox(
          width: width,
          child: ElevatedButton.icon(
              onPressed: () {
                onPressed();
              },
              icon: Icon(icon!),
              label: Text(
                label,
                style: TextStyle(fontWeight: fontWeight, fontSize: fontSize),
              )),
        );
      }
    }
  }
}

class PIPResponsiveTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final dynamic width;
  final dynamic height;
  final FontWeight? fontWeight;
  final double? fontSize;
  final IconData? icon;
  final Color? color;
  const PIPResponsiveTextButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.height,
      this.color,
      this.fontWeight,
      this.fontSize,
      this.icon,
      this.width});
  @override
  Widget build(BuildContext context) {
    return icon == null
        ? TextButton(
            style: TextButton.styleFrom(minimumSize: Size(width, height)),
            onPressed: () {
              onPressed();
            },
            child: Text(
              label,
              style: TextStyle(
                  fontWeight: fontWeight, fontSize: fontSize, color: color),
            ))
        : TextButton.icon(
            onPressed: () {
              onPressed();
            },
            icon: Icon(icon),
            label: Text(
              label,
              style: TextStyle(
                  fontWeight: fontWeight, fontSize: fontSize, color: color),
            ));
  }
}

class PIPChangeThemeButton extends ConsumerWidget {
  const PIPChangeThemeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    return IconButton(
      onPressed: () {
        // Using notifier to update theme
        ref.read(appThemeProvider.notifier).setDarkMode(!theme.isDarkMode);
      },
      icon: theme.isDarkMode
          ? const Icon(Icons.light_mode_outlined)
          : const Icon(Icons.dark_mode_outlined),
    );
  }
}

class AccountPopUpMenuButton extends ConsumerWidget {
  final AppUser user;
  final bool isDarkMode;

  const AccountPopUpMenuButton({
    super.key,
    required this.user,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signOutState = ref.watch(signOutStateProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: PIPPopUpMenu(
        icon: const Icon(Icons.account_circle_outlined),
        content: [
          _buildHeader(context),
          _buildUserAvatar(user),
          _buildGreeting(context, user),
          _buildManageAccountButton(context),
          _buildLogoutButton(context, ref, signOutState),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Text(
              user.email,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildUserAvatar(AppUser user) {
    return Center(
      child: CircleAvatar(
        radius: 25,
        child: Text('${user.firstName[0]}${user.lastName[0]}'),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, AppUser user) {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.globalGreetingOne(user.firstName),
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildManageAccountButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        minimumSize: Size(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height / 15,
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const AccountOverview(),
        ));
      },
      child: Text(
        AppLocalizations.of(context)!.settingsPageManageAccountButtonLabel,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildLogoutButton(
      BuildContext context, WidgetRef ref, AsyncValue<void> signOutState) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        minimumSize: Size(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height / 15,
        ),
      ),
      icon: const Icon(Icons.logout),
      onPressed: () async {
        Navigator.of(context).pop();
        await ref.read(signOutStateProvider.notifier).signOut();
      },
      label: Text(
        AppLocalizations.of(context)!.globalLogoutButtonLabel,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: TextButton(
            onPressed: () =>
                UrlService.launchWebUrl('https://printinprogress.net/legal'),
            child: Text(
              AppLocalizations.of(context)!.globalPrivacyPolicyLabel,
              style: const TextStyle(fontSize: 8.7),
            ),
          ),
        ),
        const Text('\u2981', style: TextStyle(fontSize: 8)),
        Expanded(
          child: TextButton(
            onPressed: () =>
                UrlService.launchWebUrl('https://printinprogress.net/legal'),
            child: Text(
              AppLocalizations.of(context)!.globalToSLabel,
              style: const TextStyle(fontSize: 8.7),
            ),
          ),
        ),
      ],
    );
  }
}

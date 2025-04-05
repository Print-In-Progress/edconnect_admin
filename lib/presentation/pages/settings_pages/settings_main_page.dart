import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons.dart';
import 'package:edconnect_admin/presentation/pages/settings_pages/submit_registration_update.dart';
import 'package:edconnect_admin/presentation/pages/settings_pages/settings_change_name_page.dart';
import 'package:edconnect_admin/presentation/pages/settings_pages/settings_change_email.dart';
import 'package:edconnect_admin/presentation/pages/settings_pages/settings_update_password_page.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountOverview extends ConsumerStatefulWidget {
  const AccountOverview({super.key});

  @override
  ConsumerState<AccountOverview> createState() => _AccountOverviewState();
}

class _AccountOverviewState extends ConsumerState<AccountOverview> {
  final _reauthenticatePasswordController = TextEditingController();

  bool reauthenticatePasswordVisible = false;

  @override
  void dispose() {
    _reauthenticatePasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);

    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [theme.primaryColor, theme.secondaryColor],
        ),
      ),
      padding: const EdgeInsets.all(8.0),
      child: SafeArea(
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: true,
                floating: true,
                snap: true,
                forceMaterialTransparency: true,
                actionsIconTheme: const IconThemeData(color: Colors.white),
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(
                  AppLocalizations.of(context)!.navSettings,
                  style: const TextStyle(color: Colors.white),
                ),
              )
            ];
          },
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Name and Profile Picture
//                SizedBox(
//                    width: MediaQuery.of(context).size.width < 700
//                        ? MediaQuery.of(context).size.width
//                        : MediaQuery.of(context).size.width / 2,
//                    child: Card(
//                      child: Column(
//                        mainAxisSize: MainAxisSize.min,
//                        children: [],
//                      ),
//                    )),
                SizedBox(
                  width: MediaQuery.of(context).size.width < 700
                      ? MediaQuery.of(context).size.width
                      : MediaQuery.of(context).size.width / 2,
                  child: Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            AppLocalizations.of(context)!.settingsManageAccount,
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),

                        // Change Name Button
                        TextButton.icon(
                          icon: Icon(
                            Icons.abc,
                            size: 30,
                            color: theme.isDarkMode
                                ? Colors.white
                                : theme.primaryColor,
                          ),
                          label: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .settingsChangeName,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: theme.isDarkMode
                                      ? Colors.white
                                      : theme.primaryColor,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: theme.isDarkMode
                                    ? Colors.white
                                    : theme.primaryColor,
                              )
                            ],
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    settings: const RouteSettings(
                                        name: 'Settings Change Name Page'),
                                    builder: (context) {
                                      return const AccountName();
                                    }));
                          },
                        ),

                        // Change Email Button
                        TextButton.icon(
                          icon: Icon(
                            Icons.email_outlined,
                            size: 30,
                            color: theme.isDarkMode
                                ? Colors.white
                                : theme.primaryColor,
                          ),
                          label: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.globalEmailLabel,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: theme.isDarkMode
                                      ? Colors.white
                                      : theme.primaryColor,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: theme.isDarkMode
                                    ? Colors.white
                                    : theme.primaryColor,
                              )
                            ],
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    settings: const RouteSettings(
                                        name: 'Settings Change Email Screen'),
                                    builder: (context) {
                                      return const ChangeEmail();
                                    }));
                          },
                        ),

                        // Change Password Button
                        TextButton.icon(
                          icon: Icon(
                            Icons.password,
                            size: 30,
                            color: theme.isDarkMode
                                ? Colors.white
                                : theme.primaryColor,
                          ),
                          label: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .settingsChangePassword,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: theme.isDarkMode
                                      ? Colors.white
                                      : theme.primaryColor,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: theme.isDarkMode
                                    ? Colors.white
                                    : theme.primaryColor,
                              )
                            ],
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    settings: const RouteSettings(
                                        name:
                                            'Settings Change Password Screen'),
                                    builder: (context) {
                                      return const AccountPassword();
                                    }));
                          },
                        ),

                        // Resubmit Registration Information Button
                        TextButton.icon(
                          icon: Icon(
                            Icons.app_registration,
                            size: 30,
                            color: theme.isDarkMode
                                ? Colors.white
                                : theme.primaryColor,
                          ),
                          label: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  // Resubmit Questionnaire
                                  AppLocalizations.of(context)!
                                      .settingsUpdateRegistrationQuestionaire,
                                  style: TextStyle(
                                    fontSize: 17,
                                    overflow: TextOverflow.ellipsis,
                                    color: theme.isDarkMode
                                        ? Colors.white
                                        : theme.primaryColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: theme.isDarkMode
                                    ? Colors.white
                                    : theme.primaryColor,
                              )
                            ],
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  settings: const RouteSettings(
                                      name: 'resubmitRegInfo'),
                                  builder: (context) {
                                    return const SubmitRegistrationUpdate();
                                  },
                                ));
                          },
                        ),

                        // Change Organization Button
/*
                        TextButton.icon(
                          icon: Icon(
                            Icons.download,
                            size: 30,
                            color: theme.isDarkMode
                                ? Colors.white
                                : theme.primaryColor,
                          ),
                          label: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Konto-Info anfragen',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: theme.isDarkMode
                                      ? Colors.white
                                      : theme.primaryColor,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: theme.isDarkMode
                                    ? Colors.white
                                    : Color(int.parse(theme
                                        .primaryColor)),
                              )
                            ],
                          ),
                          onPressed: () {
                            if (connectivity) {
                            } else {
                              errorMessage(context, 'No Internet Connection');
                              return;
                            }
                          },
                        ),
*/
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  width: MediaQuery.of(context).size.width < 700
                      ? MediaQuery.of(context).size.width
                      : MediaQuery.of(context).size.width / 2,
                  child: Card(
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          AppLocalizations.of(context)!.settingsAppearance,
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                      SwitchListTile(
                        title: Text(
                          AppLocalizations.of(context)!.settingsDarkMode,
                          style: TextStyle(
                            color: theme.isDarkMode
                                ? Colors.white
                                : theme.primaryColor,
                          ),
                        ),
                        value: theme.isDarkMode,
                        onChanged: (value) {
                          ref
                              .read(appThemeProvider.notifier)
                              .setDarkMode(!theme.isDarkMode);
                        },
                        secondary: theme.isDarkMode
                            ? const Icon(Icons.light_mode_outlined)
                            : const Icon(Icons.dark_mode_outlined),
                      )
                    ]),
                  ),
                ),

                // Logout Button
                SizedBox(
                  width: MediaQuery.of(context).size.width < 700
                      ? MediaQuery.of(context).size.width
                      : MediaQuery.of(context).size.width / 2,
                  child: Card(
                    child: Column(
                      children: [
                        TextButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.globalLogout,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 17),
                              ),
                              const Icon(Icons.logout, color: Colors.red)
                            ],
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await ref
                                .read(signOutStateProvider.notifier)
                                .signOut();
                          },
                        ),

                        // Delete Button
                        TextButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .globalDeleteAccount,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 17),
                              ),
                              const Icon(Icons.delete, color: Colors.red)
                            ],
                          ),
                          onPressed: () async {
                            await showDialog(
                                context: context,
                                builder: ((BuildContext context) {
                                  return _buildDeleteAccountDialog(context);
                                }));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildDeleteAccountDialog(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        final deleteAccountState = ref.watch(deleteAccountProvider);

        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.globalReauthenticate),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.settingsDeleteDialogBody),
              TextFormField(
                obscureText: !reauthenticatePasswordVisible,
                controller: _reauthenticatePasswordController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(
                      reauthenticatePasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() {
                      reauthenticatePasswordVisible =
                          !reauthenticatePasswordVisible;
                    }),
                  ),
                  hintText: AppLocalizations.of(context)!.authPasswordLabel,
                ),
              ),
            ],
          ),
          actions: [
            const PIPCancelButton(),
            if (deleteAccountState.isLoading)
              const CircularProgressIndicator()
            else
              PIPDialogTextButton(
                label: 'Ok',
                onPressed: () async {
                  try {
                    await ref
                        .read(deleteAccountProvider.notifier)
                        .deleteAccount(_reauthenticatePasswordController.text);

                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Pop settings page
                    successMessage(
                      context,
                      AppLocalizations.of(context)!.successDefault,
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    errorMessage(context, e.toString());
                  }
                },
              ),
          ],
        );
      },
    );
  }
}

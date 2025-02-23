import 'package:edconnect_admin/components/buttons.dart';
import 'package:edconnect_admin/components/snackbars.dart';
import 'package:edconnect_admin/models/providers/themeprovider.dart';
import 'package:edconnect_admin/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountName extends ConsumerStatefulWidget {
  const AccountName({super.key});

  @override
  ConsumerState<AccountName> createState() => _AccountNameState();
}

class _AccountNameState extends ConsumerState<AccountName> {
  final _userFirstNameController = TextEditingController();
  final _userLastNameController = TextEditingController();

  final _authService = AuthService();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _userFirstNameController.dispose();
    _userLastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentColorSchemeProvider = ref.watch(colorAndLogoProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              currentColorSchemeProvider.primaryColor,
              currentColorSchemeProvider.secondaryColor
            ],
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
                      AppLocalizations.of(context)!.globalSettingsLabel,
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                ];
              },
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width < 700
                          ? MediaQuery.of(context).size.width
                          : MediaQuery.of(context).size.width / 2,
                      child: Card(
                          child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextFormField(
                                controller: _userFirstNameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .globalEmptyFormFieldErrorLabel;
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  hintText: AppLocalizations.of(context)!
                                      .globalFirstNameTextFieldHintText,
                                  prefixIcon: const Icon(Icons.person),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextFormField(
                                controller: _userLastNameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .globalEmptyFormFieldErrorLabel;
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  hintText: AppLocalizations.of(context)!
                                      .globalLastNameTextFieldHintText,
                                  prefixIcon: const Icon(Icons.person),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: PIPResponsiveRaisedButton(
                                  fontWeight: FontWeight.w600,
                                  label: AppLocalizations.of(context)!
                                      .globalSaveChangesButtonLabel,
                                  onPressed: () async {
                                    try {
                                      if (_formKey.currentState!.validate()) {
                                        await _authService.updateUserName(
                                          firstName:
                                              _userFirstNameController.text,
                                          lastName:
                                              _userLastNameController.text,
                                        );

                                        if (!context.mounted) return;
                                        successMessage(
                                          context,
                                          AppLocalizations.of(context)!
                                              .settingsPageSuccessOnPersonalDataChangedSnackbarContent,
                                        );
                                        Navigator.of(context).pop();
                                      }
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      errorMessage(
                                        context,
                                        AppLocalizations.of(context)!
                                            .globalUnexpectedErrorLabel,
                                      );
                                    }
                                  },
                                  width: MediaQuery.of(context).size.width),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      )),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}

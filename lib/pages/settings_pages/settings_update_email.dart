import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edconnect_admin/components/buttons.dart';
import 'package:edconnect_admin/components/snackbars.dart';
import 'package:edconnect_admin/constants/database_constants.dart';
import 'package:edconnect_admin/models/providers/themeprovider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangeEmail extends ConsumerStatefulWidget {
  const ChangeEmail({super.key});

  @override
  ConsumerState<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends ConsumerState<ChangeEmail> {
  final _userEmailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextFormField(
                                controller: _userEmailController,
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
                                      .globalEmailLabel,
                                  prefixIcon: const Icon(Icons.person),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
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
                                        await FirebaseAuth.instance.currentUser!
                                            .verifyBeforeUpdateEmail(
                                                _userEmailController.text)
                                            .then((value) {
                                          successMessage(
                                              context,
                                              AppLocalizations.of(context)!
                                                  .settingsPageSuccessOnPersonalDataChangedSnackbarContent);
                                        });

                                        final uid = FirebaseAuth
                                            .instance.currentUser!.uid;
                                        var userCollection = FirebaseFirestore
                                            .instance
                                            .collection(
                                                customerSpecificCollectionUsers);
                                        await userCollection.doc(uid).update({
                                          'email': _userEmailController.text
                                        });
                                      }
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      errorMessage(
                                          context,
                                          AppLocalizations.of(context)!
                                              .globalUnexpectedErrorLabel);
                                    }
                                  },
                                  width: MediaQuery.of(context).size.width),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ));
  }
}

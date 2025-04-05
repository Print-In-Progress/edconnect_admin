import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/widgets/common/forms.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/snackbars.dart';
import 'package:edconnect_admin/presentation/widgets/registration_card_builder.dart';
import 'package:flutter/material.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubmitRegistrationUpdate extends ConsumerStatefulWidget {
  const SubmitRegistrationUpdate({super.key});

  @override
  ConsumerState<SubmitRegistrationUpdate> createState() =>
      _SubmitRegistrationUpdateState();
}

class _SubmitRegistrationUpdateState
    extends ConsumerState<SubmitRegistrationUpdate> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _validateFirstNameField = false;
  bool _validateLastNameField = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  String _getErrorMessage(String error) {
    switch (error) {
      case 'SignatureMissing':
        return AppLocalizations.of(context)!.validationSignatureMissing;
      case 'QuestionMissing':
        return AppLocalizations.of(context)!.validationRequired;
      default:
        return AppLocalizations.of(context)!.errorUnexpected;
    }
  }

  bool _validateForm() {
    setState(() {
      _validateFirstNameField = _firstNameController.text.isEmpty;
      _validateLastNameField = _lastNameController.text.isEmpty;
    });

    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      errorMessage(context, 'First and Last Name cannot be empty');
      return false;
    }
    return true;
  }

  void _resetForm() {
    _firstNameController.clear();
    _lastNameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final registrationFields = ref.watch(registrationFieldsProvider);
    final updateState = ref.watch(registrationUpdateProvider);

    ref.listen<AsyncValue<void>>(registrationUpdateProvider, (_, state) {
      state.whenOrNull(
        error: (error, _) {
          final message = error.toString().contains('Exception:')
              ? _getErrorMessage(error.toString().split('Exception: ')[1])
              : _getErrorMessage(error.toString());
          errorMessage(context, message);
        },
        data: (_) {
          _resetForm();
          successMessage(
            context,
            AppLocalizations.of(context)!.successProfileUpdated,
          );
          Navigator.of(context).pop();
        },
      );
    });

    return Scaffold(
        backgroundColor: Colors.transparent,
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
                    'Registration Information',
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ];
            },
            body: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width < 700
                      ? MediaQuery.of(context).size.width
                      : MediaQuery.of(context).size.width / 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PIPOutlinedBorderInputForm(
                                    validate: _validateFirstNameField,
                                    width: MediaQuery.of(context).size.width,
                                    controller: _firstNameController,
                                    label: AppLocalizations.of(context)!
                                        .globalFirstNameTextFieldHintText,
                                    icon: Icons.person,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  PIPOutlinedBorderInputForm(
                                    validate: _validateLastNameField,
                                    width: MediaQuery.of(context).size.width,
                                    controller: _lastNameController,
                                    label: AppLocalizations.of(context)!
                                        .globalLastNameTextFieldHintText,
                                    icon: Icons.person,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          registrationFields.when(
                            loading: () => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                5,
                                (index) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: 20.0,
                                            color: Colors.grey[300],
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            width: double.infinity,
                                            height: 20.0,
                                            color: Colors.grey[300],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            error: (error, _) => Text('Error: $error'),
                            data: (fields) {
                              if (fields.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: fields.length,
                                    itemBuilder: (context, index) =>
                                        buildRegistrationCard(
                                            context, fields, index),
                                  ),
                                  if (!updateState.isLoading)
                                    FilledButton(
                                      onPressed: () async {
                                        if (_validateForm()) {
                                          await ref
                                              .read(registrationUpdateProvider
                                                  .notifier)
                                              .submitUpdate(
                                                fields,
                                                _firstNameController.text,
                                                _lastNameController.text,
                                              );
                                        }
                                      },
                                      child: Text(AppLocalizations.of(context)!
                                          .globalSubmit),
                                    ),
                                  if (updateState.isLoading)
                                    const CircularProgressIndicator(),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )),
        ));
  }
}

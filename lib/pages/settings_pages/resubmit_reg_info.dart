import 'package:edconnect_admin/components/forms.dart';
import 'package:edconnect_admin/components/snackbars.dart';
import 'package:edconnect_admin/models/providers/themeprovider.dart';
import 'package:edconnect_admin/models/registration_fields.dart';
import 'package:edconnect_admin/services/data_service.dart';
import 'package:edconnect_admin/utils/registration_card_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResubmitRegInfo extends ConsumerStatefulWidget {
  const ResubmitRegInfo({super.key});

  @override
  ConsumerState<ResubmitRegInfo> createState() => _ResubmitRegInfoState();
}

class _ResubmitRegInfoState extends ConsumerState<ResubmitRegInfo> {
  late Future<List<BaseRegistrationField>> _futureDocs;
  bool _isDataFetched = false;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _validateFirstNameField = false;
  bool _validateLastNameField = false;

  bool _isSubmitting = false;
  double _progress = 0.0;
  String _progressLabel = '';

  final _dataService = DataService();

  Future<void> _handleSubmit(
      List<BaseRegistrationField> registrationFields) async {
    if (!_validateForm()) return;

    setState(() => _isSubmitting = true);

    try {
      await _dataService.submitRegistrationUpdate(
        registrationFields: registrationFields,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        onProgress: (progress, label) {
          setState(() {
            _progress = progress;
            _progressLabel = label;
          });
        },
      );

      if (!mounted) return;
      _resetForm();
      successMessage(context, 'Form Submitted Successfully');
    } catch (e) {
      if (!mounted) return;
      errorMessage(context, _getErrorMessage(e.toString()));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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

  String _getErrorMessage(String error) {
    switch (error) {
      case 'SignatureMissing':
        return 'Please sign all required fields';
      case 'QuestionMissing':
        return 'Please fill out all required fields';
      default:
        return 'An unexpected error occurred';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataFetched) {
      _futureDocs = DataService().fetchRegistrationFieldData();
      _isDataFetched = true;
    }
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
                          FutureBuilder<List<BaseRegistrationField>>(
                              future: _futureDocs,
                              builder: ((context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      5,
                                      (index) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2),
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
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (snapshot.hasData) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListView.builder(
                                          itemBuilder: (context, index) {
                                            return buildRegistrationCard(
                                                context, snapshot.data!, index);
                                          },
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: snapshot.data!.length),
                                      if (!_isSubmitting)
                                        FilledButton(
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .globalSubmitButtonLabel),
                                          onPressed: () =>
                                              _handleSubmit(snapshot.data!),
                                        ),
                                      if (_isSubmitting)
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            LinearProgressIndicator(
                                                value: _progress),
                                            Text(_progressLabel),
                                          ],
                                        )
                                    ],
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              })),
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

import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/validation/validators/text_field_validator.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/section_card_settings.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/loading_progress.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/app_bar.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
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
  final _formKey = GlobalKey<FormState>();

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

  void _resetForm() {
    _firstNameController.clear();
    _lastNameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final registrationFields = ref.watch(registrationFieldsProvider);
    final updateState = ref.watch(registrationUpdateProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen<AsyncValue<void>>(registrationUpdateProvider, (_, state) {
      state.whenOrNull(
        error: (error, _) {
          final message = error.toString().contains('Exception:')
              ? _getErrorMessage(error.toString().split('Exception: ')[1])
              : _getErrorMessage(error.toString());
          Toaster.error(
            context,
            AppLocalizations.of(context)!.errorUnexpected,
            description: message,
          );
        },
        data: (_) {
          _resetForm();
          Toaster.success(
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
                BaseAppBar(
                  title: l10n.navSettings,
                  showLeading: true,
                  forceMaterialTransparency: true,
                  showDivider: false,
                  foregroundColor: Foundations.colors.surfaceActive,
                  floating: true,
                ).asSliverAppBar(context, ref),
              ];
            },
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Form(
                      key: _formKey,
                      child: buildSectionCard(
                        l10n.settingsUpdateRegistrationQuestionaire,
                        theme.isDarkMode,
                        children: [
                          SizedBox(height: Foundations.spacing.lg),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: BaseInput(
                                  controller: _firstNameController,
                                  label: l10n.globalFirstNameTextFieldHintText,
                                  hint: l10n.globalFirstNameTextFieldHintText,
                                  leadingIcon: Icons.person_outline,
                                  isRequired: true,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  type: TextFieldType.name,
                                  variant: InputVariant.default_,
                                  size: InputSize.medium,
                                ),
                              ),
                              SizedBox(width: Foundations.spacing.lg),
                              Expanded(
                                child: BaseInput(
                                  controller: _lastNameController,
                                  label: l10n.globalLastNameTextFieldHintText,
                                  hint: l10n.globalLastNameTextFieldHintText,
                                  leadingIcon: Icons.person_outline,
                                  isRequired: true,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  type: TextFieldType.name,
                                  variant: InputVariant.default_,
                                  size: InputSize.medium,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Foundations.spacing.lg),
                          registrationFields.when(
                            loading: () => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                5,
                                (index) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: BaseCard(
                                    variant: CardVariant.elevated,
                                    margin: EdgeInsets.zero,
                                    padding:
                                        EdgeInsets.all(Foundations.spacing.lg),
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
                            error: (error, _) => Text('Error: $error'),
                            data: (fields) {
                              if (fields.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: fields.length,
                                    separatorBuilder: (_, __) => SizedBox(
                                        height: Foundations.spacing.md),
                                    itemBuilder: (context, index) =>
                                        buildRegistrationCard(context, fields,
                                            index, theme.isDarkMode),
                                  ),
                                  SizedBox(height: Foundations.spacing.lg),
                                  BaseButton(
                                      label: l10n.globalSubmit,
                                      variant: ButtonVariant.filled,
                                      size: ButtonSize.large,
                                      fullWidth: true,
                                      isLoading: updateState.isLoading,
                                      onPressed: () async {
                                        if (!_formKey.currentState!
                                            .validate()) {
                                          return;
                                        }
                                        await ref
                                            .read(registrationUpdateProvider
                                                .notifier)
                                            .submitUpdate(
                                              fields,
                                              _firstNameController.text,
                                              _lastNameController.text,
                                            );
                                      }),
                                  if (updateState.isLoading)
                                    LoadingProgress(
                                      message:
                                          'Updating registration information...',
                                      steps: const [
                                        'Validating information',
                                        'Processing registration form',
                                        'Finalizing update'
                                      ],
                                      currentStep: ref
                                          .watch(registrationUpdateProvider
                                              .notifier)
                                          .currentStep,
                                    )
                                ],
                              );
                            },
                          ),
                        ],
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

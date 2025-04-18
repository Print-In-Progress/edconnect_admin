import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/validation/validators/text_field_validator.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/section_card_settings.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/app_bar.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountName extends ConsumerStatefulWidget {
  const AccountName({super.key});

  @override
  ConsumerState<AccountName> createState() => _AccountNameState();
}

class _AccountNameState extends ConsumerState<AccountName> {
  final _userFirstNameController = TextEditingController();
  final _userLastNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _userFirstNameController.dispose();
    _userLastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final changeNameState = ref.watch(changeNameProvider);
    final l10n = AppLocalizations.of(context)!;

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
                          l10n.settingsChangeName,
                          theme.isDarkMode,
                          children: [
                            SizedBox(height: Foundations.spacing.lg),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: BaseInput(
                                    controller: _userFirstNameController,
                                    label:
                                        l10n.globalFirstNameTextFieldHintText,
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
                                    controller: _userLastNameController,
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
                            BaseButton(
                              label: l10n.globalSave,
                              onPressed: () async {
                                try {
                                  if (_formKey.currentState!.validate()) {
                                    final user =
                                        ref.read(currentUserProvider).value;
                                    if (user == null) return;

                                    await ref
                                        .read(changeNameProvider.notifier)
                                        .changeName(
                                          user.id,
                                          _userFirstNameController.text,
                                          _userLastNameController.text,
                                        );

                                    if (!context.mounted) return;
                                    Toaster.success(
                                      context,
                                      AppLocalizations.of(context)!
                                          .successProfileUpdated,
                                    );

                                    Navigator.of(context).pop();
                                  }
                                } catch (e) {
                                  if (!context.mounted) return;
                                  Toaster.error(
                                    context,
                                    AppLocalizations.of(context)!
                                        .errorUnexpected,
                                  );
                                }
                              },
                              variant: ButtonVariant.filled,
                              size: ButtonSize.large,
                              isLoading: changeNameState.isLoading,
                              fullWidth: true,
                            ),
                            SizedBox(height: Foundations.spacing.lg),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}

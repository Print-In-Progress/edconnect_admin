import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/validation/validators/text_field_validator.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/section_card_settings.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/app_bar.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
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
  void dispose() {
    _userEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final updateEmailState = ref.watch(updateEmailProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen<AsyncValue<void>>(updateEmailProvider, (_, state) {
      state.whenOrNull(
        error: (error, _) {
          Toaster.error(
            context,
            AppLocalizations.of(context)!.errorUnexpected,
            description: error.toString(),
          );
        },
        data: (_) {
          Toaster.success(
            context,
            AppLocalizations.of(context)!.successEmailChanged,
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
                          l10n.settingsChangeEmail, theme.isDarkMode,
                          children: [
                            SizedBox(height: Foundations.spacing.lg),
                            BaseInput(
                              controller: _userEmailController,
                              label: l10n.globalEmailLabel,
                              hint: l10n.globalEmailLabel,
                              leadingIcon: Icons.email_outlined,
                              isRequired: true,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              type: TextFieldType.email,
                              keyboardType: TextInputType.emailAddress,
                              variant: InputVariant.default_,
                              size: InputSize.medium,
                            ),
                            SizedBox(height: Foundations.spacing.lg),
                            BaseButton(
                              label: l10n.globalSave,
                              variant: ButtonVariant.filled,
                              size: ButtonSize.large,
                              fullWidth: true,
                              isLoading: updateEmailState.isLoading,
                              onPressed: updateEmailState.isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        await ref
                                            .read(updateEmailProvider.notifier)
                                            .updateEmail(
                                                _userEmailController.text);
                                      }
                                    },
                            ),
                          ]),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ));
  }
}

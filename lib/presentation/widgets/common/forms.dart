import 'package:flutter/material.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';

class PIPOutlinedBorderInputForm extends StatelessWidget {
  final String label;
  final Iterable<String>? autofillHints;
  final IconData? icon;
  final dynamic width;
  final dynamic height;
  final bool? enabled;
  final bool validate;
  final TextEditingController controller;
  const PIPOutlinedBorderInputForm(
      {super.key,
      this.autofillHints,
      required this.label,
      this.icon,
      required this.validate,
      this.height,
      required this.width,
      required this.controller,
      this.enabled = true});
  @override
  Widget build(BuildContext context) {
    if (autofillHints != null) {
      if (height != null) {
        return SizedBox(
          width: width,
          height: height,
          child: TextFormField(
            autofillHints: autofillHints,
            enabled: enabled,
            controller: controller,
            decoration: InputDecoration(
              errorText: validate
                  ? AppLocalizations.of(context)!.validationRequired
                  : null,
              filled: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: label,
              prefixIcon: Icon(icon),
            ),
          ),
        );
      } else {
        return SizedBox(
          width: width,
          height: height,
          child: TextFormField(
            autofillHints: autofillHints,
            enabled: enabled,
            controller: controller,
            decoration: InputDecoration(
              errorText: validate
                  ? AppLocalizations.of(context)!.validationRequired
                  : null,
              filled: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: label,
              prefixIcon: Icon(icon),
            ),
          ),
        );
      }
    } else {
      if (height != null) {
        return SizedBox(
          width: width,
          height: height,
          child: TextFormField(
            enabled: enabled,
            controller: controller,
            decoration: InputDecoration(
              errorText: validate
                  ? AppLocalizations.of(context)!.validationRequired
                  : null,
              filled: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: label,
              prefixIcon: Icon(icon),
            ),
          ),
        );
      } else {
        return SizedBox(
          width: width,
          child: TextFormField(
            enabled: enabled,
            controller: controller,
            decoration: InputDecoration(
              errorText: validate
                  ? AppLocalizations.of(context)!.validationRequired
                  : null,
              filled: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: label,
              prefixIcon: Icon(icon),
            ),
          ),
        );
      }
    }
  }
}

class PIPPasswordForm extends StatelessWidget {
  final String label;
  final bool passwordVisible;
  final dynamic width;
  final dynamic height;
  final VoidCallback onPressed;
  final TextEditingController controller;
  const PIPPasswordForm(
      {super.key,
      required this.label,
      this.height,
      required this.width,
      required this.controller,
      required this.passwordVisible,
      required this.onPressed});
  @override
  Widget build(BuildContext context) {
    if (height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: TextField(
          autofillHints: const [AutofillHints.password],
          controller: controller,
          obscureText: !passwordVisible,
          decoration: InputDecoration(
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: label,
            prefixIcon: const Icon(Icons.key),
            suffixIcon: IconButton(
              icon: Icon(
                passwordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                onPressed();
              },
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: width,
        child: TextField(
          autofillHints: const [AutofillHints.password],
          controller: controller,
          obscureText: !passwordVisible,
          decoration: InputDecoration(
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: label,
            prefixIcon: const Icon(Icons.key),
            suffixIcon: IconButton(
              icon: Icon(
                passwordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                onPressed();
              },
            ),
          ),
        ),
      );
    }
  }
}

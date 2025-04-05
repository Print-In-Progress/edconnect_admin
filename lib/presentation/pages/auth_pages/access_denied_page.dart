import 'package:edconnect_admin/presentation/widgets/common/buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';

class AccessDeniedPage extends StatelessWidget {
  const AccessDeniedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: Card(
        elevation: 50,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  AppLocalizations.of(context)!.errorAccessDenied,
                  style: const TextStyle(color: Colors.red, fontSize: 50),
                ),
              ),
              Text(
                AppLocalizations.of(context)!.errorAccessDeniedMessage,
                style: const TextStyle(fontSize: 15),
              ),
              PIPResponsiveRaisedButton(
                  label: AppLocalizations.of(context)!.globalBackToLogin,
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  fontWeight: FontWeight.w600,
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.height / 15)
            ],
          ),
        ),
      ),
    ));
  }
}

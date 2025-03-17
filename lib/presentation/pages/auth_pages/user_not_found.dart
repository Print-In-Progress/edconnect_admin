import 'package:edconnect_admin/presentation/widgets/common/buttons.dart';
import 'package:edconnect_admin/services/url_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserNotFoundPage extends StatelessWidget {
  const UserNotFoundPage({super.key});

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
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  '404 - User Not Found',
                  style: TextStyle(color: Colors.red, fontSize: 50),
                ),
              ),
              Text(
                AppLocalizations.of(context)!.authPagesUserNotFoundErrorMessage,
                style: const TextStyle(fontSize: 15),
              ),
              PIPResponsiveRaisedButton(
                  label: AppLocalizations.of(context)!.globalBackToLoginLabel,
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  fontWeight: FontWeight.w600,
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.height / 15),
              const SizedBox(
                height: 5,
              ),
              PIPResponsiveRaisedButton(
                  label: 'Print In Progress Homepage',
                  onPressed: () =>
                      UrlService.launchWebUrl('https://printinprogress.com'),
                  fontWeight: FontWeight.w600,
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.height / 15),
            ],
          ),
        ),
      ),
    ));
  }
}

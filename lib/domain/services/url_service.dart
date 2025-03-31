import 'package:html_editor_enhanced/utils/shims/dart_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlService {
  static Future<void> launchWebUrl(String url, {VoidCallback? onError}) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {}
  }
}

import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

class FileSaver {
  static void saveTextFile(String text, String fileName) {
    if (!kIsWeb) return;

    final blob = html.Blob([utf8.encode(text)]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "$fileName.txt")
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
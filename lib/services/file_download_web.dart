import 'dart:html' as html;

Future<void> downloadFile({
  required String url,
  required String fileName,
  required String token,
}) async {
  html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
}

import 'package:url_launcher/url_launcher.dart';

Future<void> launchWhatsApp({
  required String phoneNumber,
  required String message,
}) async {
  final String encodedMessage = Uri.encodeComponent(message);

  final Uri url = Uri.parse('https://wa.me/$phoneNumber?text=$encodedMessage');

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('No se pudo abrir WhatsApp');
  }
}

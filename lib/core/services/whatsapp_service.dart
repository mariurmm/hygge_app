import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

@lazySingleton
class WhatsAppService {
  WhatsAppService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;
  String? _cachedPhone;

  Future<void> open(String message) async {
    final phone = await _fetchPhone();
    if (phone == null) return;

    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<String?> _fetchPhone() async {
    if (_cachedPhone != null) return _cachedPhone;
    try {
      final doc = await _firestore
          .collection('config')
          .doc('contacts')
          .get();
      _cachedPhone = doc.data()?['whatsAppPhone'] as String?;
      return _cachedPhone;
    } on Object {
      return null;
    }
  }
}
import '../models/certificate.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Сертификаты клиента (только чтение). Связка user↔клиент клуба — на бэкенде
/// по user_id/телефону, по всем клубам.
class CertificateService {
  final ApiService _api;
  final StorageService _storage;

  CertificateService(this._api, this._storage);

  Future<CertificatesResult> getCertificates() async {
    final token = await _storage.getToken();
    if (token == null) return CertificatesResult.empty();
    final response = await _api.get('/certificates', token);
    return CertificatesResult.fromJson(response);
  }
}

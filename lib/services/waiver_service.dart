import 'dart:convert';
import 'dart:typed_data';

import '../models/club_waiver.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Текст поправили, пока человек читал: сервер ответил 409.
class WaiverTextChanged implements Exception {
  WaiverTextChanged(this.waiver);

  /// Свежая редакция — её и показываем взамен прочитанной.
  final ClubWaiver waiver;
}

/// Отказ от ответственности: чтение текста и подпись.
class WaiverService {
  final ApiService _api;
  final StorageService _storage;

  WaiverService(this._api, this._storage);

  Future<ClubWaiver> load(int clubId) async {
    final token = await _storage.getToken();
    final response = await _api.get('/clubs/$clubId/waiver', token);
    return ClubWaiver.fromJson(response);
  }

  /// Отправить подпись. [signature] — байты PNG с холста.
  Future<DateTime> sign({
    required int clubId,
    required String fullName,
    required String textHash,
    required Uint8List signature,
  }) async {
    final token = await _storage.getToken();

    Map<String, dynamic> response;
    try {
      response = await _api.post(
        '/clubs/$clubId/waiver/sign',
        {
          'full_name': fullName,
          'text_hash': textHash,
          'signature': 'data:image/png;base64,${base64Encode(signature)}',
        },
        token,
      );
    } on ApiException catch (e) {
      // 409 — текст успели поправить. Тело ответа до нас не доходит,
      // поэтому свежую редакцию просто перечитываем.
      if (e.statusCode == 409) {
        throw WaiverTextChanged(await load(clubId));
      }
      rethrow;
    }

    return DateTime.tryParse(response['signed_at'] as String? ?? '')?.toLocal() ??
        DateTime.now();
  }
}

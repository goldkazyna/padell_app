import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = 'https://padel-p.kz/api/mobile';

  final http.Client _client;

  ApiService() : _client = http.Client();

  Map<String, String> _headers([String? token]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, [
    String? token,
  ]) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers(token),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Ошибка сети. Проверьте подключение к интернету.');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, [
    String? token,
  ]) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers(token),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Ошибка сети. Проверьте подключение к интернету.');
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, [
    Map<String, dynamic>? body,
    String? token,
  ]) async {
    try {
      final request = http.Request('DELETE', Uri.parse('$baseUrl$endpoint'));
      request.headers.addAll(_headers(token));
      if (body != null) {
        request.body = jsonEncode(body);
      }
      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Ошибка сети. Проверьте подключение к интернету.');
    }
  }

  Future<Map<String, dynamic>> get(String endpoint, [String? token]) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers(token),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Ошибка сети. Проверьте подключение к интернету.');
    }
  }

  Future<Map<String, dynamic>> multipartPost(
    String endpoint,
    Map<String, String> fields,
    String? filePath,
    String fileField, [
    String? token,
  ]) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      request.fields.addAll(fields);
      if (filePath != null) {
        MediaType? contentType;
        final lowerPath = filePath.toLowerCase();
        if (lowerPath.endsWith('.webp')) {
          contentType = MediaType('image', 'webp');
        } else if (lowerPath.endsWith('.jpg') || lowerPath.endsWith('.jpeg')) {
          contentType = MediaType('image', 'jpeg');
        } else if (lowerPath.endsWith('.png')) {
          contentType = MediaType('image', 'png');
        }
        final file = await http.MultipartFile.fromPath(
          fileField,
          filePath,
          contentType: contentType,
        );
        request.files.add(file);
      }
      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Ошибка сети. Проверьте подключение к интернету.');
    }
  }

  /// Multipart POST с несколькими файлами под одним полем (`photos[]`).
  Future<Map<String, dynamic>> multipartPostMulti(
    String endpoint,
    Map<String, String> fields,
    List<String> filePaths,
    String fileField, [
    String? token,
  ]) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      request.fields.addAll(fields);
      for (final path in filePaths) {
        MediaType? contentType;
        final lower = path.toLowerCase();
        if (lower.endsWith('.webp')) {
          contentType = MediaType('image', 'webp');
        } else if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
          contentType = MediaType('image', 'jpeg');
        } else if (lower.endsWith('.png')) {
          contentType = MediaType('image', 'png');
        } else if (lower.endsWith('.pdf')) {
          contentType = MediaType('application', 'pdf');
        }
        request.files.add(await http.MultipartFile.fromPath(
          fileField,
          path,
          contentType: contentType,
        ));
      }
      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Ошибка сети. Проверьте подключение к интернету.');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body['message'] as String? ?? 'Произошла ошибка';
    throw ApiException(message, response.statusCode);
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;

class OllamaException implements Exception {
  OllamaException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Минимальный клиент Ollama `/api/chat`.
class OllamaClient {
  OllamaClient({
    this.baseUrl = 'http://127.0.0.1:11434',
    this.model = 'llama3.2',
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String baseUrl;
  final String model;
  final http.Client _http;

  Future<bool> isReachable() async {
    try {
      final uri = Uri.parse('$baseUrl/api/tags');
      final response = await _http.get(uri).timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<String> chat({
    required String system,
    required String user,
  }) async {
    final uri = Uri.parse('$baseUrl/api/chat');
    late final http.Response response;
    try {
      response = await _http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': model,
              'stream': false,
              'messages': [
                {'role': 'system', 'content': system},
                {'role': 'user', 'content': user},
              ],
              'options': {
                'temperature': 0.4,
                'num_predict': 180,
              },
            }),
          )
          .timeout(const Duration(seconds: 60));
    } catch (_) {
      throw OllamaException(
        'Нет связи с Ollama. Проверьте, что сервис запущен и URL верный.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OllamaException(
        'Ollama ответила кодом ${response.statusCode}.',
      );
    }

    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic>) {
      throw OllamaException('Некорректный ответ Ollama.');
    }
    final message = json['message'];
    if (message is Map && message['content'] is String) {
      final content = (message['content'] as String).trim();
      if (content.isNotEmpty) return content;
    }
    throw OllamaException('Пустой ответ модели.');
  }

  void close() => _http.close();
}

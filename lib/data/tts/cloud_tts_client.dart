import 'dart:convert';

import 'package:http/http.dart' as http;

/// OpenAI-compatible neural TTS (`/audio/speech`).
class CloudTtsClient {
  CloudTtsClient({
    required this.apiKey,
    this.baseUrl = defaultBaseUrl,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  static const defaultBaseUrl = 'https://api.openai.com/v1';

  final String apiKey;
  final String baseUrl;
  final http.Client _http;

  bool get isConfigured => apiKey.trim().isNotEmpty;

  Future<List<int>> synthesize({
    required String text,
    required String cloudVoiceId,
    String model = 'tts-1',
  }) async {
    if (!isConfigured) {
      throw StateError('TTS API key is empty');
    }

    final uri = Uri.parse('$baseUrl/audio/speech');
    final response = await _http
        .post(
          uri,
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': model,
            'voice': cloudVoiceId,
            'input': text,
            'response_format': 'mp3',
          }),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Cloud TTS ${response.statusCode}: ${response.body}',
      );
    }
    return response.bodyBytes;
  }

  void close() => _http.close();
}

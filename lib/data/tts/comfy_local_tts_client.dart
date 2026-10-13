import 'dart:convert';

import 'package:http/http.dart' as http;

/// Local ComfyUI Chatterbox TTS (no cloud).
///
/// Expects a running ComfyUI with `ComfyUI_Fill-ChatterBox` and
/// `input/goblin_voice.mp3` as the clone reference.
class ComfyLocalTtsClient {
  ComfyLocalTtsClient({
    this.baseUrl = defaultBaseUrl,
    this.referenceAudio = defaultReferenceAudio,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  static const defaultBaseUrl = 'http://127.0.0.1:8188';
  static const defaultReferenceAudio = 'goblin_voice.mp3';

  final String baseUrl;
  final String referenceAudio;
  final http.Client _http;

  Uri get _root => Uri.parse(baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl);

  Future<bool> isReachable() async {
    try {
      final response = await _http
          .get(_root.replace(path: '/system_stats'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<int>> synthesize({
    required String text,
    String? language,
    double exaggeration = 0.5,
    double cfgWeight = 0.5,
    double temperature = 0.8,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('text is empty');
    }

    final lang = language ?? detectLanguage(trimmed);
    final workflow = _buildWorkflow(
      text: trimmed,
      language: lang,
      exaggeration: exaggeration,
      cfgWeight: cfgWeight,
      temperature: temperature,
    );

    final promptId = await _submit(workflow);
    final audioMeta = await _waitForAudio(promptId);
    return _download(audioMeta);
  }

  static String detectLanguage(String text) {
    final letters = text.replaceAll(RegExp(r'[^A-Za-zА-Яа-яЁё]'), '');
    if (letters.isEmpty) return 'Russian (ru)';
    final cyrillic =
        letters.split('').where((c) => RegExp(r'[А-Яа-яЁё]').hasMatch(c)).length;
    return cyrillic >= (letters.length / 2) ? 'Russian (ru)' : 'English (en)';
  }

  Map<String, dynamic> _buildWorkflow({
    required String text,
    required String language,
    required double exaggeration,
    required double cfgWeight,
    required double temperature,
  }) {
    return {
      '1': {
        'class_type': 'LoadAudio',
        'inputs': {'audio': referenceAudio},
      },
      '2': {
        'class_type': 'FL_ChatterboxMultilingualTTS',
        'inputs': {
          'text': text,
          'language': language,
          'exaggeration': exaggeration,
          'cfg_weight': cfgWeight,
          'temperature': temperature,
          'repetition_penalty': 2.0,
          'min_p': 0.05,
          'top_p': 1.0,
          'seed': DateTime.now().millisecondsSinceEpoch % 2147483647,
          'use_cpu': false,
          'keep_model_loaded': true,
          'audio_prompt': ['1', 0],
        },
      },
      '3': {
        'class_type': 'SaveAudio',
        'inputs': {
          'audio': ['2', 0],
          'filename_prefix': 'audio/sleeping_goblin',
        },
      },
    };
  }

  Future<String> _submit(Map<String, dynamic> workflow) async {
    final response = await _http
        .post(
          _root.replace(path: '/prompt'),
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode({
            'prompt': workflow,
            'client_id': 'sleeping-radio',
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('ComfyUI prompt ${response.statusCode}: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final errors = body['node_errors'];
    if (errors is Map && errors.isNotEmpty) {
      throw Exception('ComfyUI node_errors: $errors');
    }
    final promptId = body['prompt_id'] as String?;
    if (promptId == null || promptId.isEmpty) {
      throw Exception('ComfyUI returned no prompt_id');
    }
    return promptId;
  }

  Future<_ComfyAudioRef> _waitForAudio(String promptId) async {
    final deadline = DateTime.now().add(const Duration(minutes: 6));
    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      final response = await _http
          .get(_root.replace(path: '/history/$promptId'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) continue;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final item = body[promptId];
      if (item is! Map<String, dynamic>) continue;

      final status = item['status'];
      if (status is Map && status['status_str'] == 'error') {
        throw Exception('ComfyUI job failed: $status');
      }

      final outputs = item['outputs'];
      if (outputs is! Map<String, dynamic>) continue;
      final node3 = outputs['3'];
      if (node3 is! Map<String, dynamic>) continue;
      final audio = node3['audio'];
      if (audio is! List || audio.isEmpty) continue;
      final first = audio.first;
      if (first is! Map<String, dynamic>) continue;
      return _ComfyAudioRef(
        filename: first['filename'] as String,
        subfolder: (first['subfolder'] as String?) ?? '',
        type: (first['type'] as String?) ?? 'output',
      );
    }
    throw Exception('ComfyUI TTS timed out for prompt $promptId');
  }

  Future<List<int>> _download(_ComfyAudioRef ref) async {
    final response = await _http
        .get(
          _root.replace(
            path: '/view',
            queryParameters: {
              'filename': ref.filename,
              'subfolder': ref.subfolder,
              'type': ref.type,
            },
          ),
        )
        .timeout(const Duration(seconds: 60));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('ComfyUI download ${response.statusCode}');
    }
    if (response.bodyBytes.isEmpty) {
      throw Exception('ComfyUI returned empty audio');
    }
    return response.bodyBytes;
  }

  void close() => _http.close();
}

class _ComfyAudioRef {
  const _ComfyAudioRef({
    required this.filename,
    required this.subfolder,
    required this.type,
  });

  final String filename;
  final String subfolder;
  final String type;
}

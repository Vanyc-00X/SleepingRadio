import '../../domain/enums/comment_length.dart';
import '../settings/stage8_prefs.dart';
import 'ollama_client.dart';

/// Локальный LLM-комментарий с тихим fallback на шаблон.
class LocalCommentService {
  LocalCommentService(this._prefs);

  final Stage8Prefs _prefs;

  Future<String?> tryCalmComment({
    required String sourceText,
    required CommentLength length,
  }) async {
    if (!_prefs.ollamaEnabled || length == CommentLength.off) {
      return null;
    }

    final client = OllamaClient(
      baseUrl: _prefs.ollamaUrl,
      model: _prefs.ollamaModel,
    );

    try {
      final sentences = length == CommentLength.short ? '1–2' : '2–3';
      final system =
          'Ты спокойный вечерний голос для приложения перед сном. '
          'Пиши по-русски, мягко, без кликбейта, без политики-агитации, '
          'без паники и без выдуманных фактов. '
          'Не повторяй всю статью. Только короткий комментарий на $sentences предложения. '
          'Без заголовков и маркеров.';
      final user =
          'Сделай короткий спокойный комментарий к тексту:\n\n'
          '${sourceText.length > 2500 ? sourceText.substring(0, 2500) : sourceText}';

      final comment = await client.chat(system: system, user: user);
      return comment;
    } on OllamaException {
      return null;
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }
}

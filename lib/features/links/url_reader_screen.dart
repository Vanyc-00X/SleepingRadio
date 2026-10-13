import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/web/url_extractor.dart';
import '../../domain/enums/url_read_mode.dart';
import '../player/player_controller.dart';

class UrlReaderScreen extends ConsumerStatefulWidget {
  const UrlReaderScreen({super.key, this.initialUrl, this.initialText});

  final String? initialUrl;
  final String? initialText;

  @override
  ConsumerState<UrlReaderScreen> createState() => _UrlReaderScreenState();
}

class _UrlReaderScreenState extends ConsumerState<UrlReaderScreen> {
  late final TextEditingController _urlController;
  late final TextEditingController _textController;
  var _mode = UrlReadMode.readWithComment;
  var _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final shared = widget.initialText?.trim();
    final initialUrl = widget.initialUrl?.trim();
    if (initialUrl != null && initialUrl.isNotEmpty) {
      _urlController = TextEditingController(text: initialUrl);
      _textController = TextEditingController();
    } else if (shared != null && _looksLikeUrl(shared)) {
      _urlController = TextEditingController(text: shared);
      _textController = TextEditingController();
    } else {
      _urlController = TextEditingController();
      _textController = TextEditingController(text: shared ?? '');
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _textController.dispose();
    super.dispose();
  }

  bool _looksLikeUrl(String value) {
    final v = value.trim();
    return v.startsWith('http://') ||
        v.startsWith('https://') ||
        RegExp(r'^[\w.-]+\.[a-zA-Z]{2,}(/\S*)?$').hasMatch(v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ссылка')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'Вставьте URL или текст — спокойный голос прочитает.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'URL',
              hintText: 'https://…',
              filled: true,
              fillColor: AppColors.nightElevated,
              suffixIcon: IconButton(
                tooltip: 'Вставить',
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  final text = data?.text?.trim();
                  if (text != null && text.isNotEmpty) {
                    _urlController.text = text;
                  }
                },
                icon: const Icon(Icons.content_paste),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            minLines: 3,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Или текст (share / вставка)',
              hintText: 'Если прислали текст без ссылки',
              filled: true,
              fillColor: AppColors.nightElevated,
            ),
          ),
          const SizedBox(height: 20),
          Text('Режим', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...UrlReadMode.values.map((mode) {
            final selected = _mode == mode;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: AppColors.nightElevated,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  title: Text(mode.labelRu),
                  subtitle: Text(mode.hintRu),
                  trailing: selected
                      ? const Icon(Icons.check_circle, color: AppColors.amber)
                      : const Icon(
                          Icons.circle_outlined,
                          color: AppColors.mist,
                        ),
                  onTap: () => setState(() => _mode = mode),
                ),
              ),
            );
          }),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loading ? null : _submit,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.headphones),
            label: Text(_loading ? 'Готовим…' : 'Слушать'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final url = _urlController.text.trim();
    final plain = _textController.text.trim();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (url.isNotEmpty) {
        final settings = await ref.read(settingsProvider.future);
        final episode = await ref.read(linksRepositoryProvider).importAndCompose(
          url: url,
          mode: _mode,
          commentLength: settings.commentLength,
        );
        final script = episode.script?.trim() ?? '';
        if (script.isEmpty) {
          throw UrlExtractException('Не удалось собрать текст для чтения.');
        }
        await ref.read(playerSessionProvider.notifier).playNarration(
          episodeId: episode.id,
          title: episode.title,
          subtitle: 'Ссылка',
          script: script,
        );
      } else if (plain.isNotEmpty) {
        if (plain.length < 40) {
          throw UrlExtractException('Текст слишком короткий для озвучки.');
        }
        final id = const Uuid().v4();
        final title = plain.length > 48
            ? '${plain.substring(0, 48).trim()}…'
            : plain;
        await ref.read(playerSessionProvider.notifier).playNarration(
          episodeId: id,
          title: title,
          subtitle: 'Текст',
          script: plain,
        );
      } else {
        throw UrlExtractException('Вставьте ссылку или текст.');
      }

      if (!mounted) return;
      context.go('/player');
    } on UrlExtractException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Не удалось подготовить озвучку.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

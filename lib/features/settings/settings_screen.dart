import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/llm/ollama_client.dart';
import '../../data/settings/settings_backup.dart';
import '../../data/settings/stage8_prefs.dart';
import '../../data/settings/voice_presets.dart';
import '../../data/tts/comfy_local_tts_client.dart';
import '../../data/tts/on_device_tts_models.dart';
import '../../data/tts/tts_voice.dart';
import '../../domain/enums/comment_length.dart';
import '../../domain/models/user_settings.dart';
import '../player/player_controller.dart';
import 'stage8_controller.dart';
import 'voice_preview.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _apiKeyController;
  late final TextEditingController _comfyUrlController;
  late final TextEditingController _ollamaUrlController;
  late final TextEditingController _ollamaModelController;
  var _obscureKey = true;
  var _keyLoaded = false;
  var _comfyChecking = false;
  String? _comfyStatus;
  var _ollamaChecking = false;
  String? _ollamaStatus;
  var _modelDownloading = false;
  double _modelProgress = 0;
  String? _modelStatus;
  VoicePreview? _voicePreview;
  var _previewing = false;
  String? _previewStatus;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _comfyUrlController = TextEditingController();
    _ollamaUrlController = TextEditingController();
    _ollamaModelController = TextEditingController();
  }

  @override
  void dispose() {
    _voicePreview?.dispose();
    _apiKeyController.dispose();
    _comfyUrlController.dispose();
    _ollamaUrlController.dispose();
    _ollamaModelController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_keyLoaded) return;
    _keyLoaded = true;
    final store = ref.read(ttsApiKeyStoreProvider);
    final stage8 = ref.read(stage8StateProvider);
    _apiKeyController.text = store.loadKey() ?? '';
    _comfyUrlController.text = store.loadComfyUrl();
    _ollamaUrlController.text = stage8.ollamaUrl;
    _ollamaModelController.text = stage8.ollamaModel;
  }

  Future<void> _applyVoicePreset(VoicePreset preset) async {
    final store = ref.read(voicePresetsStoreProvider);
    await store.setActivePresetId(preset.id);
    await store.setInterChunkPauseMs(preset.pauseMs);
    await ref.read(settingsProvider.notifier).updateSettings(
          (s) => s.copyWith(
            speechRate: preset.speechRate,
            pitch: preset.pitch,
            voiceId: preset.voiceId ?? s.voiceId,
          ),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Пресет «${preset.labelRu}» применён')),
    );
    setState(() {});
  }

  Future<void> _previewVoice(UserSettings settings) async {
    final voice = TtsVoices.byId(settings.voiceId);
    final messenger = ScaffoldMessenger.of(context);
    if (voice.isLocalComfy) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Превью клона — после настройки Comfy на плеере'),
        ),
      );
      return;
    }
    _voicePreview ??= VoicePreview(
      onDevice: ref.read(onDeviceTtsEngineProvider),
    );
    setState(() {
      _previewing = true;
      _previewStatus = 'Готовлю семпл…';
    });
    final handler = ref.read(audioHandlerProvider);
    final wasPlaying = handler.session.isPlaying;
    try {
      if (wasPlaying) await handler.pause();
      await _voicePreview!.play(
        voice: voice,
        speechRate: settings.speechRate,
        pitch: settings.pitch,
        onStatus: (status) {
          if (!mounted) return;
          setState(() => _previewStatus = status);
        },
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Превью: $error')),
      );
    } finally {
      if (wasPlaying) {
        try {
          await handler.play();
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _previewing = false;
          _previewStatus = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncSettings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: asyncSettings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Не удалось загрузить настройки: $error'),
        ),
        data: (settings) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _SectionTitle('Голос'),
            Text(
              'Рекомендуем Дениса — самый чистый offline Piper для чтения. '
              'Голос можно менять и во время озвучки на экране плеера.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mist,
                  ),
            ),
            const SizedBox(height: 8),
            ...TtsVoices.all.map((voice) {
              final selected = settings.voiceId == voice.id;
              return ListTile(
                title: Row(
                  children: [
                    Flexible(child: Text(voice.labelRu)),
                    if (voice.badgeRu != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          voice.badgeRu!,
                          style: const TextStyle(
                            color: AppColors.amber,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(voice.descriptionRu),
                trailing: selected
                    ? const Icon(Icons.check_circle, color: AppColors.amber)
                    : const Icon(Icons.circle_outlined, color: AppColors.mist),
                onTap: () async {
                  await ref.read(settingsProvider.notifier).updateSettings(
                        (s) => s.copyWith(voiceId: voice.id),
                      );
                  if (voice.isOnDevice) {
                    await _downloadOnDeviceModel(voice.id);
                  }
                },
              );
            }),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: _previewing || _modelDownloading
                        ? null
                        : () => _previewVoice(settings),
                    icon: Icon(
                      _previewing ? Icons.hourglass_top : Icons.play_circle_outline,
                    ),
                    label: Text(
                      _previewing
                          ? (_previewStatus ?? 'Превью…')
                          : 'Прослушать выбранный голос',
                    ),
                  ),
                  if (_previewStatus != null && _previewing)
                    Text(
                      _previewStatus!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mist,
                          ),
                    ),
                ],
              ),
            ),
            if (TtsVoices.byId(settings.voiceId).isOnDevice ||
                _modelDownloading) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_modelDownloading) ...[
                      LinearProgressIndicator(value: _modelProgress),
                      const SizedBox(height: 6),
                    ],
                    if (_modelStatus != null)
                      Text(
                        _modelStatus!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mist,
                        ),
                      ),
                    TextButton.icon(
                      onPressed: _modelDownloading
                          ? null
                          : () => _downloadOnDeviceModel(
                                settings.voiceId == TtsVoices.goblinLocal.id
                                    ? OnDeviceTtsModels.recommended.id
                                    : settings.voiceId,
                              ),
                      icon: const Icon(Icons.download),
                      label: Text(
                        settings.voiceId == OnDeviceTtsModels.recommended.id
                            ? 'Скачать Дениса (~64 МБ)'
                            : 'Скачать offline-модель',
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _modelDownloading
                          ? null
                          : () => _downloadOnDeviceModel(
                                OnDeviceTtsModels.recommended.id,
                              ),
                      icon: const Icon(Icons.star_outline),
                      label: const Text('Загрузить лучшую (Денис)'),
                    ),
                  ],
                ),
              ),
            ],
            if (settings.voiceId == TtsVoices.goblinLocal.id) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: TextField(
                  controller: _comfyUrlController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'ComfyUI URL',
                    hintText: 'http://192.168.0.10:8188',
                    helperText:
                        'На телефоне укажите IP ПК в Wi‑Fi. ComfyUI должен быть запущен.',
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await ref
                            .read(ttsApiKeyStoreProvider)
                            .saveComfyUrl(_comfyUrlController.text);
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Адрес ComfyUI сохранён'),
                          ),
                        );
                      },
                      child: const Text('Сохранить URL'),
                    ),
                    TextButton(
                      onPressed: _comfyChecking
                          ? null
                          : () async {
                              setState(() {
                                _comfyChecking = true;
                                _comfyStatus = null;
                              });
                              await ref
                                  .read(ttsApiKeyStoreProvider)
                                  .saveComfyUrl(_comfyUrlController.text);
                              final client = ComfyLocalTtsClient(
                                baseUrl: _comfyUrlController.text.trim().isEmpty
                                    ? ComfyLocalTtsClient.defaultBaseUrl
                                    : _comfyUrlController.text.trim(),
                              );
                              final ok = await client.isReachable();
                              client.close();
                              if (!mounted) return;
                              setState(() {
                                _comfyChecking = false;
                                _comfyStatus = ok
                                    ? 'ComfyUI доступен'
                                    : 'Нет связи с ComfyUI';
                              });
                            },
                      child: Text(
                        _comfyChecking ? 'Проверка…' : 'Проверить связь',
                      ),
                    ),
                  ],
                ),
              ),
              if (_comfyStatus != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 8),
                  child: Text(
                    _comfyStatus!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _comfyStatus!.contains('доступен')
                          ? AppColors.amber
                          : Colors.redAccent,
                    ),
                  ),
                ),
            ],
            const Divider(height: 32),
            _SectionTitle('Скорость чтения'),
            _LabeledSlider(
              value: settings.speechRate.clamp(
                AppConstants.speechRateMin,
                AppConstants.speechRateMax,
              ),
              min: AppConstants.speechRateMin,
              max: AppConstants.speechRateMax,
              label: '${settings.speechRate.toStringAsFixed(1)}×',
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateSettings(
                  (s) => s.copyWith(
                    speechRate: double.parse(value.toStringAsFixed(1)),
                  ),
                );
              },
            ),
            _SectionTitle('Высота тона'),
            _LabeledSlider(
              value: settings.pitch.clamp(
                AppConstants.pitchMin,
                AppConstants.pitchMax,
              ),
              min: AppConstants.pitchMin,
              max: AppConstants.pitchMax,
              label: settings.pitch.toStringAsFixed(2),
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateSettings(
                  (s) => s.copyWith(
                    pitch: double.parse(value.toStringAsFixed(2)),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _SectionTitle('Пресеты Piper / голоса'),
            Text(
              'Скорость, высота и пауза между фразами. Профили Ирина и Руслан — в списке голосов выше.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mist,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final preset in BuiltInVoicePresets.all)
                  ActionChip(
                    label: Text(preset.labelRu),
                    onPressed: () => _applyVoicePreset(preset),
                  ),
              ],
            ),
            Builder(
              builder: (context) {
                final store = ref.watch(voicePresetsStoreProvider);
                final pauseMs = store.interChunkPauseMs;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('Пауза между фразами: $pauseMs мс'),
                    Slider(
                      value: pauseMs.toDouble(),
                      min: 0,
                      max: 1200,
                      divisions: 24,
                      label: '$pauseMs',
                      onChanged: (v) async {
                        await store.setInterChunkPauseMs(v.round());
                        setState(() {});
                      },
                    ),
                  ],
                );
              },
            ),
            const Divider(height: 32),
            _SectionTitle('Новости'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.rss_feed, color: AppColors.amber),
              title: const Text('RSS-ленты и приоритет'),
              subtitle: const Text('Встроенные + свои URL, порядок в сводке'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/feeds'),
            ),
            const Divider(height: 32),
            _SectionTitle('Комментарии ИИ'),
            ...CommentLength.values.map((length) {
              final selected = settings.commentLength == length;
              return ListTile(
                title: Text(length.labelRu),
                trailing: selected
                    ? const Icon(Icons.check_circle, color: AppColors.amber)
                    : const Icon(Icons.circle_outlined, color: AppColors.mist),
                onTap: () {
                  ref
                      .read(settingsProvider.notifier)
                      .updateSettings((s) => s.copyWith(commentLength: length));
                },
              );
            }),
            const Divider(height: 32),
            _SectionTitle('Таймер сна по умолчанию'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.timerPresetsMinutes.map((minutes) {
                final selected = settings.defaultTimerMinutes == minutes;
                return ChoiceChip(
                  label: Text('$minutes мин'),
                  selected: selected,
                  selectedColor: AppColors.amber.withValues(alpha: 0.25),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.amber : AppColors.moon,
                  ),
                  onSelected: (_) {
                    ref.read(settingsProvider.notifier).updateSettings(
                      (s) => s.copyWith(defaultTimerMinutes: minutes),
                    );
                  },
                );
              }).toList(),
            ),
            const Divider(height: 32),
            _SectionTitle('Книги'),
            SwitchListTile(
              value: settings.booksReadOnly,
              activeThumbColor: AppColors.amber,
              title: const Text('Только чтение'),
              subtitle: const Text(
                'Без комментариев ИИ к книгам (по умолчанию включено)',
              ),
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .updateSettings((s) => s.copyWith(booksReadOnly: value));
              },
            ),
            const Divider(height: 32),
            _SectionTitle('Кэш и сеть'),
            SwitchListTile(
              value: settings.useCloudAi,
              activeThumbColor: AppColors.amber,
              title: const Text('Облачный TTS / LLM'),
              subtitle: const Text(
                'Без ключа — автоматический переход на системный TTS.',
              ),
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .updateSettings((s) => s.copyWith(useCloudAi: value));
              },
            ),
            ListTile(
              title: const Text('Что уходит в сеть'),
              subtitle: const Text('Прозрачность для облачного режима'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/privacy'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextField(
                controller: _apiKeyController,
                obscureText: _obscureKey,
                decoration: InputDecoration(
                  labelText: 'TTS API key (OpenAI-compatible)',
                  hintText: 'sk-... или пусто для локального TTS',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscureKey = !_obscureKey),
                    icon: Icon(
                      _obscureKey ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await ref
                      .read(ttsApiKeyStoreProvider)
                      .saveKey(_apiKeyController.text);
                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Ключ сохранён локально')),
                  );
                },
                child: const Text('Сохранить ключ'),
              ),
            ),
            ListTile(
              title: const Text('Лимит офлайн-кэша'),
              subtitle: Text('${settings.cacheLimitGb} ГБ'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: settings.cacheLimitGb <= 1
                        ? null
                        : () => _bumpCache(settings, -1),
                    icon: const Icon(Icons.remove),
                  ),
                  IconButton(
                    onPressed: settings.cacheLimitGb >= 5
                        ? null
                        : () => _bumpCache(settings, 1),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Очистить кэш озвучки'),
              subtitle: const Text('Удалит синтезированные аудио-чанки'),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                await ref.read(audioCacheStoreProvider).clear();
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('Кэш озвучки очищен')),
                );
              },
            ),
            const Divider(height: 32),
            _SectionTitle('Атмосфера и локальный ИИ'),
            Builder(
              builder: (context) {
                final stage8 = ref.watch(stage8StateProvider);
                return Column(
                  children: [
                    SwitchListTile(
                      value: stage8.ambientEnabled,
                      activeThumbColor: AppColors.amber,
                      title: const Text('Ambient под голосом'),
                      subtitle: const Text(
                        'Тихий ночной фон во время чтения',
                      ),
                      onChanged: (value) {
                        ref
                            .read(stage8StateProvider.notifier)
                            .setAmbientEnabled(value);
                      },
                    ),
                    if (stage8.ambientEnabled)
                      _LabeledSlider(
                        value: stage8.ambientVolume,
                        min: 0.0,
                        max: 0.4,
                        label: stage8.ambientVolume.toStringAsFixed(2),
                        onChanged: (value) {
                          ref
                              .read(stage8StateProvider.notifier)
                              .setAmbientVolume(value);
                        },
                      ),
                    ListTile(
                      title: const Text('Громкость голоса'),
                      subtitle: Text(
                        stage8.voiceVolume.toStringAsFixed(2),
                      ),
                    ),
                    _LabeledSlider(
                      value: stage8.voiceVolume,
                      min: 0.15,
                      max: 1.0,
                      label: stage8.voiceVolume.toStringAsFixed(2),
                      onChanged: (value) {
                        ref
                            .read(stage8StateProvider.notifier)
                            .setVoiceVolume(value);
                      },
                    ),
                    SwitchListTile(
                      value: stage8.autoAdvanceChapters,
                      activeThumbColor: AppColors.amber,
                      title: const Text('Автопереход к следующей главе'),
                      subtitle: const Text(
                        'В конце главы — следующая; выкл. = стоп',
                      ),
                      onChanged: (value) {
                        ref
                            .read(stage8StateProvider.notifier)
                            .setAutoAdvanceChapters(value);
                      },
                    ),
                    SwitchListTile(
                      value: stage8.ollamaEnabled,
                      activeThumbColor: AppColors.amber,
                      title: const Text('Ollama для комментариев'),
                      subtitle: const Text(
                        'Локальный LLM; при ошибке — шаблонный комментарий',
                      ),
                      onChanged: (value) {
                        ref
                            .read(stage8StateProvider.notifier)
                            .setOllamaEnabled(value);
                      },
                    ),
                    if (stage8.ollamaEnabled) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: TextField(
                          controller: _ollamaUrlController,
                          keyboardType: TextInputType.url,
                          decoration: const InputDecoration(
                            labelText: 'Ollama URL',
                            hintText: 'http://127.0.0.1:11434',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: TextField(
                          controller: _ollamaModelController,
                          decoration: const InputDecoration(
                            labelText: 'Модель',
                            hintText: 'llama3.2',
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          children: [
                            TextButton(
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                await ref
                                    .read(stage8StateProvider.notifier)
                                    .setOllamaUrl(_ollamaUrlController.text);
                                await ref
                                    .read(stage8StateProvider.notifier)
                                    .setOllamaModel(
                                      _ollamaModelController.text,
                                    );
                                if (!mounted) return;
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Ollama настройки сохранены'),
                                  ),
                                );
                              },
                              child: const Text('Сохранить'),
                            ),
                            TextButton(
                              onPressed: _ollamaChecking
                                  ? null
                                  : () async {
                                      setState(() {
                                        _ollamaChecking = true;
                                        _ollamaStatus = null;
                                      });
                                      await ref
                                          .read(stage8StateProvider.notifier)
                                          .setOllamaUrl(
                                            _ollamaUrlController.text,
                                          );
                                      final client = OllamaClient(
                                        baseUrl: _ollamaUrlController.text
                                                .trim()
                                                .isEmpty
                                            ? Stage8Prefs.defaultOllamaUrl
                                            : _ollamaUrlController.text.trim(),
                                        model:
                                            _ollamaModelController.text.trim(),
                                      );
                                      final ok = await client.isReachable();
                                      client.close();
                                      if (!mounted) return;
                                      setState(() {
                                        _ollamaChecking = false;
                                        _ollamaStatus = ok
                                            ? 'Ollama доступна'
                                            : 'Нет связи с Ollama';
                                      });
                                    },
                              child: Text(
                                _ollamaChecking ? 'Проверка…' : 'Проверить',
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_ollamaStatus != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 8),
                          child: Text(
                            _ollamaStatus!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: _ollamaStatus!.contains('доступ')
                                      ? AppColors.amber
                                      : Colors.redAccent,
                                ),
                          ),
                        ),
                    ],
                  ],
                );
              },
            ),
            const Divider(height: 32),
            _SectionTitle('Резервная копия'),
            ListTile(
              title: const Text('Экспорт настроек'),
              subtitle: const Text('Локальный JSON без облачного аккаунта'),
              onTap: _exportBackup,
            ),
            ListTile(
              title: const Text('Импорт настроек'),
              subtitle: const Text('Восстановить из JSON-файла'),
              onTap: _importBackup,
            ),
            const SizedBox(height: 16),
            Text(
              'Offline TTS: Piper. Ambient: тихий фон. '
              'Ollama: локальные комментарии. '
              'Синхронизация аккаунта — через экспорт/импорт профиля.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mist,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportBackup() async {
    final messenger = ScaffoldMessenger.of(context);
    final settings = await ref.read(settingsProvider.future);
    final backup = SettingsBackup(
      settings: settings,
      stage8: ref.read(stage8PrefsProvider),
      keyStore: ref.read(ttsApiKeyStoreProvider),
    );
    final json = backup.toPrettyJson();
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      p.join(
        dir.path,
        'sleeping_radio_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      ),
    );
    await file.writeAsString(json, flush: true);
    await Clipboard.setData(ClipboardData(text: json));
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text('Экспорт сохранён и скопирован:\n${file.path}')),
    );
  }

  Future<void> _importBackup() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      if (files.isEmpty) return;
      final path = files.single.path;
      if (path == null) return;
      final raw = await File(path).readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Некорректный файл настроек');
      }
      final settings = SettingsBackup.parseSettings(decoded);
      await ref.read(settingsProvider.notifier).updateSettings((_) => settings);
      final stage8 = SettingsBackup.parseStage8(decoded);
      if (stage8 != null) {
        await ref.read(stage8StateProvider.notifier).applyMap(stage8);
        _ollamaUrlController.text =
            ref.read(stage8StateProvider).ollamaUrl;
        _ollamaModelController.text =
            ref.read(stage8StateProvider).ollamaModel;
      }
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Настройки восстановлены')),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Не удалось импортировать: $error')),
      );
    }
  }

  Future<void> _downloadOnDeviceModel(String voiceId) async {
    final model = OnDeviceTtsModels.byId(voiceId);
    if (model == null) return;
    setState(() {
      _modelDownloading = true;
      _modelProgress = 0;
      _modelStatus = 'Подготовка…';
    });
    try {
      await ref.read(onDeviceTtsEngineProvider).ensureModel(
        model,
        onProgress: (progress, status) {
          if (!mounted) return;
          setState(() {
            _modelProgress = progress;
            _modelStatus = status;
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _modelDownloading = false;
        _modelStatus = '${model.labelRu}: модель готова';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${model.labelRu} скачана')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _modelDownloading = false;
        _modelStatus = 'Ошибка: $error';
      });
    }
  }

  void _bumpCache(UserSettings settings, int delta) {
    ref.read(settingsProvider.notifier).updateSettings(
      (s) => s.copyWith(cacheLimitGb: settings.cacheLimitGb + delta),
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final String label;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Text(min.toStringAsFixed(1)),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: 8,
              label: label,
              activeColor: AppColors.amber,
              onChanged: onChanged,
            ),
          ),
          Text(max.toStringAsFixed(1)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.amber,
        ),
      ),
    );
  }
}

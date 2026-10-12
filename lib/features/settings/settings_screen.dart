import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/enums/comment_length.dart';
import '../../domain/models/user_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            ...AppConstants.mvpVoices.map((voice) {
              final selected = settings.voiceId == voice.id;
              return ListTile(
                title: Text(voice.label),
                trailing: selected
                    ? const Icon(Icons.check_circle, color: AppColors.amber)
                    : const Icon(Icons.circle_outlined, color: AppColors.mist),
                onTap: () {
                  ref
                      .read(settingsProvider.notifier)
                      .updateSettings((s) => s.copyWith(voiceId: voice.id));
                },
              );
            }),
            const Divider(height: 32),
            _SectionTitle('Скорость чтения'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Text('${AppConstants.speechRateMin}×'),
                  Expanded(
                    child: Slider(
                      value: settings.speechRate.clamp(
                        AppConstants.speechRateMin,
                        AppConstants.speechRateMax,
                      ),
                      min: AppConstants.speechRateMin,
                      max: AppConstants.speechRateMax,
                      divisions: 7,
                      label: '${settings.speechRate.toStringAsFixed(1)}×',
                      activeColor: AppColors.amber,
                      onChanged: (value) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateSettings(
                              (s) => s.copyWith(
                                speechRate: double.parse(
                                  value.toStringAsFixed(1),
                                ),
                              ),
                            );
                      },
                    ),
                  ),
                  Text('${AppConstants.speechRateMax}×'),
                ],
              ),
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
                    ref
                        .read(settingsProvider.notifier)
                        .updateSettings(
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
                'Локальные модели — этап 8. Книги целиком в облако не уходят.',
              ),
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .updateSettings((s) => s.copyWith(useCloudAi: value));
              },
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
                        : () => _bumpCache(ref, settings, -1),
                    icon: const Icon(Icons.remove),
                  ),
                  IconButton(
                    onPressed: settings.cacheLimitGb >= 5
                        ? null
                        : () => _bumpCache(ref, settings, 1),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Настройки сохраняются локально. Озвучка книг сейчас — системный TTS (этап 3 — облачные голоса).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mist,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _bumpCache(WidgetRef ref, UserSettings settings, int delta) {
    ref
        .read(settingsProvider.notifier)
        .updateSettings(
          (s) => s.copyWith(cacheLimitGb: settings.cacheLimitGb + delta),
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

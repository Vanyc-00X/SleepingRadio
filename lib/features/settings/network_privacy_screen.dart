import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/tts/network_privacy.dart';
import '../../data/tts/tts_api_key_store.dart';

class NetworkPrivacyScreen extends ConsumerWidget {
  const NetworkPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudOn =
        ref.watch(settingsProvider).asData?.value.useCloudAi ?? true;
    final stored = ref.watch(ttsApiKeyStoreProvider).loadKey();
    final hasKey =
        (stored ?? CloudTtsDefaults.envApiKey).trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Что уходит в сеть')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text(
            cloudOn
                ? (hasKey
                      ? 'Облачный TTS включён: фрагменты текста могут отправляться провайдеру.'
                      : 'Облачный TTS включён, но ключ не задан — используется локальный fallback.')
                : 'Облачный TTS выключен — озвучка остаётся на устройстве.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ...NetworkPrivacyCatalog.items.map((item) {
            final active = item.whenEnabled ? cloudOn : true;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: AppColors.nightElevated,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(item.detail),
                  ),
                  trailing: Icon(
                    active ? Icons.cloud_outlined : Icons.phone_android,
                    color: active ? AppColors.amber : AppColors.mist,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          Text(
            'Книги целиком в облако не загружаются. API-ключ хранится только локально.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.mist,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/playback_session.dart';
import '../player/player_controller.dart';

/// Компактная полоска над нижней навигацией.
class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(playerSessionProvider);
    final hasContent =
        session.title.isNotEmpty || session.state != PlayerState.idle;
    if (!hasContent && !session.isPlaying) {
      return const SizedBox.shrink();
    }

    final title = session.title.isEmpty ? 'Ночной демо-трек' : session.title;
    final subtitle = session.state == PlayerState.fadingOut
        ? 'Засыпание…'
        : session.hasKaraoke
            ? 'Текст на экране плеера'
            : (session.subtitle.isEmpty ? 'Сонное радио' : session.subtitle);

    return Material(
      color: AppColors.nightSoft,
      child: InkWell(
        onTap: () => context.go('/player'),
        child: SafeArea(
          top: false,
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.mist.withValues(alpha: 0.12),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    session.isPlaying
                        ? Icons.graphic_eq
                        : Icons.nightlight_round,
                    color: AppColors.amber,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mist,
                        ),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label: session.isPlaying ? 'Пауза' : 'Играть',
                  child: IconButton(
                    onPressed: () =>
                        ref.read(playerSessionProvider.notifier).toggle(),
                    icon: Icon(
                      session.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: AppColors.moon,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

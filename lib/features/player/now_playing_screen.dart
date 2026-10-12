import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/playback_session.dart';
import 'player_controller.dart';

class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(playerSessionProvider);
    final textTheme = Theme.of(context).textTheme;
    final remaining = session.timerRemaining;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.35),
            radius: 1.15,
            colors: [Color(0xFF1A2238), AppColors.night],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Сейчас играет', style: textTheme.titleMedium),
                ),
                const Spacer(flex: 2),
                _Artwork(fading: session.state == PlayerState.fadingOut),
                const SizedBox(height: 28),
                Text(
                  session.title.isEmpty ? 'Ночной демо-трек' : session.title,
                  style: textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  session.state == PlayerState.fadingOut
                      ? 'Засыпание… звук затихает'
                      : AppConstants.appNameShort,
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _PositionBar(session: session),
                const SizedBox(height: 12),
                _TimerBadge(
                  remaining: remaining,
                  playUntilEnd: session.playUntilEnd,
                ),
                const Spacer(),
                _TransportControls(session: session),
                const SizedBox(height: 20),
                _TimerPresets(session: session),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.fading});

  final bool fading;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: fading ? 0.55 : 1,
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.nightSoft,
          border: Border.all(
            color: AppColors.amber.withValues(alpha: 0.25),
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.nightlight_round,
          size: 72,
          color: AppColors.amber,
        ),
      ),
    );
  }
}

class _PositionBar extends ConsumerWidget {
  const _PositionBar({required this.session});

  final PlaybackSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = session.duration.inMilliseconds;
    final position = session.position.inMilliseconds.clamp(0, duration > 0 ? duration : 0);
    final max = duration > 0 ? duration.toDouble() : 1.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.amber,
            inactiveTrackColor: AppColors.mist.withValues(alpha: 0.2),
            thumbColor: AppColors.amber,
            overlayColor: AppColors.amber.withValues(alpha: 0.12),
            trackHeight: 3,
          ),
          child: Slider(
            value: position.toDouble().clamp(0, max),
            max: max,
            onChanged: duration <= 0
                ? null
                : (value) {
                    ref
                        .read(playerSessionProvider.notifier)
                        .seek(Duration(milliseconds: value.round()));
                  },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _format(session.position),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mist,
                ),
              ),
              Text(
                _format(session.duration),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mist,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimerBadge extends ConsumerWidget {
  const _TimerBadge({
    required this.remaining,
    required this.playUntilEnd,
  });

  final Duration? remaining;
  final bool playUntilEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = playUntilEnd
        ? 'До конца трека'
        : remaining == null
        ? 'Таймер выключен'
        : 'Таймер ${_format(remaining!)}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.amber,
          ),
        ),
        if (remaining != null) ...[
          const SizedBox(width: 12),
          TextButton(
            onPressed: () =>
                ref.read(playerSessionProvider.notifier).extendTimer(),
            child: const Text('+15 мин'),
          ),
        ],
      ],
    );
  }
}

class _TransportControls extends ConsumerWidget {
  const _TransportControls({required this.session});

  final PlaybackSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(playerSessionProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () =>
              notifier.seekBy(const Duration(seconds: -AppConstants.seekStepSeconds)),
          iconSize: 36,
          icon: const Icon(Icons.replay),
          color: AppColors.mist,
          tooltip: '-${AppConstants.seekStepSeconds} с',
        ),
        const SizedBox(width: 16),
        FilledButton(
          onPressed: notifier.toggle,
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
          ),
          child: Icon(
            session.isPlaying ? Icons.pause : Icons.play_arrow,
            size: 44,
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: () =>
              notifier.seekBy(const Duration(seconds: AppConstants.seekStepSeconds)),
          iconSize: 36,
          icon: const Icon(Icons.forward),
          color: AppColors.mist,
          tooltip: '+${AppConstants.seekStepSeconds} с',
        ),
      ],
    );
  }
}

class _TimerPresets extends ConsumerWidget {
  const _TimerPresets({required this.session});

  final PlaybackSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(playerSessionProvider.notifier);
    final preset = session.timerPresetMinutes;
    final isCustom = session.timerEndsAt != null &&
        !session.playUntilEnd &&
        preset != null &&
        !AppConstants.timerPresetsMinutes.contains(preset);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        ...AppConstants.timerPresetsMinutes.map((minutes) {
          final selected = !session.playUntilEnd && preset == minutes;
          return ChoiceChip(
            label: Text('$minutes'),
            selected: selected,
            selectedColor: AppColors.amber.withValues(alpha: 0.25),
            labelStyle: TextStyle(
              color: selected ? AppColors.amber : AppColors.moon,
            ),
            onSelected: (_) async {
              await notifier.setTimerMinutes(minutes);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Таймер: $minutes мин')),
                );
              }
            },
          );
        }),
        ChoiceChip(
          label: Text(isCustom ? '$presetм' : 'Своё'),
          selected: isCustom,
          selectedColor: AppColors.amber.withValues(alpha: 0.25),
          labelStyle: TextStyle(
            color: isCustom ? AppColors.amber : AppColors.moon,
          ),
          onSelected: (_) => _askCustomMinutes(context, ref),
        ),
        ChoiceChip(
          label: const Text('До конца'),
          selected: session.playUntilEnd,
          selectedColor: AppColors.amber.withValues(alpha: 0.25),
          labelStyle: TextStyle(
            color: session.playUntilEnd ? AppColors.amber : AppColors.moon,
          ),
          onSelected: (_) => notifier.setPlayUntilEnd(),
        ),
        if (session.timerEndsAt != null || session.playUntilEnd)
          ActionChip(
            label: const Text('Сброс'),
            onPressed: notifier.clearTimer,
          ),
      ],
    );
  }

  Future<void> _askCustomMinutes(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: '20');
    final minutes = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.nightElevated,
          title: const Text('Таймер, минуты'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Например, 20',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value == null || value <= 0) return;
                Navigator.pop(context, value.clamp(1, 24 * 60));
              },
              child: const Text('Старт'),
            ),
          ],
        );
      },
    );

    if (minutes != null) {
      await ref.read(playerSessionProvider.notifier).setTimerMinutes(minutes);
    }
  }
}

String _format(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (hours > 0) {
    return '$hours:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}

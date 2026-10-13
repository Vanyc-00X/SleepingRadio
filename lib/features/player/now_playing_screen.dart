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
                      : session.isBookMode
                      ? (session.subtitle.isNotEmpty
                            ? '${session.subtitle} · TTS'
                            : 'Озвучка главы')
                      : session.subtitle.isNotEmpty
                      ? session.subtitle
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

class _Artwork extends StatefulWidget {
  const _Artwork({required this.fading});

  final bool fading;

  @override
  State<_Artwork> createState() => _ArtworkState();
}

class _ArtworkState extends State<_Artwork>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: widget.fading ? 0.55 : 1,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_pulse.value);
          return Container(
            width: 188,
            height: 188,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color.lerp(
                    const Color(0xFF243049),
                    const Color(0xFF2C3854),
                    t,
                  )!,
                  AppColors.nightSoft,
                ],
              ),
              border: Border.all(
                color: AppColors.amber.withValues(alpha: 0.22 + t * 0.12),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.amber.withValues(alpha: 0.08 + t * 0.06),
                  blurRadius: 28 + t * 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          );
        },
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
        Semantics(
          button: true,
          label: 'Назад ${AppConstants.seekStepSeconds} секунд',
          child: IconButton(
            onPressed: () => notifier.seekBy(
              const Duration(seconds: -AppConstants.seekStepSeconds),
            ),
            iconSize: 38,
            icon: const Icon(Icons.replay_10),
            color: AppColors.mist,
          ),
        ),
        const SizedBox(width: 18),
        Semantics(
          button: true,
          label: session.isPlaying ? 'Пауза' : 'Играть',
          child: FilledButton(
            onPressed: notifier.toggle,
            style: FilledButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(26),
              elevation: 0,
            ),
            child: Icon(
              session.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 46,
            ),
          ),
        ),
        const SizedBox(width: 18),
        Semantics(
          button: true,
          label: 'Вперёд ${AppConstants.seekStepSeconds} секунд',
          child: IconButton(
            onPressed: () => notifier.seekBy(
              const Duration(seconds: AppConstants.seekStepSeconds),
            ),
            iconSize: 38,
            icon: const Icon(Icons.forward_10),
            color: AppColors.mist,
          ),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/tts/on_device_tts_models.dart';
import '../../data/tts/tts_voice.dart';
import '../../domain/models/playback_session.dart';
import 'player_controller.dart';

class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(playerSessionProvider);
    final textTheme = Theme.of(context).textTheme;
    final remaining = session.timerRemaining;
    final showKaraoke = session.hasKaraoke;

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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Сейчас играет', style: textTheme.titleMedium),
                    ),
                    if (session.state == PlayerState.fadingOut)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Затихание',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.amber,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  session.title.isEmpty ? 'Ночной демо-трек' : session.title,
                  style: textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  _subtitle(session),
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.mist),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: showKaraoke
                      ? _KaraokePanel(session: session)
                      : Center(
                          child: _Artwork(
                            fading: session.state == PlayerState.fadingOut,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                if (session.isBookMode) ...[
                  _LiveVoicePicker(session: session),
                  const SizedBox(height: 8),
                ],
                _PositionBar(session: session),
                const SizedBox(height: 4),
                _VolumeMixer(session: session),
                const SizedBox(height: 4),
                _TimerBadge(session: session, remaining: remaining),
                const SizedBox(height: 12),
                _TransportControls(session: session),
                const SizedBox(height: 14),
                _TimerPresets(session: session),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _subtitle(PlaybackSession session) {
    if (session.state == PlayerState.fadingOut) {
      return 'Скоро пауза — дослушиваю фразу';
    }
    if (session.isBookMode) {
      if (session.subtitle.isNotEmpty) {
        return '${session.subtitle} · озвучка';
      }
      return 'Озвучка';
    }
    if (session.subtitle.isNotEmpty) return session.subtitle;
    return AppConstants.appNameShort;
  }
}

class _KaraokePanel extends StatefulWidget {
  const _KaraokePanel({required this.session});

  final PlaybackSession session;

  @override
  State<_KaraokePanel> createState() => _KaraokePanelState();
}

class _KaraokePanelState extends State<_KaraokePanel> {
  final _controller = ScrollController();
  int _lastIndex = -1;

  @override
  void didUpdateWidget(covariant _KaraokePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final index = widget.session.currentChunkIndex;
    if (index != _lastIndex) {
      _lastIndex = index;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActive());
    }
  }

  void _scrollToActive() {
    if (!_controller.hasClients) return;
    final index = widget.session.currentChunkIndex.clamp(
      0,
      (widget.session.chunks.length - 1).clamp(0, 999999),
    );
    final target = (index * 56.0) - 80;
    _controller.animateTo(
      target.clamp(0.0, _controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chunks = widget.session.chunks;
    final active = widget.session.currentChunkIndex;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.nightSoft.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.12)),
      ),
      child: ListView.builder(
        controller: _controller,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        itemCount: chunks.length,
        itemBuilder: (context, index) {
          final isActive = index == active;
          final isPast = index < active;
          return AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  height: 1.45,
                  fontSize: isActive ? 20 : 16,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? AppColors.moon
                      : isPast
                          ? AppColors.mist.withValues(alpha: 0.45)
                          : AppColors.mist.withValues(alpha: 0.75),
                ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                chunks[index].trim(),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
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

class _LiveVoicePicker extends ConsumerStatefulWidget {
  const _LiveVoicePicker({required this.session});

  final PlaybackSession session;

  @override
  ConsumerState<_LiveVoicePicker> createState() => _LiveVoicePickerState();
}

class _LiveVoicePickerState extends ConsumerState<_LiveVoicePicker> {
  var _switching = false;
  String? _status;

  Future<void> _onSelect(TtsVoice voice) async {
    if (_switching || voice.id == widget.session.voiceId) return;
    setState(() {
      _switching = true;
      _status = voice.isOnDevice ? 'Готовлю ${voice.labelRu}…' : null;
    });
    try {
      if (voice.isOnDevice) {
        final model = OnDeviceTtsModels.byId(voice.id);
        if (model != null) {
          final engine = ref.read(onDeviceTtsEngineProvider);
          final ready = await engine.isReady(model);
          if (!ready) {
            setState(() => _status = 'Скачиваю ${voice.labelRu}…');
            await engine.ensureModel(
              model,
              onProgress: (p, s) {
                if (!mounted) return;
                setState(() => _status = s);
              },
            );
          }
        }
      }
      await ref.read(playerSessionProvider.notifier).switchVoice(voice.id);
      if (!mounted) return;
      setState(() => _status = 'Голос: ${voice.labelRu}');
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = 'Не удалось сменить голос');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Голос: $error')),
      );
    } finally {
      if (mounted) setState(() => _switching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: TtsVoices.liveSwitchable.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final voice = TtsVoices.liveSwitchable[index];
              final selected = voice.id == widget.session.voiceId;
              return ChoiceChip(
                label: Text(
                  voice.badgeRu != null
                      ? '${voice.labelRu} · ${voice.badgeRu}'
                      : voice.labelRu,
                ),
                selected: selected,
                selectedColor: AppColors.amber.withValues(alpha: 0.28),
                labelStyle: TextStyle(
                  color: selected ? AppColors.amber : AppColors.moon,
                  fontSize: 13,
                ),
                onSelected: _switching ? null : (_) => _onSelect(voice),
              );
            },
          ),
        ),
        if (_status != null) ...[
          const SizedBox(height: 6),
          Text(
            _status!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mist,
                ),
          ),
        ],
      ],
    );
  }
}

class _VolumeMixer extends ConsumerWidget {
  const _VolumeMixer({required this.session});

  final PlaybackSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(playerSessionProvider.notifier);
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.mist,
        );

    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 56, child: Text('Голос', style: textStyle)),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.amber,
                  inactiveTrackColor: AppColors.mist.withValues(alpha: 0.2),
                  thumbColor: AppColors.amber,
                  trackHeight: 2.5,
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(
                  value: session.voiceVolume.clamp(0.15, 1.0),
                  min: 0.15,
                  max: 1.0,
                  onChanged: notifier.setVoiceVolume,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(width: 56, child: Text('Фон', style: textStyle)),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.amber.withValues(alpha: 0.75),
                  inactiveTrackColor: AppColors.mist.withValues(alpha: 0.2),
                  thumbColor: AppColors.amber.withValues(alpha: 0.85),
                  trackHeight: 2.5,
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(
                  value: session.ambientVolume.clamp(0.0, 0.4),
                  min: 0.0,
                  max: 0.4,
                  onChanged: notifier.setAmbientVolume,
                ),
              ),
            ),
          ],
        ),
        if (session.isBookMode && session.bookId != null)
          Align(
            alignment: Alignment.centerLeft,
            child: FilterChip(
              label: const Text('След. глава'),
              selected: session.autoAdvanceChapters,
              selectedColor: AppColors.amber.withValues(alpha: 0.28),
              labelStyle: TextStyle(
                color: session.autoAdvanceChapters
                    ? AppColors.amber
                    : AppColors.moon,
                fontSize: 12,
              ),
              onSelected: notifier.setAutoAdvanceChapters,
            ),
          ),
      ],
    );
  }
}

class _PositionBar extends ConsumerWidget {
  const _PositionBar({required this.session});

  final PlaybackSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = session.duration.inMilliseconds;
    final position =
        session.position.inMilliseconds.clamp(0, duration > 0 ? duration : 0);
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
              if (session.isBookMode && session.scriptText.isNotEmpty)
                Text(
                  '${((session.charOffset / session.scriptText.length.clamp(1, 1 << 30)) * 100).clamp(0, 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mist.withValues(alpha: 0.7),
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
    required this.session,
    required this.remaining,
  });

  final PlaybackSession session;
  final Duration? remaining;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = switch (session.timerMode) {
      SleepTimerMode.afterChapter => session.bookId != null
          ? 'До конца главы'
          : 'До конца выпуска',
      SleepTimerMode.afterSegment => 'До конца фразы',
      SleepTimerMode.countdown => remaining == null
          ? 'Таймер выключен'
          : 'Таймер ${_format(remaining!)}',
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.bedtime_outlined,
          size: 18,
          color: AppColors.amber.withValues(alpha: 0.9),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.amber,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        if (remaining != null) ...[
          const SizedBox(width: 8),
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
    final step = AppConstants.seekStepSeconds;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Semantics(
          button: true,
          label: 'Назад $step секунд',
          child: IconButton(
            onPressed: () => notifier.seekBy(Duration(seconds: -step)),
            iconSize: 40,
            icon: Badge(
              label: Text('$step'),
              backgroundColor: Colors.transparent,
              textColor: AppColors.mist,
              offset: const Offset(10, -8),
              child: const Icon(Icons.replay),
            ),
            color: AppColors.mist,
          ),
        ),
        const SizedBox(width: 16),
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
        const SizedBox(width: 16),
        Semantics(
          button: true,
          label: 'Вперёд $step секунд',
          child: IconButton(
            onPressed: () => notifier.seekBy(Duration(seconds: step)),
            iconSize: 40,
            icon: Badge(
              label: Text('$step'),
              backgroundColor: Colors.transparent,
              textColor: AppColors.mist,
              offset: const Offset(10, -8),
              child: const Icon(Icons.forward),
            ),
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
        session.timerMode == SleepTimerMode.countdown &&
        preset != null &&
        !AppConstants.timerPresetsMinutes.contains(preset);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        ...AppConstants.timerPresetsMinutes.map((minutes) {
          final selected = session.timerMode == SleepTimerMode.countdown &&
              !session.playUntilEnd &&
              preset == minutes;
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
                  SnackBar(
                    content: Text(
                      'Таймер: $minutes мин · стоп после фразы',
                    ),
                  ),
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
          label: Text(
            session.bookId != null ? 'До главы' : 'До конца',
          ),
          selected: session.timerMode == SleepTimerMode.afterChapter,
          selectedColor: AppColors.amber.withValues(alpha: 0.25),
          labelStyle: TextStyle(
            color: session.timerMode == SleepTimerMode.afterChapter
                ? AppColors.amber
                : AppColors.moon,
          ),
          onSelected: (_) => notifier.setSmartTimer(SleepTimerMode.afterChapter),
        ),
        ChoiceChip(
          label: const Text('До фразы'),
          selected: session.timerMode == SleepTimerMode.afterSegment &&
              session.playUntilEnd,
          selectedColor: AppColors.amber.withValues(alpha: 0.25),
          labelStyle: TextStyle(
            color: session.timerMode == SleepTimerMode.afterSegment &&
                    session.playUntilEnd
                ? AppColors.amber
                : AppColors.moon,
          ),
          onSelected: (_) =>
              notifier.setSmartTimer(SleepTimerMode.afterSegment),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/tts/tts_voice.dart';
import '../../domain/enums/comment_length.dart';
import '../../domain/enums/news_topic.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  var _page = 0;
  var _voiceId = TtsVoices.calmFemale.id;
  var _commentLength = CommentLength.short;
  final _topics = <NewsTopic>{
    NewsTopic.technology,
    NewsTopic.science,
  };

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF12182C),
              AppColors.night,
              Color(0xFF080C18),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppConstants.appName,
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.moon,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    _WelcomePage(textTheme: textTheme),
                    _VoicePage(
                      textTheme: textTheme,
                      voiceId: _voiceId,
                      onChanged: (id) => setState(() => _voiceId = id),
                    ),
                    _PrefsPage(
                      textTheme: textTheme,
                      topics: _topics,
                      commentLength: _commentLength,
                      onToggleTopic: (topic, selected) {
                        setState(() {
                          if (selected) {
                            _topics.add(topic);
                          } else if (_topics.length > 1) {
                            _topics.remove(topic);
                          }
                        });
                      },
                      onCommentChanged: (value) =>
                          setState(() => _commentLength = value),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final active = i == _page;
                        return Semantics(
                          label: 'Шаг ${i + 1} из 3',
                          selected: active,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: active ? 18 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.amber
                                  : AppColors.mist.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _next,
                        child: Text(_page == 2 ? 'Начать' : 'Далее'),
                      ),
                    ),
                    if (_page < 2)
                      TextButton(
                        onPressed: _finish,
                        child: const Text('Пропустить'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _next() async {
    if (_page < 2) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    await _finish();
  }

  Future<void> _finish() async {
    await ref.read(settingsProvider.notifier).updateSettings(
      (s) => s.copyWith(
        voiceId: _voiceId,
        commentLength: _commentLength,
        newsTopics: _topics.toList(),
        onboardingCompleted: true,
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Спокойный вечерний голос', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(
            'Книги, новости и ссылки — мягко, без спешки. '
            'Поставьте таймер и засыпайте под чтение.',
            style: textTheme.bodyLarge?.copyWith(color: AppColors.mist),
          ),
          const Spacer(),
          const Icon(Icons.nightlight_round, size: 72, color: AppColors.amber),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _VoicePage extends StatelessWidget {
  const _VoicePage({
    required this.textTheme,
    required this.voiceId,
    required this.onChanged,
  });

  final TextTheme textTheme;
  final String voiceId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      children: [
        Text('Выберите голос', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Потом можно сменить в настройках.',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.mist),
        ),
        const SizedBox(height: 16),
        ...TtsVoices.all.map((voice) {
          final selected = voice.id == voiceId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: AppColors.nightElevated,
              borderRadius: BorderRadius.circular(14),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(voice.labelRu),
                subtitle: Text(voice.descriptionRu),
                trailing: Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? AppColors.amber : AppColors.mist,
                ),
                onTap: () => onChanged(voice.id),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _PrefsPage extends StatelessWidget {
  const _PrefsPage({
    required this.textTheme,
    required this.topics,
    required this.commentLength,
    required this.onToggleTopic,
    required this.onCommentChanged,
  });

  final TextTheme textTheme;
  final Set<NewsTopic> topics;
  final CommentLength commentLength;
  final void Function(NewsTopic topic, bool selected) onToggleTopic;
  final ValueChanged<CommentLength> onCommentChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      children: [
        Text('Предпочтения', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Темы новостей и длина комментария.',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.mist),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: NewsTopic.values.map((topic) {
            final selected = topics.contains(topic);
            return FilterChip(
              label: Text(topic.labelRu),
              selected: selected,
              selectedColor: AppColors.amber.withValues(alpha: 0.25),
              checkmarkColor: AppColors.amber,
              onSelected: (value) => onToggleTopic(topic, value),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Text('Комментарий', style: textTheme.titleSmall),
        const SizedBox(height: 8),
        ...CommentLength.values.map((length) {
          final selected = commentLength == length;
          return ListTile(
            title: Text(length.labelRu),
            trailing: Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? AppColors.amber : AppColors.mist,
            ),
            selected: selected,
            onTap: () => onCommentChanged(length),
          );
        }),
      ],
    );
  }
}

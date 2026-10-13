import '../enums/comment_length.dart';
import '../enums/news_topic.dart';

class UserSettings {
  const UserSettings({
    this.voiceId = 'piper_denis',
    this.speechRate = 1.0,
    this.pitch = 1.0,
    this.commentLength = CommentLength.short,
    this.defaultTimerMinutes = 30,
    this.cacheLimitGb = 2,
    this.newsTopics = const [NewsTopic.technology, NewsTopic.science],
    this.useCloudAi = false,
    this.onboardingCompleted = false,
    this.booksReadOnly = true,
  });

  final String voiceId;
  final double speechRate;
  final double pitch;
  final CommentLength commentLength;
  final int defaultTimerMinutes;
  final int cacheLimitGb;
  final List<NewsTopic> newsTopics;
  final bool useCloudAi;
  final bool onboardingCompleted;
  final bool booksReadOnly;

  UserSettings copyWith({
    String? voiceId,
    double? speechRate,
    double? pitch,
    CommentLength? commentLength,
    int? defaultTimerMinutes,
    int? cacheLimitGb,
    List<NewsTopic>? newsTopics,
    bool? useCloudAi,
    bool? onboardingCompleted,
    bool? booksReadOnly,
  }) {
    return UserSettings(
      voiceId: voiceId ?? this.voiceId,
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      commentLength: commentLength ?? this.commentLength,
      defaultTimerMinutes: defaultTimerMinutes ?? this.defaultTimerMinutes,
      cacheLimitGb: cacheLimitGb ?? this.cacheLimitGb,
      newsTopics: newsTopics ?? this.newsTopics,
      useCloudAi: useCloudAi ?? this.useCloudAi,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      booksReadOnly: booksReadOnly ?? this.booksReadOnly,
    );
  }
}

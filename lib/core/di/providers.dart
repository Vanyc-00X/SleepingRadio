import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local/app_database.dart' hide Book, Episode;
import '../../data/llm/local_comment_service.dart';
import '../../data/recommendations/topic_recommender.dart';
import '../../data/repositories/books_repository.dart';
import '../../data/repositories/episodes_repository.dart';
import '../../data/repositories/links_repository.dart';
import '../../data/repositories/listen_history_repository.dart';
import '../../data/repositories/news_repository.dart';
import '../../data/repositories/podcast_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/news/news_feed_store.dart';
import '../../data/settings/stage8_prefs.dart';
import '../../data/settings/voice_presets.dart';
import '../../data/tts/audio_cache_store.dart';
import '../../data/repositories/playback_progress_repository.dart';
import '../../data/tts/on_device_model_store.dart';
import '../../data/tts/on_device_tts_engine.dart';
import '../../data/tts/tts_api_key_store.dart';
import '../../domain/models/book.dart';
import '../../domain/models/episode.dart';
import '../../domain/models/user_settings.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden in main');
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main',
  );
});

final ttsApiKeyStoreProvider = Provider<TtsApiKeyStore>((ref) {
  return TtsApiKeyStore(ref.watch(sharedPreferencesProvider));
});

final stage8PrefsProvider = Provider<Stage8Prefs>((ref) {
  return Stage8Prefs(ref.watch(sharedPreferencesProvider));
});

final voicePresetsStoreProvider = Provider<VoicePresetsStore>((ref) {
  return VoicePresetsStore(ref.watch(sharedPreferencesProvider));
});

final newsFeedStoreProvider = Provider<NewsFeedStore>((ref) {
  return NewsFeedStore(ref.watch(sharedPreferencesProvider));
});

final playbackProgressRepositoryProvider =
    Provider<PlaybackProgressRepository>((ref) {
  return PlaybackProgressRepository(ref.watch(sharedPreferencesProvider));
});

final localCommentServiceProvider = Provider<LocalCommentService>((ref) {
  return LocalCommentService(ref.watch(stage8PrefsProvider));
});

final topicRecommenderProvider = Provider<TopicRecommender>((ref) {
  return TopicRecommender();
});

final audioCacheStoreProvider = Provider<AudioCacheStore>((ref) {
  final settings = ref.watch(settingsProvider).asData?.value;
  return AudioCacheStore(limitGb: settings?.cacheLimitGb ?? 2);
});

final onDeviceModelStoreProvider = Provider<OnDeviceModelStore>((ref) {
  final store = OnDeviceModelStore();
  ref.onDispose(store.close);
  return store;
});

final onDeviceTtsEngineProvider = Provider<OnDeviceTtsEngine>((ref) {
  final engine = OnDeviceTtsEngine(
    store: ref.watch(onDeviceModelStoreProvider),
  );
  ref.onDispose(engine.dispose);
  return engine;
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(appDatabaseProvider));
});

final booksRepositoryProvider = Provider<BooksRepository>((ref) {
  return BooksRepository(ref.watch(appDatabaseProvider));
});

final linksRepositoryProvider = Provider<LinksRepository>((ref) {
  return LinksRepository(
    ref.watch(appDatabaseProvider),
    commentService: ref.watch(localCommentServiceProvider),
  );
});

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepository(
    ref.watch(appDatabaseProvider),
    commentService: ref.watch(localCommentServiceProvider),
    feedStore: ref.watch(newsFeedStoreProvider),
  );
});

final topicRecommendationsProvider = Provider((ref) {
  final settings = ref.watch(settingsProvider).asData?.value;
  final history = ref.watch(recentHistoryProvider).asData?.value ?? const [];
  if (settings == null) return const <TopicRecommendation>[];
  return ref.watch(topicRecommenderProvider).recommend(
    settings: settings,
    history: history,
  );
});

final podcastRepositoryProvider = Provider<PodcastRepository>((ref) {
  return PodcastRepository(ref.watch(appDatabaseProvider));
});

final episodesRepositoryProvider = Provider<EpisodesRepository>((ref) {
  return EpisodesRepository(ref.watch(appDatabaseProvider));
});

final listenHistoryRepositoryProvider = Provider<ListenHistoryRepository>((
  ref,
) {
  return ListenHistoryRepository(ref.watch(appDatabaseProvider));
});

final booksProvider = StreamProvider<List<Book>>((ref) {
  return ref.watch(booksRepositoryProvider).watchBooks();
});

final linkEpisodesProvider = StreamProvider<List<Episode>>((ref) {
  return ref.watch(linksRepositoryProvider).watchLinkEpisodes();
});

final newsEpisodesProvider = StreamProvider<List<Episode>>((ref) {
  return ref.watch(newsRepositoryProvider).watchNewsEpisodes();
});

final showEpisodesProvider = StreamProvider<List<Episode>>((ref) {
  return ref.watch(podcastRepositoryProvider).watchShowEpisodes();
});

final favoriteEpisodesProvider = StreamProvider<List<Episode>>((ref) {
  return ref.watch(episodesRepositoryProvider).watchFavorites();
});

final recentHistoryProvider = StreamProvider((ref) {
  return ref.watch(listenHistoryRepositoryProvider).watchRecent();
});

final bookProvider = FutureProvider.family<Book?, String>((ref, id) {
  return ref.watch(booksRepositoryProvider).getBook(id);
});

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, UserSettings>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<UserSettings> {
  @override
  Future<UserSettings> build() {
    return ref.read(settingsRepositoryProvider).load();
  }

  Future<void> updateSettings(
    UserSettings Function(UserSettings) transform,
  ) async {
    final current = state.asData?.value ?? const UserSettings();
    final next = transform(current);
    state = AsyncData(next);
    await ref.read(settingsRepositoryProvider).save(next);
  }
}

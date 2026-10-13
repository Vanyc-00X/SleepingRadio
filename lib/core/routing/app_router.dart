import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/books/book_detail_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/links/url_reader_screen.dart';
import '../../features/news/news_screen.dart';
import '../../features/player/now_playing_screen.dart';
import '../../features/podcast/podcast_builder_screen.dart';
import '../../features/settings/network_privacy_screen.dart';
import '../../features/settings/news_feeds_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/app_shell.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/player',
                builder: (context, state) => const NowPlayingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/book/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BookDetailScreen(bookId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/link',
        builder: (context, state) {
          final url = state.uri.queryParameters['url'];
          final text = state.uri.queryParameters['text'];
          return UrlReaderScreen(initialUrl: url, initialText: text);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/news',
        builder: (context, state) => const NewsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/podcast',
        builder: (context, state) => const PodcastBuilderScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/settings/privacy',
        builder: (context, state) => const NetworkPrivacyScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/settings/feeds',
        builder: (context, state) => const NewsFeedsScreen(),
      ),
    ],
  );
}

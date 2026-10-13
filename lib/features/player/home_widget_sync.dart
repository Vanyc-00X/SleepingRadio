import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../domain/models/playback_session.dart';

/// Синхронизация данных с Android-виджетом «таймер + play».
abstract final class HomeWidgetSync {
  static const androidName = 'SleepingRadioWidgetProvider';
  static const appGroup = 'group.com.sleepingradio';

  static Future<void> ensureConfigured() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await HomeWidget.setAppGroupId(appGroup);
    } catch (_) {}
  }

  static Future<void> push(PlaybackSession session) async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final playing = session.isPlaying;
      final timer = _timerLabel(session);
      await HomeWidget.saveWidgetData<String>('title', session.title);
      await HomeWidget.saveWidgetData<String>('timer', timer);
      await HomeWidget.saveWidgetData<bool>('playing', playing);
      await HomeWidget.updateWidget(androidName: androidName);
    } catch (_) {
      // Виджет опционален.
    }
  }

  static String _timerLabel(PlaybackSession session) {
    switch (session.timerMode) {
      case SleepTimerMode.afterChapter:
        return session.bookId != null ? 'До главы' : 'До конца';
      case SleepTimerMode.afterSegment:
        return 'До фразы';
      case SleepTimerMode.countdown:
        final left = session.timerRemaining;
        if (left == null) return 'Таймер выкл.';
        final m = left.inMinutes;
        final s = left.inSeconds.remainder(60).toString().padLeft(2, '0');
        return '$m:$s';
    }
  }
}

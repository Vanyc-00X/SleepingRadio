import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Локальный кэш синтезированных аудио-чанков.
class AudioCacheStore {
  AudioCacheStore({this.limitGb = 2});

  int limitGb;

  Future<Directory> _root() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'tts_cache'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String keyFor({
    required String voiceId,
    required String text,
    required double speechRate,
    required double pitch,
  }) {
    final payload =
        '$voiceId|${speechRate.toStringAsFixed(2)}|${pitch.toStringAsFixed(2)}|$text';
    return sha256.convert(utf8.encode(payload)).toString();
  }

  Future<File?> find(String key) async {
    final root = await _root();
    for (final ext in const ['mp3', 'wav', 'ogg']) {
      final file = File(p.join(root.path, '$key.$ext'));
      if (await file.exists() && await file.length() > 0) {
        return file;
      }
    }
    return null;
  }

  Future<File> put({
    required String key,
    required List<int> bytes,
    String extension = 'mp3',
  }) async {
    final root = await _root();
    final file = File(p.join(root.path, '$key.$extension'));
    await file.writeAsBytes(bytes, flush: true);
    await enforceLimit();
    return file;
  }

  Future<int> totalBytes() async {
    final root = await _root();
    var total = 0;
    await for (final entity in root.list(recursive: false)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  Future<void> enforceLimit() async {
    final maxBytes = limitGb * 1024 * 1024 * 1024;
    final root = await _root();
    final files = <File>[];
    await for (final entity in root.list(recursive: false)) {
      if (entity is File) files.add(entity);
    }
    files.sort(
      (a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()),
    );

    var total = 0;
    for (final f in files) {
      total += await f.length();
    }

    var i = 0;
    while (total > maxBytes && i < files.length) {
      final len = await files[i].length();
      try {
        await files[i].delete();
      } catch (_) {}
      total -= len;
      i++;
    }
  }

  Future<void> clear() async {
    final root = await _root();
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  }
}

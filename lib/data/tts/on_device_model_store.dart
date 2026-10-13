import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'on_device_tts_models.dart';

typedef OnDeviceDownloadProgress = void Function(double progress, String status);

/// Downloads and unpacks Piper RU models into app documents.
class OnDeviceModelStore {
  OnDeviceModelStore({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final http.Client _http;

  Future<Directory> rootDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'on_device_tts'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> modelDir(OnDeviceTtsModel model) async {
    final root = await rootDir();
    return Directory(p.join(root.path, model.folderName));
  }

  Future<bool> isInstalled(OnDeviceTtsModel model) async {
    final dir = await modelDir(model);
    final onnx = File(p.join(dir.path, model.modelFile));
    final tokens = File(p.join(dir.path, model.tokensFile));
    final data = Directory(p.join(dir.path, model.dataDirName));
    return await onnx.exists() &&
        await tokens.exists() &&
        await data.exists();
  }

  Future<OnDeviceModelPaths> ensureInstalled(
    OnDeviceTtsModel model, {
    OnDeviceDownloadProgress? onProgress,
  }) async {
    if (await isInstalled(model)) {
      return pathsFor(model);
    }
    onProgress?.call(0.02, 'Скачивание ${model.labelRu}…');
    final root = await rootDir();
    final archivePath = p.join(root.path, '${model.folderName}.tar.bz2');
    await _download(model.archiveUrl, archivePath, onProgress);
    onProgress?.call(0.85, 'Распаковка…');
    await _extractBz2Tar(archivePath, root.path);
    try {
      await File(archivePath).delete();
    } catch (_) {}
    if (!await isInstalled(model)) {
      throw StateError('Модель ${model.id} не установилась корректно');
    }
    onProgress?.call(1, 'Готово');
    return pathsFor(model);
  }

  Future<OnDeviceModelPaths> pathsFor(OnDeviceTtsModel model) async {
    final dir = await modelDir(model);
    return OnDeviceModelPaths(
      model: p.join(dir.path, model.modelFile),
      tokens: p.join(dir.path, model.tokensFile),
      dataDir: p.join(dir.path, model.dataDirName),
    );
  }

  Future<void> _download(
    String url,
    String destPath,
    OnDeviceDownloadProgress? onProgress,
  ) async {
    final request = http.Request('GET', Uri.parse(url));
    final response = await _http.send(request);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Download failed ${response.statusCode}',
        uri: Uri.parse(url),
      );
    }
    final total = response.contentLength ?? 0;
    final sink = File(destPath).openWrite();
    var received = 0;
    await for (final chunk in response.stream) {
      sink.add(chunk);
      received += chunk.length;
      if (total > 0) {
        final ratio = (received / total).clamp(0.0, 1.0);
        onProgress?.call(0.05 + ratio * 0.75, 'Скачивание…');
      }
    }
    await sink.close();
  }

  Future<void> _extractBz2Tar(String archivePath, String outDir) async {
    final bytes = await File(archivePath).readAsBytes();
    final tarBytes = BZip2Decoder().decodeBytes(bytes);
    final archive = TarDecoder().decodeBytes(tarBytes);
    for (final file in archive) {
      final outPath = p.join(outDir, file.name);
      if (file.isFile) {
        final out = File(outPath);
        await out.parent.create(recursive: true);
        await out.writeAsBytes(file.content as List<int>, flush: true);
      } else {
        await Directory(outPath).create(recursive: true);
      }
    }
  }

  void close() => _http.close();
}

class OnDeviceModelPaths {
  const OnDeviceModelPaths({
    required this.model,
    required this.tokens,
    required this.dataDir,
  });

  final String model;
  final String tokens;
  final String dataDir;
}

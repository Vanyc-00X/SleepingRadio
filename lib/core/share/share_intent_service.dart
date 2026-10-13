import 'dart:async';

import 'package:flutter/services.dart';

class SharedPayload {
  const SharedPayload({this.text, this.url});

  final String? text;
  final String? url;

  bool get isEmpty =>
      (text == null || text!.trim().isEmpty) &&
      (url == null || url!.trim().isEmpty);
}

/// Приём Android ACTION_SEND через MethodChannel.
class ShareIntentService {
  ShareIntentService() {
    _channel.setMethodCallHandler(_onMethodCall);
  }

  static const _channel = MethodChannel('com.sleepingradio/share');

  final _controller = StreamController<SharedPayload>.broadcast();
  Stream<SharedPayload> get stream => _controller.stream;

  Future<SharedPayload?> getInitial() async {
    try {
      final raw = await _channel.invokeMethod<dynamic>('getInitialShared');
      return _parse(raw);
    } catch (_) {
      return null;
    }
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'onShared') {
      final payload = _parse(call.arguments);
      if (payload != null && !payload.isEmpty) {
        _controller.add(payload);
      }
    }
  }

  SharedPayload? _parse(dynamic raw) {
    if (raw is! Map) return null;
    final text = raw['text'] as String?;
    final url = raw['url'] as String?;
    final payload = SharedPayload(text: text, url: url);
    return payload.isEmpty ? null : payload;
  }

  void dispose() {
    _controller.close();
  }
}

final shareIntentService = ShareIntentService();

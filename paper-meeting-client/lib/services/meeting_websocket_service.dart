import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/client_protocol.dart';

class MeetingWebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  String? _activeUrl;

  Future<void> connect({
    required String host,
    required int port,
    required String token,
    String path = '/infra/ws',
    required void Function(SyncEnvelope envelope) onMessage,
    void Function()? onConnected,
    void Function()? onDisconnected,
    void Function(Object error)? onError,
  }) async {
    await disconnect();
    final scheme = port == 443 ? 'wss' : 'ws';
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: normalizedPath,
      queryParameters: <String, String>{'token': token},
    );
    _activeUrl = uri.toString();
    _channel = WebSocketChannel.connect(uri);
    onConnected?.call();
    _subscription = _channel!.stream.listen((dynamic raw) {
      if (raw == 'pong') return;
      final parsed = jsonDecode(raw as String) as Map<String, dynamic>;
      final typeCode = parsed['type'] as String? ?? '';
      final content = parsed['content'] == null
          ? <String, dynamic>{}
          : jsonDecode(parsed['content'] as String) as Map<String, dynamic>;
      final type = _resolveType(typeCode);
      if (type == null) return;
      onMessage(SyncEnvelope(
        type: type,
        meetingId: '${content['meetingId'] ?? ''}',
        timestamp: DateTime.now(),
        payload: content,
      ));
    }, onDone: () {
      _channel = null;
      _subscription = null;
      onDisconnected?.call();
    }, onError: (Object error) {
      onError?.call(error);
    }, cancelOnError: true);
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    await _channel?.sink.close();
    _subscription = null;
    _channel = null;
    _activeUrl = null;
  }

  bool get isConnected => _channel != null;

  String? get activeUrl => _activeUrl;

  void send({
    required String type,
    required Map<String, dynamic> payload,
  }) {
    if (_channel == null) {
      return;
    }
    _channel!.sink.add(jsonEncode(<String, dynamic>{
      'type': type,
      'content': jsonEncode(payload),
    }));
  }

  SyncMessageType? _resolveType(String code) {
    switch (code) {
      case 'meeting-sync-request':
        return SyncMessageType.syncRequest;
      case 'meeting-sync-approved':
        return SyncMessageType.syncApproved;
      case 'meeting-sync-rejected':
        return SyncMessageType.syncRejected;
      case 'meeting-sync-stopped':
        return SyncMessageType.syncStopped;
      case 'meeting-notice-published':
        return SyncMessageType.noticePublished;
      case 'meeting-service-requested':
        return SyncMessageType.serviceRequested;
      case 'meeting-service-updated':
        return SyncMessageType.serviceUpdated;
      case 'meeting-vote-started':
        return SyncMessageType.voteStarted;
      case 'meeting-vote-finished':
        return SyncMessageType.voteFinished;
      case 'meeting-vote-published':
        return SyncMessageType.votePublished;
      case 'meeting-force-return':
        return SyncMessageType.forceReturn;
      case 'meeting-force-logout':
        return SyncMessageType.forceLogout;
      case 'meeting-video-opened':
        return SyncMessageType.videoOpened;
      case 'meeting-video-controlled':
        return SyncMessageType.videoControlled;
      case 'meeting-timer-started':
        return SyncMessageType.timerStarted;
      case 'meeting-timer-updated':
        return SyncMessageType.timerUpdated;
      case 'meeting-timer-stopped':
        return SyncMessageType.timerStopped;
      default:
        return null;
    }
  }
}

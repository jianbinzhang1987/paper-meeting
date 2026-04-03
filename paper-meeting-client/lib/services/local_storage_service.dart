import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_models.dart';

class LocalStorageSnapshot {
  const LocalStorageSnapshot({
    this.config,
    this.isConfigured = false,
    this.isDarkMode = false,
    this.notes = const <NoteEntry>[],
    this.bookmarks = const <BookmarkEntry>[],
    this.lastSignedInUserId,
    this.currentUser,
    this.cachedResources = const <String, String>{},
    this.recentDocumentIds = const <String>[],
    this.readNoticeIds = const <String>[],
    this.pinnedNoticeIds = const <String>[],
    this.noticeAutoPlay = false,
  });

  final ConnectionConfig? config;
  final bool isConfigured;
  final bool isDarkMode;
  final List<NoteEntry> notes;
  final List<BookmarkEntry> bookmarks;
  final String? lastSignedInUserId;
  final MeetingUser? currentUser;
  final Map<String, String> cachedResources;
  final List<String> recentDocumentIds;
  final List<String> readNoticeIds;
  final List<String> pinnedNoticeIds;
  final bool noticeAutoPlay;
}

class LocalStorageService {
  static const _configKey = 'meeting.config';
  static const _configuredKey = 'meeting.configured';
  static const _darkModeKey = 'meeting.darkMode';
  static const _notesKey = 'meeting.notes';
  static const _bookmarksKey = 'meeting.bookmarks';
  static const _lastSignedInUserIdKey = 'meeting.lastSignedInUserId';
  static const _currentUserKey = 'meeting.currentUser';
  static const _cachedResourcesKey = 'meeting.cachedResources';
  static const _recentDocumentIdsKey = 'meeting.recentDocumentIds';
  static const _readNoticeIdsKey = 'meeting.readNoticeIds';
  static const _pinnedNoticeIdsKey = 'meeting.pinnedNoticeIds';
  static const _noticeAutoPlayKey = 'meeting.noticeAutoPlay';

  Future<LocalStorageSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageSnapshot(
      config: _decodeConfig(prefs.getString(_configKey)),
      isConfigured: prefs.getBool(_configuredKey) ?? false,
      isDarkMode: prefs.getBool(_darkModeKey) ?? false,
      notes: _decodeNotes(prefs.getString(_notesKey)),
      bookmarks: _decodeBookmarks(prefs.getString(_bookmarksKey)),
      lastSignedInUserId: prefs.getString(_lastSignedInUserIdKey),
      currentUser: _decodeCurrentUser(prefs.getString(_currentUserKey)),
      cachedResources: _decodeStringMap(prefs.getString(_cachedResourcesKey)),
      recentDocumentIds:
          _decodeStringList(prefs.getString(_recentDocumentIdsKey)),
      readNoticeIds: _decodeStringList(prefs.getString(_readNoticeIdsKey)),
      pinnedNoticeIds: _decodeStringList(prefs.getString(_pinnedNoticeIdsKey)),
      noticeAutoPlay: prefs.getBool(_noticeAutoPlayKey) ?? false,
    );
  }

  Future<void> saveConfig(ConnectionConfig config,
      {required bool isConfigured}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _configKey,
      jsonEncode(<String, dynamic>{
        'serverIp': config.serverIp,
        'port': config.port,
        'roomName': config.roomName,
        'seatName': config.seatName,
        'deviceName': config.deviceName,
      }),
    );
    await prefs.setBool(_configuredKey, isConfigured);
  }

  Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> saveNotes(List<NoteEntry> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _notesKey,
      jsonEncode(
        notes
            .map(
              (item) => <String, dynamic>{
                'id': item.id,
                'documentId': item.documentId,
                'page': item.page,
                'content': item.content,
                'createdBy': item.createdBy,
                'updatedAt': item.updatedAt?.toIso8601String(),
              },
            )
            .toList(),
      ),
    );
  }

  Future<void> saveBookmarks(List<BookmarkEntry> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _bookmarksKey,
      jsonEncode(
        bookmarks
            .map(
              (item) => <String, dynamic>{
                'id': item.id,
                'documentId': item.documentId,
                'page': item.page,
                'label': item.label,
                'updatedAt': item.updatedAt?.toIso8601String(),
              },
            )
            .toList(),
      ),
    );
  }

  Future<void> saveLastSignedInUserId(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId == null || userId.isEmpty) {
      await prefs.remove(_lastSignedInUserIdKey);
      return;
    }
    await prefs.setString(_lastSignedInUserIdKey, userId);
  }

  Future<void> saveCurrentUser(MeetingUser? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_currentUserKey);
      return;
    }
    await prefs.setString(
      _currentUserKey,
      jsonEncode(<String, dynamic>{
        'id': user.id,
        'name': user.name,
        'role': user.role.name,
        'seatName': user.seatName,
        'signStatus': user.signStatus,
        'personalPassword': user.personalPassword,
        'requirePersonalPassword': user.requirePersonalPassword,
        'accessToken': user.accessToken,
        'accessTokenExpiresAt': user.accessTokenExpiresAt?.toIso8601String(),
        'websocketPath': user.websocketPath,
      }),
    );
  }

  Future<void> saveCachedResources(Map<String, String> resources) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedResourcesKey, jsonEncode(resources));
  }

  Future<void> saveRecentDocumentIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recentDocumentIdsKey, jsonEncode(ids));
  }

  Future<void> saveReadNoticeIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_readNoticeIdsKey, jsonEncode(ids));
  }

  Future<void> savePinnedNoticeIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinnedNoticeIdsKey, jsonEncode(ids));
  }

  Future<void> saveNoticeAutoPlay(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_noticeAutoPlayKey, value);
  }

  ConnectionConfig? _decodeConfig(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return ConnectionConfig(
      serverIp: '${json['serverIp'] ?? '127.0.0.1'}',
      port: (json['port'] as num?)?.toInt() ?? 48080,
      roomName: '${json['roomName'] ?? '未配置'}',
      seatName: '${json['seatName'] ?? '未配置'}',
      deviceName: '${json['deviceName'] ?? '客户端设备'}',
    );
  }

  List<NoteEntry> _decodeNotes(String? raw) {
    if (raw == null || raw.isEmpty) return const <NoteEntry>[];
    final json = jsonDecode(raw) as List<dynamic>;
    return json
        .map((item) => item as Map<String, dynamic>)
        .map(
          (item) => NoteEntry(
            id: item['id'] as String?,
            documentId: item['documentId'] as String?,
            page: (item['page'] as num?)?.toInt() ?? 1,
            content: '${item['content'] ?? ''}',
            createdBy: '${item['createdBy'] ?? '未知用户'}',
            updatedAt: DateTime.tryParse('${item['updatedAt'] ?? ''}'),
          ),
        )
        .toList();
  }

  List<BookmarkEntry> _decodeBookmarks(String? raw) {
    if (raw == null || raw.isEmpty) return const <BookmarkEntry>[];
    final json = jsonDecode(raw) as List<dynamic>;
    return json
        .map((item) => item as Map<String, dynamic>)
        .map(
          (item) => BookmarkEntry(
            id: item['id'] as String?,
            documentId: item['documentId'] as String?,
            page: (item['page'] as num?)?.toInt() ?? 1,
            label: '${item['label'] ?? '未命名书签'}',
            updatedAt: DateTime.tryParse('${item['updatedAt'] ?? ''}'),
          ),
        )
        .toList();
  }

  MeetingUser? _decodeCurrentUser(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final roleName = '${json['role'] ?? UserRole.attendee.name}';
    UserRole role = UserRole.attendee;
    for (final item in UserRole.values) {
      if (item.name == roleName) {
        role = item;
        break;
      }
    }
    return MeetingUser(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? '未知用户'}',
      role: role,
      seatName: '${json['seatName'] ?? ''}',
      signStatus: (json['signStatus'] as num?)?.toInt() ?? 0,
      personalPassword:
          (json['personalPassword'] ?? json['password']) as String?,
      requirePersonalPassword: json['requirePersonalPassword'] == true,
      accessToken: json['accessToken'] as String?,
      accessTokenExpiresAt:
          DateTime.tryParse('${json['accessTokenExpiresAt'] ?? ''}'),
      websocketPath: json['websocketPath'] as String?,
    );
  }

  Map<String, String> _decodeStringMap(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const <String, String>{};
    }
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return json.map((key, value) => MapEntry(key, '$value'));
  }

  List<String> _decodeStringList(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const <String>[];
    }
    final json = jsonDecode(raw) as List<dynamic>;
    return json.map((item) => '$item').toList();
  }
}

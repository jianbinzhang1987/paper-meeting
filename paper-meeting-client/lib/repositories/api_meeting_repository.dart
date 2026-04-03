import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../data/mock_data.dart';
import '../models/app_models.dart';
import '../models/client_protocol.dart';
import 'meeting_repository.dart';

class ApiMeetingRepository implements MeetingRepository {
  ApiMeetingRepository({
    required MeetingRepository fallback,
  }) : _fallback = fallback;

  final MeetingRepository _fallback;
  PackageInfo? _packageInfo;

  @override
  Future<SeedData> loadBootstrapData(ConnectionConfig config) async {
    try {
      final uri = Uri.http('${config.serverIp}:${config.port}',
          '/meeting/app/bootstrap', <String, String>{
        'roomName': config.roomName,
        'seatName': config.seatName,
        'deviceName': config.deviceName,
      });
      final json = await _getJson(uri);
      final data = json['data'];
      if (data == null) {
        return SeedData(
          config: config,
          session: _buildNoMeetingSession(),
        );
      }
      return SeedData(
        config: config,
        session: _mapSession(data as Map<String, dynamic>),
      );
    } catch (_) {
      return _fallback.loadBootstrapData(config);
    }
  }

  @override
  Future<void> reportTerminalStatus({
    required ConnectionConfig config,
    required MeetingSession session,
    MeetingUser? user,
    required bool isDarkMode,
    required ConnectionStatus connectionStatus,
  }) async {
    try {
      final packageInfo = await _getPackageInfo();
      final uri = Uri.http(
          '${config.serverIp}:${config.port}', '/meeting/app/terminal-heartbeat');
      final terminalProfile = session.terminalProfile;
      final appVersionProfile = terminalProfile?.appVersion;
      final uiConfigProfile = terminalProfile?.uiConfig;
      final brandingProfile = terminalProfile?.branding;
      final installedVersionName = packageInfo.version;
      final installedVersionCode = _parseBuildNumber(packageInfo.buildNumber);
      final versionMatched = appVersionProfile != null &&
          appVersionProfile.versionCode == installedVersionCode &&
          (appVersionProfile.versionName == null ||
              appVersionProfile.versionName == installedVersionName);
      await _postJson(uri, <String, dynamic>{
        'clientType': appVersionProfile?.clientType ?? 1,
        'roomName': config.roomName,
        'seatName': config.seatName,
        'deviceName': config.deviceName,
        'meetingId': _parseMeetingId(session.meetingId),
        'meetingName': _isMeaningfulSession(session) ? session.meetingName : null,
        'userId': user == null ? null : int.tryParse(user.id),
        'userName': user?.name,
        'themeMode': isDarkMode ? 'dark' : 'light',
        'connectionStatus': connectionStatus.name,
        'appVersionId': versionMatched ? _parseNullableId(appVersionProfile?.id) : null,
        'appVersionName': versionMatched
            ? (appVersionProfile?.name ?? '${packageInfo.appName} $installedVersionName')
            : '${packageInfo.appName} $installedVersionName',
        'appVersionCode': installedVersionCode,
        'uiConfigId': _parseNullableId(uiConfigProfile?.id),
        'uiConfigName': uiConfigProfile?.name,
        'brandingId': _parseNullableId(brandingProfile?.id),
        'brandingName': brandingProfile?.siteName,
      });
    } catch (_) {
      return;
    }
  }

  @override
  Future<MeetingUser> signIn({
    required ConnectionConfig config,
    required MeetingSession session,
    required MeetingUser user,
    required String meetingPassword,
    String personalPassword = '',
  }) async {
    try {
      final uri =
          Uri.http('${config.serverIp}:${config.port}', '/meeting/app/sign-in');
      final json = await _postJson(uri, <String, dynamic>{
        'meetingId': int.tryParse(session.meetingId) ?? 0,
        'userId': int.tryParse(user.id) ?? 0,
        'password': meetingPassword,
        'meetingPassword': meetingPassword,
        'userPassword': personalPassword,
        'deviceName': config.deviceName,
      });
      final data = json['data'] as Map<String, dynamic>;
      return MeetingUser(
        id: '${data['userId']}',
        name: '${data['nickname'] ?? user.name}',
        role: _mapRole(data['role'] as int? ?? _roleToCode(user.role)),
        seatName: '${data['seatId'] ?? user.seatName}',
        signStatus: 1,
        personalPassword: user.personalPassword,
        requirePersonalPassword: user.requirePersonalPassword,
        accessToken: data['accessToken'] as String?,
        accessTokenExpiresAt:
            DateTime.tryParse('${data['accessTokenExpiresTime'] ?? ''}'),
        websocketPath: data['websocketPath'] as String?,
      );
    } catch (_) {
      return _fallback.signIn(
        config: config,
        session: session,
        user: user,
        meetingPassword: meetingPassword,
        personalPassword: personalPassword,
      );
    }
  }

  @override
  Future<void> submitVote({
    required ConnectionConfig config,
    required String userId,
    required String voteId,
    required String optionId,
  }) async {
    try {
      final uri = Uri.http(
          '${config.serverIp}:${config.port}', '/meeting/app/vote/submit');
      await _postJson(uri, <String, dynamic>{
        'voteId': int.tryParse(voteId) ?? 0,
        'userId': int.tryParse(userId) ?? 0,
        'optionId': int.tryParse(optionId) ?? 0,
      });
    } catch (_) {
      await _fallback.submitVote(
        config: config,
        userId: userId,
        voteId: voteId,
        optionId: optionId,
      );
    }
  }

  @override
  Future<List<MeetingDocument>> fetchDocuments({
    required ConnectionConfig config,
    required String meetingId,
  }) async {
    try {
      final uri = Uri.http('${config.serverIp}:${config.port}',
          '/meeting/app/documents', <String, String>{
        'meetingId': meetingId,
      });
      final json = await _getJson(uri);
      final data = (json['data'] as List<dynamic>? ?? <dynamic>[])
          .map((item) => item as Map<String, dynamic>)
          .toList();
      return data
          .map(
            (item) => MeetingDocument(
              id: '${item['id']}',
              topicId: '${item['agendaId']}',
              title: '${item['name'] ?? '未命名文稿'}',
              pageCount: (item['pageCount'] as num?)?.toInt() ?? 1,
              summary:
                  '${item['summary'] ?? '文件类型：${item['type'] ?? 'unknown'}，文件地址：${item['url'] ?? ''}'}',
              fileType: '${item['type'] ?? ''}',
              fileUrl: item['url'] as String?,
              thumbnailUrl: item['thumbnailUrl'] as String?,
            ),
          )
          .toList();
    } catch (_) {
      return _fallback.fetchDocuments(config: config, meetingId: meetingId);
    }
  }

  @override
  Future<NoticePageResult> fetchNotices({
    required ConnectionConfig config,
    required String meetingId,
    String? userId,
    int pageNo = 1,
    int pageSize = 100,
  }) async {
    try {
      final uri = Uri.http('${config.serverIp}:${config.port}',
          '/meeting/app/notices/page', <String, String>{
        'meetingId': meetingId,
        'pageNo': '$pageNo',
        'pageSize': '$pageSize',
        if (userId != null && userId.isNotEmpty) 'userId': userId,
      });
      final json = await _getJson(uri);
      final page = json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final data = (page['list'] as List<dynamic>? ?? <dynamic>[])
          .map((item) => item as Map<String, dynamic>)
          .toList();
      return NoticePageResult(
        items: data
            .map(
              (item) => MeetingNotice(
                id: '${item['id']}',
                title: '${item['title'] ?? '会议通知'}',
                content: '${item['content'] ?? ''}',
                createdAt: DateTime.tryParse(
                        '${item['publishedTime'] ?? item['createTime'] ?? ''}') ??
                    DateTime.now(),
                read: item['read'] as bool? ?? false,
              ),
            )
            .toList(),
        total: (page['total'] as num?)?.toInt() ?? data.length,
      );
    } catch (_) {
      return _fallback.fetchNotices(
          config: config,
          meetingId: meetingId,
          userId: userId,
          pageNo: pageNo,
          pageSize: pageSize);
    }
  }

  @override
  Future<void> markNoticeRead({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required String noticeId,
  }) async {
    try {
      final uri = Uri.http(
          '${config.serverIp}:${config.port}', '/meeting/app/notices/read');
      await _postJson(uri, <String, dynamic>{
        'meetingId': int.tryParse(meetingId) ?? 0,
        'userId': int.tryParse(userId) ?? 0,
        'noticeId': int.tryParse(noticeId) ?? 0,
      });
    } catch (_) {
      await _fallback.markNoticeRead(
        config: config,
        meetingId: meetingId,
        userId: userId,
        noticeId: noticeId,
      );
    }
  }

  @override
  Future<List<NoteEntry>> fetchNotes({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required String documentId,
  }) async {
    return _fetchDocumentMarks(
      config: config,
      meetingId: meetingId,
      userId: userId,
      documentId: documentId,
      type: 'note',
    ).then((items) => items
        .map((item) => NoteEntry(
              id: item['id'],
              documentId: item['documentId'],
              page: item['page'] as int? ?? 1,
              content: item['content'] ?? '',
              createdBy: item['createdBy'] ?? '当前用户',
              updatedAt: DateTime.tryParse('${item['updatedAt'] ?? ''}'),
            ))
        .toList());
  }

  @override
  Future<List<BookmarkEntry>> fetchBookmarks({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required String documentId,
  }) async {
    return _fetchDocumentMarks(
      config: config,
      meetingId: meetingId,
      userId: userId,
      documentId: documentId,
      type: 'bookmark',
    ).then((items) => items
        .map((item) => BookmarkEntry(
              id: item['id'],
              documentId: item['documentId'],
              page: item['page'] as int? ?? 1,
              label: item['content'] ?? '',
              updatedAt: DateTime.tryParse('${item['updatedAt'] ?? ''}'),
            ))
        .toList());
  }

  @override
  Future<NoteEntry> saveNote({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required String documentId,
    required int page,
    required String content,
    required String createdBy,
  }) async {
    try {
      final item = await _saveDocumentMark(
        config: config,
        meetingId: meetingId,
        userId: userId,
        documentId: documentId,
        page: page,
        type: 'note',
        content: content,
      );
      return NoteEntry(
        id: item['id'],
        documentId: item['documentId'],
        page: item['page'] as int? ?? page,
        content: item['content'] ?? content,
        createdBy: createdBy,
        updatedAt: DateTime.tryParse('${item['updatedAt'] ?? ''}') ?? DateTime.now(),
      );
    } catch (_) {
      return _fallback.saveNote(
        config: config,
        meetingId: meetingId,
        userId: userId,
        documentId: documentId,
        page: page,
        content: content,
        createdBy: createdBy,
      );
    }
  }

  @override
  Future<BookmarkEntry> saveBookmark({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required String documentId,
    required int page,
    required String label,
  }) async {
    try {
      final item = await _saveDocumentMark(
        config: config,
        meetingId: meetingId,
        userId: userId,
        documentId: documentId,
        page: page,
        type: 'bookmark',
        content: label,
      );
      return BookmarkEntry(
        id: item['id'],
        documentId: item['documentId'],
        page: item['page'] as int? ?? page,
        label: item['content'] ?? label,
        updatedAt: DateTime.tryParse('${item['updatedAt'] ?? ''}') ?? DateTime.now(),
      );
    } catch (_) {
      return _fallback.saveBookmark(
        config: config,
        meetingId: meetingId,
        userId: userId,
        documentId: documentId,
        page: page,
        label: label,
      );
    }
  }

  @override
  Future<void> deleteNote({
    required ConnectionConfig config,
    required String userId,
    required String markId,
  }) async {
    try {
      final uri = Uri.http('${config.serverIp}:${config.port}',
          '/meeting/app/document-marks/delete');
      await _postJson(uri, <String, dynamic>{
        'id': int.tryParse(markId) ?? 0,
        'userId': int.tryParse(userId) ?? 0,
      });
    } catch (_) {
      await _fallback.deleteNote(
          config: config, userId: userId, markId: markId);
    }
  }

  @override
  Future<void> deleteBookmark({
    required ConnectionConfig config,
    required String userId,
    required String markId,
  }) async {
    try {
      final uri = Uri.http('${config.serverIp}:${config.port}',
          '/meeting/app/document-marks/delete');
      await _postJson(uri, <String, dynamic>{
        'id': int.tryParse(markId) ?? 0,
        'userId': int.tryParse(userId) ?? 0,
      });
    } catch (_) {
      await _fallback.deleteBookmark(
          config: config, userId: userId, markId: markId);
    }
  }

  @override
  Future<VoteItem?> fetchCurrentVote({
    required ConnectionConfig config,
    required String meetingId,
    String? userId,
  }) async {
    try {
      final uri = Uri.http('${config.serverIp}:${config.port}',
          '/meeting/app/votes', <String, String>{
        'meetingId': meetingId,
        if (userId != null && userId.isNotEmpty) 'userId': userId,
      });
      final json = await _getJson(uri);
      final data = (json['data'] as List<dynamic>? ?? <dynamic>[])
          .map((item) => item as Map<String, dynamic>)
          .toList();
      if (data.isEmpty) {
        return null;
      }
      return _mapVote(data.first, currentUserId: userId);
    } catch (_) {
      return _fallback.fetchCurrentVote(
          config: config, meetingId: meetingId, userId: userId);
    }
  }

  @override
  Future<RealtimeSnapshot> fetchRealtimeState({
    required ConnectionConfig config,
    required String meetingId,
  }) async {
    try {
      final uri = Uri.http('${config.serverIp}:${config.port}',
          '/meeting/app/realtime-state', <String, String>{
        'meetingId': meetingId,
      });
      final json = await _getJson(uri);
      final data = json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return RealtimeSnapshot(
        syncRequests: _mapSyncRequests(data['syncRequests'] as List<dynamic>?),
        serviceRequests:
            _mapServiceRequests(data['serviceRequests'] as List<dynamic>?),
        videoState: _mapVideoState(data['videoState'] as Map<String, dynamic>?),
        timerState: _mapTimerState(data['timerState'] as Map<String, dynamic>?),
      );
    } catch (_) {
      return _fallback.fetchRealtimeState(config: config, meetingId: meetingId);
    }
  }

  @override
  Future<SignatureSubmission> submitSignature({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required List<int> pngBytes,
    required int strokeCount,
  }) async {
    try {
      final uri = Uri.http(
          '${config.serverIp}:${config.port}', '/meeting/app/signature/submit');
      final json = await _postJson(uri, <String, dynamic>{
        'meetingId': int.tryParse(meetingId) ?? 0,
        'userId': int.tryParse(userId) ?? 0,
        'imageBase64': base64Encode(pngBytes),
        'strokeCount': strokeCount,
      });
      final data = json['data'] as Map<String, dynamic>;
      return SignatureSubmission(
        fileUrl: '${data['fileUrl'] ?? ''}',
        submitTime:
            DateTime.tryParse('${data['submitTime'] ?? ''}') ?? DateTime.now(),
        strokeCount: (data['strokeCount'] as num?)?.toInt() ?? strokeCount,
      );
    } catch (_) {
      return _fallback.submitSignature(
        config: config,
        meetingId: meetingId,
        userId: userId,
        pngBytes: pngBytes,
        strokeCount: strokeCount,
      );
    }
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await http.get(
      uri,
      headers: <String, String>{'Accept': 'application/json'},
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _postJson(
      Uri uri, Map<String, dynamic> payload) async {
    final response = await http.post(
      uri,
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return _decodeResponse(response);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  MeetingSession _mapSession(Map<String, dynamic> data) {
    final attendeeList = (data['attendees'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => item as Map<String, dynamic>)
        .toList();
    final noticeList = (data['notices'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => item as Map<String, dynamic>)
        .toList();
    final voteList = (data['votes'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => item as Map<String, dynamic>)
        .toList();
    final agendaList = (data['agendas'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => item as Map<String, dynamic>)
        .toList();
    final documentList = (data['documents'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => item as Map<String, dynamic>)
        .toList();

    return MeetingSession(
      meetingId: '${data['meetingId']}',
      meetingName: '${data['meetingName'] ?? '未命名会议'}',
      description: '${data['description'] ?? ''}',
      topics: agendaList
          .map((item) => MeetingTopic(
              id: '${item['id']}', title: '${item['title'] ?? '未命名议题'}'))
          .toList(),
      documents: documentList
          .map(
            (item) => MeetingDocument(
              id: '${item['id']}',
              topicId: '${item['agendaId']}',
              title: '${item['name'] ?? '未命名文稿'}',
              pageCount: (item['pageCount'] as num?)?.toInt() ?? 1,
              summary:
                  '${item['summary'] ?? '文件类型：${item['type'] ?? 'unknown'}，文件地址：${item['url'] ?? ''}'}',
              fileType: '${item['type'] ?? ''}',
              fileUrl: item['url'] as String?,
              thumbnailUrl: item['thumbnailUrl'] as String?,
            ),
          )
          .toList(),
      videoTitles: documentList
          .where(
              (item) => '${item['type'] ?? ''}'.toLowerCase().contains('video'))
          .map((item) => '${item['name']}')
          .toList(),
      libraryTitles: documentList
          .where((item) =>
              !'${item['type'] ?? ''}'.toLowerCase().contains('video'))
          .map((item) => '${item['name']}')
          .toList(),
      users: attendeeList
          .map(
            (item) => MeetingUser(
              id: '${item['userId']}',
              name: '${item['name'] ?? '未知用户'}',
              role: _mapRole(item['role'] as int? ?? 0),
              seatName: '${item['seatId'] ?? ''}',
              signStatus: item['signStatus'] as int? ?? 0,
              requirePersonalPassword:
                  item['personalPasswordRequired'] == true,
            ),
          )
          .toList(),
      notices: noticeList
          .map(
            (item) => MeetingNotice(
              id: '${item['id']}',
              title: '${item['title'] ?? '会议通知'}',
              content: '${item['content'] ?? ''}',
              createdAt: DateTime.tryParse(
                      '${item['publishedTime'] ?? item['createTime'] ?? ''}') ??
                  DateTime.now(),
              read: item['read'] as bool? ?? false,
            ),
          )
          .toList(),
      voteItem: voteList.isEmpty
          ? VoteItem(
              id: '0',
              title: '暂无表决',
              description: '当前会议暂无进行中的表决事项。',
              anonymous: false,
              stage: VoteStage.idle,
              options: <VoteOption>[VoteOption(id: '0', label: '待发布')],
              votedUserIds: <String>{},
            )
          : _mapVote(voteList.first),
      serviceRequests:
          _mapServiceRequests(data['serviceRequests'] as List<dynamic>?),
      syncRequests: _mapSyncRequests(data['syncRequests'] as List<dynamic>?),
      watermarkEnabled: data['watermark'] == true,
      meetingPasswordRequired: data['meetingPasswordRequired'] == true,
      terminalProfile: TerminalProfile(
        appVersion: _mapActiveAppVersion(
            data['activeAppVersion'] as Map<String, dynamic>?),
        uiConfig:
            _mapActiveUiConfig(data['activeUiConfig'] as Map<String, dynamic>?),
        branding:
            _mapActiveBranding(data['activeBranding'] as Map<String, dynamic>?),
      ),
    );
  }

  MeetingSession _buildNoMeetingSession() {
    return MeetingSession(
      meetingId: 'no-meeting',
      meetingName: '当前无进行中会议',
      description: '当前会议室暂无进行中的会议，请稍后重试或检查会议室配置。',
      topics: const <MeetingTopic>[],
      documents: const <MeetingDocument>[],
      videoTitles: const <String>[],
      libraryTitles: const <String>[],
      users: const <MeetingUser>[],
      notices: const <MeetingNotice>[],
      voteItem: VoteItem(
        id: '0',
        title: '暂无表决',
        description: '当前会议暂无可参与的表决。',
        anonymous: false,
        stage: VoteStage.idle,
        options: <VoteOption>[VoteOption(id: '0', label: '待发布')],
        votedUserIds: <String>{},
      ),
      serviceRequests: const <ServiceRequest>[],
      syncRequests: const <SyncRequest>[],
      watermarkEnabled: false,
      meetingPasswordRequired: false,
      terminalProfile: const TerminalProfile(),
    );
  }

  TerminalAppVersionProfile? _mapActiveAppVersion(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return null;
    }
    return TerminalAppVersionProfile(
      id: '${data['id'] ?? ''}',
      clientType: (data['clientType'] as num?)?.toInt(),
      name: data['name'] as String?,
      versionName: data['versionName'] as String?,
      versionCode: (data['versionCode'] as num?)?.toInt(),
      forceUpdate: data['forceUpdate'] == true,
      downloadUrl: data['downloadUrl'] as String?,
      md5: data['md5'] as String?,
    );
  }

  TerminalUiConfigProfile? _mapActiveUiConfig(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return null;
    }
    return TerminalUiConfigProfile(
      id: '${data['id'] ?? ''}',
      name: data['name'] as String?,
      fontSize: (data['fontSize'] as num?)?.toInt(),
      primaryColor: data['primaryColor'] as String?,
      accentColor: data['accentColor'] as String?,
      backgroundImageUrl: data['backgroundImageUrl'] as String?,
      logoUrl: data['logoUrl'] as String?,
      extraCss: data['extraCss'] as String?,
    );
  }

  TerminalBrandingProfile? _mapActiveBranding(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return null;
    }
    return TerminalBrandingProfile(
      id: '${data['id'] ?? ''}',
      siteName: data['siteName'] as String?,
      siteLogoUrl: data['siteLogoUrl'] as String?,
      sidebarTitle: data['sidebarTitle'] as String?,
      sidebarSubtitle: data['sidebarSubtitle'] as String?,
    );
  }

  Future<PackageInfo> _getPackageInfo() async {
    final cached = _packageInfo;
    if (cached != null) {
      return cached;
    }
    final value = await PackageInfo.fromPlatform();
    _packageInfo = value;
    return value;
  }

  int? _parseMeetingId(String meetingId) {
    if (meetingId == 'bootstrap' || meetingId == 'no-meeting') {
      return null;
    }
    return int.tryParse(meetingId);
  }

  int? _parseNullableId(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return int.tryParse(value);
  }

  int _parseBuildNumber(String rawValue) {
    return int.tryParse(rawValue) ?? 1;
  }

  bool _isMeaningfulSession(MeetingSession session) {
    return session.meetingId != 'bootstrap' && session.meetingId != 'no-meeting';
  }

  VoteItem _mapVote(Map<String, dynamic> data, {String? currentUserId}) {
    final options = (data['options'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => item as Map<String, dynamic>)
        .map(
          (item) => VoteOption(
            id: '${item['id']}',
            label: '${item['content'] ?? ''}',
            count: (item['voteCount'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList();
    final currentUserVoted = data['currentUserVoted'] == true;
    return VoteItem(
      id: '${data['id']}',
      title: '${data['title'] ?? '表决'}',
      description: '表决类型：${(data['type'] ?? 0) == 1 ? '多选' : '单选'}',
      anonymous: data['secret'] == true,
      stage: _mapVoteStage(
        data['status'] as int? ?? 0,
        publishedTime: '${data['publishedTime'] ?? ''}',
      ),
      options: options.isEmpty
          ? <VoteOption>[VoteOption(id: '0', label: '无选项')]
          : options,
      votedUserIds: currentUserVoted && currentUserId != null
          ? <String>{currentUserId}
          : <String>{},
      publishedAt: DateTime.tryParse('${data['publishedTime'] ?? ''}'),
    );
  }

  List<SyncRequest> _mapSyncRequests(List<dynamic>? values) {
    return (values ?? <dynamic>[])
        .map((item) => item as Map<String, dynamic>)
        .map(
          (item) => SyncRequest(
            id: '${item['requestId']}',
            requesterUserId: '${item['requesterUserId'] ?? ''}',
            requesterName: '${item['requesterName'] ?? '未知用户'}',
            requesterSeatName: '${item['requesterSeatName'] ?? ''}',
            documentId: '${item['documentId'] ?? ''}',
            documentTitle: '${item['documentTitle'] ?? '未命名文稿'}',
            page: item['page'] as int?,
            status: _mapSyncStatus('${item['status'] ?? 'pending'}'),
            approverUserId: '${item['approverUserId'] ?? ''}',
            approverName: '${item['approverName'] ?? ''}',
          ),
        )
        .toList();
  }

  List<ServiceRequest> _mapServiceRequests(List<dynamic>? values) {
    return (values ?? <dynamic>[])
        .map((item) => item as Map<String, dynamic>)
        .map(
          (item) => ServiceRequest(
            id: '${item['requestId']}',
            requesterUserId: '${item['requesterUserId'] ?? ''}',
            requesterName: '${item['requesterName'] ?? '未知用户'}',
            seatName: '${item['requesterSeatName'] ?? ''}',
            category: '${item['category'] ?? '会务服务'}',
            detail: '${item['detail'] ?? ''}',
            status: _mapServiceStatus('${item['status'] ?? 'pending'}'),
            handlerUserId: '${item['handlerUserId'] ?? ''}',
            handlerName: '${item['handlerName'] ?? ''}',
            acceptedAt: DateTime.tryParse('${item['acceptedAt'] ?? ''}'),
            completedAt: DateTime.tryParse('${item['completedAt'] ?? ''}'),
            canceledAt: DateTime.tryParse('${item['canceledAt'] ?? ''}'),
            resultRemark: item['resultRemark'] as String?,
          ),
        )
        .toList();
  }

  UserRole _mapRole(int role) {
    switch (role) {
      case 1:
        return UserRole.host;
      case 2:
        return UserRole.secretary;
      default:
        return UserRole.attendee;
    }
  }

  SyncRequestStatus _mapSyncStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return SyncRequestStatus.approved;
      case 'rejected':
        return SyncRequestStatus.rejected;
      default:
        return SyncRequestStatus.pending;
    }
  }

  ServiceStatus _mapServiceStatus(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return ServiceStatus.accepted;
      case 'processing':
        return ServiceStatus.processing;
      case 'completed':
        return ServiceStatus.completed;
      case 'canceled':
        return ServiceStatus.canceled;
      default:
        return ServiceStatus.pending;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchDocumentMarks({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required String documentId,
    required String type,
  }) async {
    try {
      final uri = Uri.http('${config.serverIp}:${config.port}',
          '/meeting/app/document-marks', <String, String>{
        'meetingId': meetingId,
        'userId': userId,
        'documentId': documentId,
      });
      final json = await _getJson(uri);
      final data = (json['data'] as List<dynamic>? ?? <dynamic>[])
          .map((item) => item as Map<String, dynamic>)
          .where((item) => '${item['type'] ?? ''}'.toLowerCase() == type)
          .map((item) => <String, dynamic>{
                'id': '${item['id']}',
                'documentId': '${item['documentId']}',
                'page': (item['page'] as num?)?.toInt() ?? 1,
                'content': '${item['content'] ?? ''}',
                'updatedAt': '${item['updatedAt'] ?? ''}',
              })
          .toList();
      return data;
    } catch (_) {
      if (type == 'note') {
        return (await _fallback.fetchNotes(
          config: config,
          meetingId: meetingId,
          userId: userId,
          documentId: documentId,
        ))
            .map((item) => <String, dynamic>{
                  'id': item.id,
                  'documentId': item.documentId,
                  'page': item.page,
                  'content': item.content,
                  'createdBy': item.createdBy,
                  'updatedAt': item.updatedAt?.toIso8601String(),
                })
            .toList();
      }
      return (await _fallback.fetchBookmarks(
        config: config,
        meetingId: meetingId,
        userId: userId,
        documentId: documentId,
      ))
          .map((item) => <String, dynamic>{
                'id': item.id,
                'documentId': item.documentId,
                'page': item.page,
                'content': item.label,
                'updatedAt': item.updatedAt?.toIso8601String(),
              })
          .toList();
    }
  }

  Future<Map<String, dynamic>> _saveDocumentMark({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required String documentId,
    required int page,
    required String type,
    required String content,
  }) async {
    final uri = Uri.http(
        '${config.serverIp}:${config.port}', '/meeting/app/document-marks/save');
    final json = await _postJson(uri, <String, dynamic>{
      'meetingId': int.tryParse(meetingId) ?? 0,
      'userId': int.tryParse(userId) ?? 0,
      'documentId': int.tryParse(documentId) ?? 0,
      'page': page,
      'type': type,
      'content': content,
    });
    return json['data'] as Map<String, dynamic>;
  }

  int _roleToCode(UserRole role) {
    switch (role) {
      case UserRole.host:
        return 1;
      case UserRole.secretary:
        return 2;
      case UserRole.attendee:
        return 0;
    }
  }

  VoteStage _mapVoteStage(int status, {String? publishedTime}) {
    final publishedAt = DateTime.tryParse(publishedTime ?? '');
    if (publishedAt != null) {
      return VoteStage.published;
    }
    switch (status) {
      case 1:
        return VoteStage.active;
      case 2:
        return VoteStage.finished;
      default:
        return VoteStage.idle;
    }
  }

  VideoSyncState _mapVideoState(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return const VideoSyncState();
    }
    return VideoSyncState(
      documentId: '${data['documentId'] ?? ''}',
      documentTitle: data['documentTitle'] as String?,
      positionMs: (data['positionMs'] as num?)?.toInt() ?? 0,
      playing: data['playing'] == true,
      active: '${data['documentId'] ?? ''}'.isNotEmpty,
      sentAt: DateTime.tryParse('${data['sentTime'] ?? ''}'),
    );
  }

  TimerState? _mapTimerState(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return null;
    }
    return TimerState(
      totalSeconds: (data['totalSeconds'] as num?)?.toInt() ?? 0,
      remainingSeconds: (data['remainingSeconds'] as num?)?.toInt() ?? 0,
      running: data['running'] == true,
      countDown: data['countDown'] != false,
      speaker: data['speaker'] as String?,
      controlled: true,
      sentAt: DateTime.tryParse('${data['sentTime'] ?? ''}'),
    );
  }
}

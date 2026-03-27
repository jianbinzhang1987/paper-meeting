import 'dart:async';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/app_models.dart';
import '../models/client_protocol.dart';
import '../repositories/meeting_repository.dart';
import '../services/local_storage_service.dart';
import '../services/meeting_websocket_service.dart';
import '../services/resource_cache_service.dart';

class AppController extends ChangeNotifier {
  AppController({
    required MeetingRepository repository,
    required MeetingWebSocketService websocketService,
    required LocalStorageService localStorageService,
    required ResourceCacheService resourceCacheService,
  })  : _repository = repository,
        _websocketService = websocketService,
        _localStorageService = localStorageService,
        _resourceCacheService = resourceCacheService,
        config = ConnectionConfig(
          serverIp: '127.0.0.1',
          port: 48080,
          roomName: '未配置',
          seatName: '未配置',
          deviceName: '客户端设备',
        ),
        session = MeetingSession(
          meetingId: 'bootstrap',
          meetingName: '会议加载中',
          description: '正在初始化会议数据',
          topics: <MeetingTopic>[MeetingTopic(id: 'loading', title: '初始化议题')],
          documents: <MeetingDocument>[
            MeetingDocument(
              id: 'loading-doc',
              topicId: 'loading',
              title: '初始化文稿',
              pageCount: 1,
              summary: '正在加载本地缓存和服务器会议数据。',
              fileType: 'placeholder',
            ),
          ],
          videoTitles: const <String>[],
          libraryTitles: const <String>[],
          users: const <MeetingUser>[],
          notices: <MeetingNotice>[
            MeetingNotice(
              id: 'bootstrap',
              title: '初始化中',
              content: '客户端正在读取本地配置并尝试连接会议服务。',
              createdAt: DateTime.now(),
            ),
          ],
          voteItem: VoteItem(
            id: 'bootstrap-vote',
            title: '初始化表决',
            description: '初始化表决',
            anonymous: false,
            stage: VoteStage.idle,
            options: <VoteOption>[VoteOption(id: 'init', label: '初始化')],
            votedUserIds: <String>{},
          ),
          serviceRequests: const <ServiceRequest>[],
          syncRequests: const <SyncRequest>[],
          watermarkEnabled: false,
        ),
        selectedTopicId = 'loading',
        selectedDocumentId = 'loading-doc',
        currentPage = 1,
        timerState = TimerState(
          totalSeconds: 300,
          remainingSeconds: 300,
          running: false,
          countDown: true,
        );

  final MeetingRepository _repository;
  final MeetingWebSocketService _websocketService;
  final LocalStorageService _localStorageService;
  final ResourceCacheService _resourceCacheService;

  ConnectionConfig config;
  MeetingSession session;
  MeetingUser? currentUser;
  bool isConfigured = false;
  bool isDarkMode = false;
  bool annotationEnabled = false;
  bool followSync = true;
  bool syncActive = false;
  String selectedTopicId;
  String selectedDocumentId;
  int currentPage;
  int noticeIndex = 0;
  int currentHomeIndex = 0;
  ConnectionStatus connectionStatus = ConnectionStatus.online;
  DateTime? lastSyncTime;
  bool bootstrapping = false;
  String? bootstrapError;
  String? sessionMessage;
  bool preloading = false;
  double preloadProgress = 0;
  bool refreshingDocuments = false;
  bool refreshingNotices = false;
  bool refreshingVotes = false;
  bool submittingSignature = false;
  bool realtimeConnecting = false;
  bool realtimeEnabled = false;
  String? realtimeEndpoint;
  final List<NoteEntry> notes = <NoteEntry>[];
  final List<BookmarkEntry> bookmarks = <BookmarkEntry>[];
  final List<Offset?> signaturePoints = <Offset?>[];
  final List<SyncEnvelope> messageLog = <SyncEnvelope>[];
  final Map<String, String> cachedResources = <String, String>{};
  final List<String> recentDocumentIds = <String>[];
  final List<String> readNoticeIds = <String>[];
  final List<String> pinnedNoticeIds = <String>[];
  String? lastSignedInUserId;
  MeetingUser? _restoredCurrentUser;
  bool noticeAutoPlay = false;
  TimerState timerState;
  Timer? _timer;
  Timer? _preloadTimer;
  Timer? _networkTimer;
  Timer? _noticeTimer;

  Future<void> restoreLocalState() async {
    try {
      final snapshot = await _localStorageService.load();
      if (snapshot.config != null) {
        config = snapshot.config!;
      }
      isConfigured = snapshot.isConfigured;
      isDarkMode = snapshot.isDarkMode;
      notes
        ..clear()
        ..addAll(snapshot.notes);
      bookmarks
        ..clear()
        ..addAll(snapshot.bookmarks);
      cachedResources
        ..clear()
        ..addAll(snapshot.cachedResources);
      recentDocumentIds
        ..clear()
        ..addAll(snapshot.recentDocumentIds);
      readNoticeIds
        ..clear()
        ..addAll(snapshot.readNoticeIds);
      pinnedNoticeIds
        ..clear()
        ..addAll(snapshot.pinnedNoticeIds);
      lastSignedInUserId = snapshot.lastSignedInUserId;
      _restoredCurrentUser = snapshot.currentUser;
      noticeAutoPlay = snapshot.noticeAutoPlay;
      _syncNoticeAutoPlayTimer();
      _startNetworkMonitor();
      unawaited(recheckNetworkStatus());
      notifyListeners();
      if (isConfigured) {
        unawaited(loadBootstrapData());
      }
    } catch (error) {
      bootstrapError = '读取本地配置失败：$error';
      notifyListeners();
    }
  }

  List<MeetingDocument> get currentTopicDocuments {
    return session.documents.where((item) => item.topicId == selectedTopicId).toList();
  }

  MeetingDocument? get currentDocumentOrNull {
    for (final item in session.documents) {
      if (item.id == selectedDocumentId) {
        return item;
      }
    }
    final topicDocuments = currentTopicDocuments;
    if (topicDocuments.isNotEmpty) {
      return topicDocuments.first;
    }
    if (session.documents.isNotEmpty) {
      return session.documents.first;
    }
    return null;
  }

  MeetingDocument get currentDocument {
    return currentDocumentOrNull ??
        MeetingDocument(
          id: 'empty-document',
          topicId: '',
          title: '暂无文稿',
          pageCount: 1,
          summary: '当前会议暂无可阅读文稿。',
        );
  }

  MeetingNotice? get currentNoticeOrNull {
    if (session.notices.isEmpty) {
      return null;
    }
    final index = noticeIndex.clamp(0, session.notices.length - 1);
    return session.notices[index];
  }

  MeetingNotice get currentNotice =>
      currentNoticeOrNull ??
      MeetingNotice(
        id: 'empty-notice',
        title: '暂无通知',
        content: '当前会议还没有可查看的通知。',
        createdAt: DateTime.now(),
      );

  bool get isSecretaryMode {
    return currentUser?.role == UserRole.secretary || currentUser?.role == UserRole.host;
  }

  String get currentSyncRoleLabel {
    final userId = currentUser?.id;
    if (userId == null) {
      return '未登录';
    }
    final activeRequest = session.syncRequests
        .where((item) => item.status == SyncRequestStatus.approved || item.status == SyncRequestStatus.pending)
        .cast<SyncRequest?>()
        .firstWhere((item) => item != null, orElse: () => null);
    if (activeRequest == null) {
      return followSync ? '跟随者' : '自由阅读者';
    }
    if (activeRequest.requesterUserId == userId) {
      return '发起人';
    }
    if (activeRequest.approverUserId == userId) {
      return '审批人';
    }
    if (followSync) {
      return '跟随者';
    }
    return '自由阅读者';
  }

  List<HomeModule> get modules {
    const base = <HomeModule>[
      HomeModule.info,
      HomeModule.document,
      HomeModule.media,
      HomeModule.library,
      HomeModule.vote,
      HomeModule.signature,
      HomeModule.service,
      HomeModule.notice,
      HomeModule.timer,
    ];
    return isSecretaryMode ? <HomeModule>[...base, HomeModule.secretary] : base;
  }

  Future<void> loadBootstrapData() async {
    bootstrapping = true;
    bootstrapError = null;
    notifyListeners();
    try {
      final seed = await _repository.loadBootstrapData(config);
      config = seed.config;
      session = seed.session;
      selectedTopicId = seed.session.topics.isNotEmpty ? seed.session.topics.first.id : selectedTopicId;
      selectedDocumentId = seed.session.documents.isNotEmpty ? seed.session.documents.first.id : selectedDocumentId;
      currentPage = 1;
      _normalizeSelection();
      _restoreCurrentUserIfPossible();
      lastSyncTime = DateTime.now();
      _startNetworkMonitor();
      unawaited(recheckNetworkStatus());
      if (currentUser?.accessToken?.isNotEmpty == true) {
        unawaited(_connectRealtime(currentUser!));
      }
    } catch (error) {
      bootstrapError = '$error';
    } finally {
      bootstrapping = false;
      notifyListeners();
    }
  }

  void completeConfiguration({
    required String serverIp,
    required int port,
    required String roomName,
    required String seatName,
    required String deviceName,
  }) {
    config = config.copyWith(
      serverIp: serverIp,
      port: port,
      roomName: roomName,
      seatName: seatName,
      deviceName: deviceName,
    );
    isConfigured = true;
    unawaited(_localStorageService.saveConfig(config, isConfigured: isConfigured));
    _startNetworkMonitor();
    unawaited(recheckNetworkStatus());
    unawaited(loadBootstrapData());
    notifyListeners();
  }

  Future<String?> signIn({
    required MeetingUser user,
    String password = '',
  }) async {
    if (user.requiresPassword && user.password != password) {
      return '密码不正确';
    }
    try {
      currentUser = await _repository.signIn(
        config: config,
        session: session,
        user: user,
        password: password,
      );
    } catch (error) {
      return '$error';
    }
    if (currentUser?.accessToken?.isNotEmpty == true) {
      unawaited(_connectRealtime(currentUser!));
    } else {
      realtimeEnabled = false;
      realtimeConnecting = false;
      realtimeEndpoint = null;
      connectionStatus = ConnectionStatus.offline;
    }
    sessionMessage = null;
    lastSignedInUserId = currentUser?.id;
    unawaited(_localStorageService.saveLastSignedInUserId(lastSignedInUserId));
    unawaited(_localStorageService.saveCurrentUser(currentUser));
    notifyListeners();
    return null;
  }

  void signOut({bool preserveSessionMessage = false}) {
    unawaited(_disconnectRealtime());
    currentUser = null;
    annotationEnabled = false;
    followSync = true;
    syncActive = false;
    currentHomeIndex = 0;
    currentPage = 1;
    signaturePoints.clear();
    _restoredCurrentUser = null;
    if (!preserveSessionMessage) {
      sessionMessage = null;
    }
    _noticeTimer?.cancel();
    unawaited(_localStorageService.saveCurrentUser(null));
    stopTimer(reset: true);
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    unawaited(_localStorageService.saveDarkMode(isDarkMode));
    notifyListeners();
  }

  void selectHomeModule(int index) {
    currentHomeIndex = index;
    notifyListeners();
  }

  void selectTopic(String topicId) {
    selectedTopicId = topicId;
    final topicDocs = currentTopicDocuments;
    if (topicDocs.isNotEmpty) {
      selectedDocumentId = topicDocs.first.id;
      currentPage = 1;
    } else {
      selectedDocumentId = '';
    }
    notifyListeners();
  }

  void selectDocument(String documentId) {
    if (!session.documents.any((item) => item.id == documentId)) {
      return;
    }
    selectedDocumentId = documentId;
    currentPage = 1;
    _recordRecentDocument(documentId);
    notifyListeners();
  }

  void nextPage() {
    final document = currentDocumentOrNull;
    if (document != null && currentPage < document.pageCount) {
      currentPage += 1;
      notifyListeners();
    }
  }

  void previousPage() {
    if (currentPage > 1) {
      currentPage -= 1;
      notifyListeners();
    }
  }

  void jumpToPage(int page) {
    final document = currentDocumentOrNull;
    if (document == null) {
      return;
    }
    final targetPage = page < 1
        ? 1
        : page > document.pageCount
            ? document.pageCount
            : page;
    if (targetPage == currentPage) {
      return;
    }
    currentPage = targetPage;
    notifyListeners();
  }

  void toggleAnnotation() {
    annotationEnabled = !annotationEnabled;
    notifyListeners();
  }

  void addNote(String content) {
    notes.add(NoteEntry(page: currentPage, content: content, createdBy: currentUser?.name ?? '未知用户'));
    unawaited(_localStorageService.saveNotes(notes));
    notifyListeners();
  }

  void addBookmark(String label) {
    bookmarks.add(BookmarkEntry(page: currentPage, label: label));
    unawaited(_localStorageService.saveBookmarks(bookmarks));
    notifyListeners();
  }

  void requestSync() {
    final user = currentUser;
    final document = currentDocumentOrNull;
    if (user == null || document == null) {
      return;
    }
    if (realtimeEnabled) {
      _sendRealtime(
        type: 'meeting-sync-request-send',
        payload: <String, dynamic>{
          'meetingId': int.tryParse(session.meetingId) ?? 0,
          'requesterName': user.name,
          'requesterSeatName': user.seatName,
          'documentId': selectedDocumentId,
          'documentTitle': document.title,
          'page': currentPage,
          'status': 'pending',
        },
      );
    } else {
      final request = SyncRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        requesterUserId: user.id,
        requesterName: user.name,
        requesterSeatName: user.seatName,
        documentId: selectedDocumentId,
        documentTitle: document.title,
        page: currentPage,
        status: isSecretaryMode ? SyncRequestStatus.approved : SyncRequestStatus.pending,
      );
      session = _copySession(syncRequests: <SyncRequest>[request, ...session.syncRequests]);
    }
    _logMessage(
      SyncMessageType.syncRequest,
      <String, dynamic>{'documentTitle': document.title, 'requester': user.name},
    );
    syncActive = isSecretaryMode;
    notifyListeners();
  }

  void stopSync() {
    syncActive = false;
    final document = currentDocumentOrNull;
    if (realtimeEnabled) {
      _sendRealtime(
        type: 'meeting-sync-status-send',
        payload: <String, dynamic>{
          'meetingId': int.tryParse(session.meetingId) ?? 0,
          'requestId': '',
          'status': 'stopped',
          'documentId': selectedDocumentId,
          'documentTitle': document?.title ?? '未命名文稿',
          'page': currentPage,
        },
      );
    }
    notifyListeners();
  }

  void leaveSync() {
    followSync = false;
    notifyListeners();
  }

  void returnToSync() {
    followSync = true;
    notifyListeners();
  }

  void playVideoSync() {
    syncActive = true;
    _logMessage(SyncMessageType.syncApproved, <String, dynamic>{'videoSync': true});
    notifyListeners();
  }

  void vote(String optionId) {
    final userId = currentUser?.id;
    if (userId == null || session.voteItem.stage != VoteStage.active || session.voteItem.votedUserIds.contains(userId)) {
      return;
    }
    final options = session.voteItem.options
        .map((item) => item.id == optionId ? item.copyWith(count: item.count + 1) : item)
        .toList();
    final voted = Set<String>.from(session.voteItem.votedUserIds)..add(userId);
    session = _copySession(voteItem: session.voteItem.copyWith(options: options, votedUserIds: voted));
    unawaited(_repository.submitVote(
      config: config,
      userId: userId,
      voteId: session.voteItem.id,
      optionId: optionId,
    ));
    notifyListeners();
  }

  void startVote() {
    if (realtimeEnabled) {
      _sendRealtime(
        type: 'meeting-vote-start-send',
        payload: <String, dynamic>{
          'meetingId': int.tryParse(session.meetingId) ?? 0,
          'voteId': int.tryParse(session.voteItem.id) ?? 0,
        },
      );
    }
    session = _copySession(voteItem: session.voteItem.copyWith(stage: VoteStage.active));
    _logMessage(SyncMessageType.voteStarted, <String, dynamic>{'voteId': session.voteItem.id});
    notifyListeners();
  }

  void resetVote() {
    final resetOptions = session.voteItem.options.map((item) => item.copyWith(count: 0)).toList();
    session = _copySession(
      voteItem: session.voteItem.copyWith(
        stage: VoteStage.idle,
        options: resetOptions,
        votedUserIds: <String>{},
      ),
    );
    notifyListeners();
  }

  void finishVote() {
    if (realtimeEnabled) {
      _sendRealtime(
        type: 'meeting-vote-finish-send',
        payload: <String, dynamic>{
          'meetingId': int.tryParse(session.meetingId) ?? 0,
          'voteId': int.tryParse(session.voteItem.id) ?? 0,
        },
      );
    }
    session = _copySession(voteItem: session.voteItem.copyWith(stage: VoteStage.finished));
    notifyListeners();
  }

  void publishVote() {
    if (realtimeEnabled) {
      _sendRealtime(
        type: 'meeting-vote-publish-send',
        payload: <String, dynamic>{
          'meetingId': int.tryParse(session.meetingId) ?? 0,
          'voteId': int.tryParse(session.voteItem.id) ?? 0,
        },
      );
    }
    session = _copySession(voteItem: session.voteItem.copyWith(stage: VoteStage.published));
    _logMessage(SyncMessageType.votePublished, <String, dynamic>{'voteId': session.voteItem.id});
    notifyListeners();
  }

  void addServiceRequest({
    required String category,
    required String detail,
  }) {
    final user = currentUser;
    if (user == null) return;
    if (realtimeEnabled) {
      _sendRealtime(
        type: 'meeting-service-request-send',
        payload: <String, dynamic>{
          'meetingId': int.tryParse(session.meetingId) ?? 0,
          'requesterName': user.name,
          'requesterSeatName': user.seatName,
          'category': category,
          'detail': detail,
          'status': 'pending',
        },
      );
    } else {
      session = _copySession(
        serviceRequests: <ServiceRequest>[
          ServiceRequest(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            requesterUserId: user.id,
            requesterName: user.name,
            seatName: user.seatName,
            category: category,
            detail: detail,
            status: ServiceStatus.pending,
          ),
          ...session.serviceRequests,
        ],
      );
    }
    _logMessage(SyncMessageType.serviceRequested, <String, dynamic>{'category': category, 'requester': user.name});
    notifyListeners();
  }

  void updateServiceStatus(String requestId, ServiceStatus status) {
    session = _copySession(
      serviceRequests: session.serviceRequests
          .map(
            (item) => item.id == requestId
                ? item.copyWith(
                    status: status,
                    handlerUserId: currentUser?.id,
                    handlerName: currentUser?.name,
                  )
                : item,
          )
          .toList(),
    );
    if (realtimeEnabled) {
      final item = session.serviceRequests.firstWhere((entry) => entry.id == requestId);
      _sendRealtime(
        type: 'meeting-service-status-send',
        payload: <String, dynamic>{
          'meetingId': int.tryParse(session.meetingId) ?? 0,
          'requestId': requestId,
          'requesterUserId': int.tryParse(item.requesterUserId ?? ''),
          'requesterName': item.requesterName,
          'requesterSeatName': item.seatName,
          'category': item.category,
          'detail': item.detail,
          'status': _serviceStatusCode(status),
          'handlerName': currentUser?.name,
        },
      );
    }
    _logMessage(SyncMessageType.serviceUpdated, <String, dynamic>{'requestId': requestId, 'status': status.label});
    notifyListeners();
  }

  void approveSync(String requestId) {
    session = _copySession(
      syncRequests: session.syncRequests
          .map(
            (item) => item.id == requestId
                ? item.copyWith(
                    status: SyncRequestStatus.approved,
                    approverUserId: currentUser?.id,
                    approverName: currentUser?.name,
                  )
                : item,
          )
          .toList(),
    );
    syncActive = true;
    followSync = true;
    if (realtimeEnabled) {
      final item = session.syncRequests.firstWhere((entry) => entry.id == requestId);
      _sendRealtime(
        type: 'meeting-sync-status-send',
        payload: <String, dynamic>{
          'meetingId': int.tryParse(session.meetingId) ?? 0,
          'requestId': requestId,
          'requesterUserId': int.tryParse(item.requesterUserId ?? ''),
          'requesterName': item.requesterName,
          'requesterSeatName': item.requesterSeatName,
          'documentId': item.documentId,
          'documentTitle': item.documentTitle,
          'page': item.page,
          'status': 'approved',
          'approverName': currentUser?.name,
        },
      );
    }
    _logMessage(SyncMessageType.syncApproved, <String, dynamic>{'requestId': requestId});
    notifyListeners();
  }

  void rejectSync(String requestId) {
    session = _copySession(
      syncRequests: session.syncRequests
          .map(
            (item) => item.id == requestId
                ? item.copyWith(
                    status: SyncRequestStatus.rejected,
                    approverUserId: currentUser?.id,
                    approverName: currentUser?.name,
                  )
                : item,
          )
          .toList(),
    );
    if (realtimeEnabled) {
      final item = session.syncRequests.firstWhere((entry) => entry.id == requestId);
      _sendRealtime(
        type: 'meeting-sync-status-send',
        payload: <String, dynamic>{
          'meetingId': int.tryParse(session.meetingId) ?? 0,
          'requestId': requestId,
          'requesterUserId': int.tryParse(item.requesterUserId ?? ''),
          'requesterName': item.requesterName,
          'requesterSeatName': item.requesterSeatName,
          'documentId': item.documentId,
          'documentTitle': item.documentTitle,
          'page': item.page,
          'status': 'rejected',
          'approverName': currentUser?.name,
        },
      );
    }
    _logMessage(SyncMessageType.syncRejected, <String, dynamic>{'requestId': requestId});
    notifyListeners();
  }

  void broadcastNotice(String title, String content) {
    final user = currentUser;
    if (realtimeEnabled && user != null) {
      _sendRealtime(
        type: 'meeting-notice-publish-send',
        payload: <String, dynamic>{
          'meetingId': int.tryParse(session.meetingId) ?? 0,
          'title': title,
          'content': content,
        },
      );
      return;
    }
    session = _copySession(
      notices: <MeetingNotice>[
        MeetingNotice(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          content: content,
          createdAt: DateTime.now(),
        ),
        ...session.notices,
      ],
    );
    noticeIndex = 0;
    _logMessage(SyncMessageType.noticePublished, <String, dynamic>{'title': title});
    notifyListeners();
  }

  void forceStopSync() {
    syncActive = false;
    followSync = false;
    final document = currentDocumentOrNull;
    if (realtimeEnabled) {
      _sendRealtime(
        type: 'meeting-sync-status-send',
        payload: <String, dynamic>{
          'meetingId': int.tryParse(session.meetingId) ?? 0,
          'requestId': 'all',
          'status': 'stopped',
          'documentId': selectedDocumentId,
          'documentTitle': document?.title ?? '未命名文稿',
          'page': currentPage,
          'approverName': currentUser?.name,
        },
      );
    }
    _logMessage(SyncMessageType.syncStopped, <String, dynamic>{'forced': true});
    notifyListeners();
  }

  void forceReturnSync() {
    final user = currentUser;
    if (realtimeEnabled && user != null) {
      _sendRealtime(
        type: 'meeting-force-return-send',
        payload: <String, dynamic>{
          'meetingId': int.tryParse(session.meetingId) ?? 0,
          'operatorUserId': int.tryParse(user.id),
          'operatorName': user.name,
        },
      );
      return;
    }
    syncActive = true;
    followSync = true;
    _logMessage(SyncMessageType.forceReturn, <String, dynamic>{'forced': true});
    notifyListeners();
  }

  void forceLogoutUser(MeetingUser targetUser) {
    final user = currentUser;
    if (realtimeEnabled && user != null) {
      _sendRealtime(
        type: 'meeting-force-logout-send',
        payload: <String, dynamic>{
          'meetingId': int.tryParse(session.meetingId) ?? 0,
          'operatorUserId': int.tryParse(user.id),
          'operatorName': user.name,
          'targetUserId': int.tryParse(targetUser.id),
          'targetUserName': targetUser.name,
          'content': '${user.name} 已将 ${targetUser.name} 强制注销签到',
        },
      );
      return;
    }
    if (currentUser?.id == targetUser.id) {
      sessionMessage = '当前终端已被强制注销，请重新签到。';
      signOut(preserveSessionMessage: true);
    }
  }

  Future<void> recheckNetworkStatus() async {
    if (!isConfigured) {
      connectionStatus = ConnectionStatus.offline;
      notifyListeners();
      return;
    }
    connectionStatus = ConnectionStatus.reconnecting;
    notifyListeners();
    final reachable = await _isServerReachable();
    if (!reachable) {
      connectionStatus = ConnectionStatus.offline;
      if (realtimeEnabled || realtimeConnecting) {
        await _disconnectRealtime();
      }
      notifyListeners();
      return;
    }
    connectionStatus = ConnectionStatus.online;
    lastSyncTime = DateTime.now();
    if (currentUser != null) {
      unawaited(refreshRealtimeState());
      unawaited(refreshNotices());
      unawaited(refreshVotes());
    }
    if (currentUser?.accessToken?.isNotEmpty == true && !realtimeEnabled && !realtimeConnecting) {
      unawaited(_connectRealtime(currentUser!));
    }
    notifyListeners();
  }

  void simulatePreload() {
    unawaited(preloadResources());
  }

  Future<void> preloadResources() async {
    _preloadTimer?.cancel();
    final urls = session.documents
        .map((item) => item.fileUrl)
        .whereType<String>()
        .map(_resolveResourceUrl)
        .whereType<String>()
        .toList();
    if (urls.isEmpty) {
      preloading = false;
      preloadProgress = 1;
      notifyListeners();
      return;
    }
    preloading = true;
    preloadProgress = 0;
    notifyListeners();
    try {
      final result = await _resourceCacheService.warmupResources(
        urls,
        onProgress: (progress) {
          preloadProgress = progress;
          notifyListeners();
        },
      );
      cachedResources.addAll(result.cachedByUrl);
      unawaited(_localStorageService.saveCachedResources(cachedResources));
      lastSyncTime = DateTime.now();
    } finally {
      preloading = false;
      if (preloadProgress < 1) {
        preloadProgress = 1;
      }
      notifyListeners();
    }
  }

  Future<void> refreshDocuments() async {
    refreshingDocuments = true;
    notifyListeners();
    try {
      final documents = await _repository.fetchDocuments(
        config: config,
        meetingId: session.meetingId,
      );
      session = _copySession(documents: documents);
      if (documents.isNotEmpty) {
        selectedDocumentId = documents.first.id;
      } else {
        selectedDocumentId = '';
      }
      _recordRecentDocument(selectedDocumentId);
      _normalizeSelection();
      lastSyncTime = DateTime.now();
    } finally {
      refreshingDocuments = false;
      notifyListeners();
    }
  }

  Future<void> refreshNotices() async {
    refreshingNotices = true;
    notifyListeners();
    try {
      final notices = await _repository.fetchNotices(
        config: config,
        meetingId: session.meetingId,
      );
      session = _copySession(notices: notices);
      _normalizeNoticeCollections();
      noticeIndex = 0;
      _normalizeNoticeIndex();
      lastSyncTime = DateTime.now();
    } finally {
      refreshingNotices = false;
      notifyListeners();
    }
  }

  Future<void> refreshVotes() async {
    refreshingVotes = true;
    notifyListeners();
    try {
      final vote = await _repository.fetchCurrentVote(
        config: config,
        meetingId: session.meetingId,
        userId: currentUser?.id,
      );
      if (vote != null) {
        session = _copySession(voteItem: vote);
      }
      lastSyncTime = DateTime.now();
    } finally {
      refreshingVotes = false;
      notifyListeners();
    }
  }

  Future<void> refreshRealtimeState() async {
    try {
      final snapshot = await _repository.fetchRealtimeState(
        config: config,
        meetingId: session.meetingId,
      );
      session = _copySession(
        syncRequests: snapshot.syncRequests,
        serviceRequests: snapshot.serviceRequests,
      );
      lastSyncTime = DateTime.now();
      notifyListeners();
    } catch (_) {
      // Websocket recovery can proceed even if the snapshot endpoint is temporarily unavailable.
    }
  }

  void previousNotice() {
    if (session.notices.isNotEmpty && noticeIndex > 0) {
      noticeIndex -= 1;
      markCurrentNoticeRead();
      notifyListeners();
    }
  }

  void nextNotice() {
    if (session.notices.isNotEmpty && noticeIndex < session.notices.length - 1) {
      noticeIndex += 1;
      markCurrentNoticeRead();
      notifyListeners();
    }
  }

  void markCurrentNoticeRead() {
    final notice = currentNoticeOrNull;
    if (notice == null || readNoticeIds.contains(notice.id)) {
      return;
    }
    readNoticeIds.add(notice.id);
    unawaited(_localStorageService.saveReadNoticeIds(readNoticeIds));
    notifyListeners();
  }

  bool isNoticeRead(String noticeId) => readNoticeIds.contains(noticeId);

  bool isNoticePinned(String noticeId) => pinnedNoticeIds.contains(noticeId);

  void toggleNoticePinned(String noticeId) {
    if (pinnedNoticeIds.contains(noticeId)) {
      pinnedNoticeIds.remove(noticeId);
    } else {
      pinnedNoticeIds.add(noticeId);
    }
    _normalizeNoticeCollections();
    unawaited(_localStorageService.savePinnedNoticeIds(pinnedNoticeIds));
    notifyListeners();
  }

  void toggleNoticeAutoPlay() {
    noticeAutoPlay = !noticeAutoPlay;
    _syncNoticeAutoPlayTimer();
    unawaited(_localStorageService.saveNoticeAutoPlay(noticeAutoPlay));
    notifyListeners();
  }

  void setTimer({
    required int minutes,
    required bool countDown,
  }) {
    final seconds = minutes * 60;
    timerState = TimerState(
      totalSeconds: seconds,
      remainingSeconds: countDown ? seconds : 0,
      running: false,
      countDown: countDown,
    );
    _timer?.cancel();
    notifyListeners();
  }

  void startTimer() {
    _timer?.cancel();
    timerState = timerState.copyWith(running: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!timerState.running) return;
      if (timerState.countDown) {
        if (timerState.remainingSeconds <= 0) {
          stopTimer();
          return;
        }
        timerState = timerState.copyWith(remainingSeconds: timerState.remainingSeconds - 1);
      } else {
        timerState = timerState.copyWith(remainingSeconds: timerState.remainingSeconds + 1);
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void stopTimer({bool reset = false}) {
    _timer?.cancel();
    timerState = timerState.copyWith(
      running: false,
      remainingSeconds: reset ? (timerState.countDown ? timerState.totalSeconds : 0) : timerState.remainingSeconds,
    );
    notifyListeners();
  }

  void addSignaturePoint(Offset point) {
    signaturePoints.add(point);
    notifyListeners();
  }

  void addSignatureBreak() {
    signaturePoints.add(null);
    notifyListeners();
  }

  void clearSignature() {
    signaturePoints.clear();
    notifyListeners();
  }

  Future<String?> submitSignature(List<int> pngBytes) async {
    final user = currentUser;
    if (user == null) {
      return '当前未登录，无法提交签名';
    }
    final strokeCount = signaturePoints.whereType<Offset>().length;
    if (strokeCount == 0) {
      return '请先完成签名';
    }
    submittingSignature = true;
    notifyListeners();
    try {
      final result = await _repository.submitSignature(
        config: config,
        meetingId: session.meetingId,
        userId: user.id,
        pngBytes: pngBytes,
        strokeCount: strokeCount,
      );
      clearSignature();
      sessionMessage = '签名提交成功';
      broadcastNotice('签名已提交', '${user.name} 已完成电子签名提交。');
      return result.fileUrl;
    } catch (error) {
      return '签名提交失败：$error';
    } finally {
      submittingSignature = false;
      notifyListeners();
    }
  }

  void _logMessage(SyncMessageType type, Map<String, dynamic> payload) {
    messageLog.insert(
      0,
      SyncEnvelope(
        type: type,
        meetingId: session.meetingId,
        timestamp: DateTime.now(),
        payload: payload,
      ),
    );
    lastSyncTime = DateTime.now();
  }

  void applyEnvelope(SyncEnvelope envelope) {
    _logMessage(envelope.type, envelope.payload);
    switch (envelope.type) {
      case SyncMessageType.noticePublished:
        final notice = MeetingNotice(
          id: '${envelope.payload['noticeId'] ?? DateTime.now().millisecondsSinceEpoch}',
          title: '${envelope.payload['title'] ?? '会议通知'}',
          content: '${envelope.payload['content'] ?? ''}',
          createdAt: DateTime.tryParse('${envelope.payload['publishedTime'] ?? ''}') ?? DateTime.now(),
        );
        session = _copySession(notices: <MeetingNotice>[notice, ...session.notices]);
        _normalizeNoticeCollections();
        noticeIndex = 0;
        _normalizeNoticeIndex();
        break;
      case SyncMessageType.syncRequest:
        session = _copySession(syncRequests: _mergeSyncRequest(_syncRequestFromEnvelope(envelope)));
        break;
      case SyncMessageType.syncApproved:
        syncActive = true;
        followSync = true;
        session = _copySession(syncRequests: _mergeSyncRequest(_syncRequestFromEnvelope(envelope)));
        break;
      case SyncMessageType.syncRejected:
        session = _copySession(syncRequests: _mergeSyncRequest(_syncRequestFromEnvelope(envelope)));
        break;
      case SyncMessageType.syncStopped:
        syncActive = false;
        followSync = false;
        session = _copySession(syncRequests: _markSyncStopped(envelope));
        break;
      case SyncMessageType.serviceRequested:
        session = _copySession(serviceRequests: _mergeServiceRequest(_serviceRequestFromEnvelope(envelope)));
        break;
      case SyncMessageType.serviceUpdated:
        session = _copySession(serviceRequests: _mergeServiceRequest(_serviceRequestFromEnvelope(envelope)));
        break;
      case SyncMessageType.voteStarted:
        session = _copySession(
          voteItem: session.voteItem.copyWith(
            id: '${envelope.payload['voteId'] ?? session.voteItem.id}',
            title: '${envelope.payload['title'] ?? session.voteItem.title}',
            stage: VoteStage.active,
          ),
        );
        break;
      case SyncMessageType.voteFinished:
        session = _copySession(voteItem: session.voteItem.copyWith(stage: VoteStage.finished));
        break;
      case SyncMessageType.votePublished:
        session = _copySession(
          voteItem: session.voteItem.copyWith(
            id: '${envelope.payload['voteId'] ?? session.voteItem.id}',
            title: '${envelope.payload['title'] ?? session.voteItem.title}',
            stage: VoteStage.published,
          ),
        );
        break;
      case SyncMessageType.forceReturn:
        syncActive = true;
        followSync = true;
        break;
      case SyncMessageType.forceLogout:
        final targetUserId = '${envelope.payload['targetUserId'] ?? ''}';
        if (targetUserId.isEmpty || targetUserId == currentUser?.id) {
          final operatorName = '${envelope.payload['operatorName'] ?? '会议秘书'}';
          sessionMessage = '$operatorName 已将当前终端强制注销，请重新签到。';
          signOut(preserveSessionMessage: true);
          return;
        }
        break;
    }
    notifyListeners();
  }

  void _normalizeSelection() {
    if (session.topics.isNotEmpty && !session.topics.any((item) => item.id == selectedTopicId)) {
      selectedTopicId = session.topics.first.id;
    }
    if (session.documents.isEmpty) {
      selectedDocumentId = '';
      currentPage = 1;
      return;
    }
    final document = currentDocumentOrNull;
    if (document == null) {
      selectedDocumentId = session.documents.first.id;
      currentPage = 1;
      return;
    }
    selectedDocumentId = document.id;
    if (currentPage > document.pageCount) {
      currentPage = document.pageCount;
    }
    if (currentPage < 1) {
      currentPage = 1;
    }
  }

  void _normalizeNoticeIndex() {
    if (session.notices.isEmpty) {
      noticeIndex = 0;
      return;
    }
    noticeIndex = noticeIndex.clamp(0, session.notices.length - 1);
  }

  void _normalizeNoticeCollections() {
    if (session.notices.isEmpty) {
      return;
    }
    final pinned = session.notices.where((item) => pinnedNoticeIds.contains(item.id)).toList();
    final normal = session.notices.where((item) => !pinnedNoticeIds.contains(item.id)).toList();
    session = _copySession(notices: <MeetingNotice>[...pinned, ...normal]);
  }

  void _syncNoticeAutoPlayTimer() {
    _noticeTimer?.cancel();
    if (!noticeAutoPlay) {
      return;
    }
    _noticeTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (session.notices.length <= 1) {
        return;
      }
      if (noticeIndex >= session.notices.length - 1) {
        noticeIndex = 0;
      } else {
        noticeIndex += 1;
      }
      markCurrentNoticeRead();
      notifyListeners();
    });
  }

  String? resolveCachedResourcePath(String? rawUrl) {
    final url = _resolveResourceUrl(rawUrl);
    if (url == null || url.isEmpty) {
      return null;
    }
    return cachedResources[url];
  }

  Future<void> rememberCachedResource(String url) async {
    try {
      final path = await _resourceCacheService.cacheResource(url);
      cachedResources[url] = path;
      unawaited(_localStorageService.saveCachedResources(cachedResources));
      notifyListeners();
    } catch (_) {
      // Keep the UI responsive; callers handle visible failures.
    }
  }

  void rememberRecentResource(String documentId) {
    _recordRecentDocument(documentId);
    notifyListeners();
  }

  bool isResourceCached(String? rawUrl) {
    final resolved = _resolveResourceUrl(rawUrl);
    if (resolved == null) {
      return false;
    }
    return cachedResources.containsKey(resolved);
  }

  void _recordRecentDocument(String? documentId) {
    if (documentId == null || documentId.isEmpty) {
      return;
    }
    recentDocumentIds.remove(documentId);
    recentDocumentIds.insert(0, documentId);
    if (recentDocumentIds.length > 12) {
      recentDocumentIds.removeRange(12, recentDocumentIds.length);
    }
    unawaited(_localStorageService.saveRecentDocumentIds(recentDocumentIds));
  }

  String? _resolveResourceUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return null;
    }
    final normalized = rawUrl.trim();
    final uri = Uri.tryParse(normalized);
    if (uri != null && uri.hasScheme) {
      return uri.toString();
    }
    return Uri.http(
      '${config.serverIp}:${config.port}',
      normalized.startsWith('/') ? normalized : '/$normalized',
    ).toString();
  }

  Future<String?> exportMessageLog() async {
    if (messageLog.isEmpty) {
      return null;
    }
    final dir = await getApplicationCacheDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}meeting_message_log_${session.meetingId}.txt');
    final lines = messageLog
        .map((item) => '[${item.timestamp.toIso8601String()}] ${item.type.code} ${item.payload}')
        .join('\n');
    await file.writeAsString(lines, flush: true);
    return file.path;
  }

  void _restoreCurrentUserIfPossible() {
    final restored = _restoredCurrentUser;
    if (restored == null) {
      return;
    }
    if (restored.accessTokenExpiresAt != null && restored.accessTokenExpiresAt!.isBefore(DateTime.now())) {
      _restoredCurrentUser = null;
      unawaited(_localStorageService.saveCurrentUser(null));
      return;
    }
    final matchedUser = session.users.where((item) => item.id == restored.id).toList();
    if (matchedUser.isEmpty) {
      return;
    }
    currentUser = MeetingUser(
      id: restored.id,
      name: restored.name.isNotEmpty ? restored.name : matchedUser.first.name,
      role: restored.role,
      seatName: restored.seatName.isNotEmpty ? restored.seatName : matchedUser.first.seatName,
      signStatus: matchedUser.first.signStatus,
      password: matchedUser.first.password ?? restored.password,
      accessToken: restored.accessToken,
      accessTokenExpiresAt: restored.accessTokenExpiresAt,
      websocketPath: restored.websocketPath,
    );
    _restoredCurrentUser = null;
    sessionMessage = null;
    unawaited(_localStorageService.saveCurrentUser(currentUser));
  }

  void _sendRealtime({
    required String type,
    required Map<String, dynamic> payload,
  }) {
    _websocketService.send(type: type, payload: payload);
  }

  List<SyncRequest> _mergeSyncRequest(SyncRequest request) {
    final existing = session.syncRequests.where((item) => item.id != request.id).toList();
    return <SyncRequest>[request, ...existing];
  }

  List<SyncRequest> _markSyncStopped(SyncEnvelope envelope) {
    final requestId = '${envelope.payload['requestId'] ?? ''}';
    if (requestId.isEmpty || requestId == 'all') {
      return session.syncRequests
          .map((item) => item.copyWith(status: SyncRequestStatus.rejected))
          .toList();
    }
    return session.syncRequests
        .map(
          (item) => item.id == requestId ? item.copyWith(status: SyncRequestStatus.rejected) : item,
        )
        .toList();
  }

  List<ServiceRequest> _mergeServiceRequest(ServiceRequest request) {
    final existing = session.serviceRequests.where((item) => item.id != request.id).toList();
    return <ServiceRequest>[request, ...existing];
  }

  SyncRequest _syncRequestFromEnvelope(SyncEnvelope envelope) {
    return SyncRequest(
      id: '${envelope.payload['requestId'] ?? DateTime.now().millisecondsSinceEpoch}',
      requesterUserId: '${envelope.payload['requesterUserId'] ?? ''}',
      requesterName: '${envelope.payload['requesterName'] ?? '未知用户'}',
      requesterSeatName: '${envelope.payload['requesterSeatName'] ?? ''}',
      documentId: '${envelope.payload['documentId'] ?? ''}',
      documentTitle: '${envelope.payload['documentTitle'] ?? ''}',
      page: envelope.payload['page'] as int?,
      status: _syncRequestStatusFromCode('${envelope.payload['status'] ?? 'pending'}', envelope.type),
      approverUserId: '${envelope.payload['approverUserId'] ?? ''}',
      approverName: '${envelope.payload['approverName'] ?? ''}',
    );
  }

  ServiceRequest _serviceRequestFromEnvelope(SyncEnvelope envelope) {
    return ServiceRequest(
      id: '${envelope.payload['requestId'] ?? DateTime.now().millisecondsSinceEpoch}',
      requesterUserId: '${envelope.payload['requesterUserId'] ?? ''}',
      requesterName: '${envelope.payload['requesterName'] ?? '未知用户'}',
      seatName: '${envelope.payload['requesterSeatName'] ?? ''}',
      category: '${envelope.payload['category'] ?? '会务服务'}',
      detail: '${envelope.payload['detail'] ?? ''}',
      status: _serviceStatusFromCode('${envelope.payload['status'] ?? 'pending'}'),
      handlerUserId: '${envelope.payload['handlerUserId'] ?? ''}',
      handlerName: '${envelope.payload['handlerName'] ?? ''}',
    );
  }

  SyncRequestStatus _syncRequestStatusFromCode(String code, SyncMessageType type) {
    if (type == SyncMessageType.syncRejected || code.toLowerCase() == 'rejected') {
      return SyncRequestStatus.rejected;
    }
    if (type == SyncMessageType.syncApproved || code.toLowerCase() == 'approved') {
      return SyncRequestStatus.approved;
    }
    return SyncRequestStatus.pending;
  }

  ServiceStatus _serviceStatusFromCode(String code) {
    switch (code.toLowerCase()) {
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

  String _serviceStatusCode(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.processing:
        return 'processing';
      case ServiceStatus.completed:
        return 'completed';
      case ServiceStatus.canceled:
        return 'canceled';
      case ServiceStatus.pending:
        return 'pending';
    }
  }

  Future<void> _connectRealtime(MeetingUser user) async {
    final token = user.accessToken;
    if (token == null || token.isEmpty) {
      return;
    }
    realtimeConnecting = true;
    realtimeEnabled = false;
    connectionStatus = ConnectionStatus.reconnecting;
    final websocketPath = user.websocketPath ?? '/infra/ws';
    realtimeEndpoint = '${config.serverIp}:${config.port}$websocketPath';
    notifyListeners();
    try {
      await _websocketService.connect(
        host: config.serverIp,
        port: config.port,
        token: token,
        path: websocketPath,
        onConnected: () {
          realtimeConnecting = false;
          realtimeEnabled = true;
          connectionStatus = ConnectionStatus.online;
          lastSyncTime = DateTime.now();
          unawaited(refreshRealtimeState());
          notifyListeners();
        },
        onDisconnected: () {
          realtimeConnecting = false;
          realtimeEnabled = false;
          connectionStatus = ConnectionStatus.offline;
          notifyListeners();
        },
        onError: (Object error) {
          realtimeConnecting = false;
          realtimeEnabled = false;
          connectionStatus = ConnectionStatus.offline;
          bootstrapError = '实时连接失败：$error';
          notifyListeners();
        },
        onMessage: applyEnvelope,
      );
    } catch (error) {
      realtimeConnecting = false;
      realtimeEnabled = false;
      connectionStatus = ConnectionStatus.offline;
      bootstrapError = '实时连接失败：$error';
      notifyListeners();
    }
  }

  Future<void> _disconnectRealtime() async {
    await _websocketService.disconnect();
    realtimeConnecting = false;
    realtimeEnabled = false;
    realtimeEndpoint = null;
    connectionStatus = ConnectionStatus.offline;
  }

  void _startNetworkMonitor() {
    _networkTimer?.cancel();
    if (!isConfigured) {
      return;
    }
    _networkTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      unawaited(recheckNetworkStatus());
    });
  }

  Future<bool> _isServerReachable() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
    try {
      final uri = Uri.http('${config.serverIp}:${config.port}', '/meeting/app/bootstrap', <String, String>{
        'roomName': config.roomName,
        'seatName': config.seatName,
        'deviceName': config.deviceName,
      });
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 3));
      final response = await request.close().timeout(const Duration(seconds: 3));
      await response.drain<void>();
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }

  MeetingSession _copySession({
    VoteItem? voteItem,
    List<ServiceRequest>? serviceRequests,
    List<SyncRequest>? syncRequests,
    List<MeetingNotice>? notices,
    List<MeetingDocument>? documents,
  }) {
    return MeetingSession(
      meetingId: session.meetingId,
      meetingName: session.meetingName,
      description: session.description,
      topics: session.topics,
      documents: documents ?? session.documents,
      videoTitles: session.videoTitles,
      libraryTitles: session.libraryTitles,
      users: session.users,
      notices: notices ?? session.notices,
      voteItem: voteItem ?? session.voteItem,
      serviceRequests: serviceRequests ?? session.serviceRequests,
      syncRequests: syncRequests ?? session.syncRequests,
      watermarkEnabled: session.watermarkEnabled,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _preloadTimer?.cancel();
    _networkTimer?.cancel();
    _noticeTimer?.cancel();
    unawaited(_disconnectRealtime());
    super.dispose();
  }
}

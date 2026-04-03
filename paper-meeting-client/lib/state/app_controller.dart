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
          meetingPasswordRequired: false,
        ),
        selectedTopicId = 'loading',
        selectedDocumentId = 'loading-doc',
        currentPage = 1,
        timerState = TimerState(
          totalSeconds: 300,
          remainingSeconds: 300,
          running: false,
          countDown: true,
          controlled: false,
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
  int noticeTotal = 0;
  int noticePageNo = 1;
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
  bool loadingMoreNotices = false;
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
  bool allowOfflineBrowsing = false;
  VideoSyncState videoSyncState = const VideoSyncState();
  TimerState timerState;
  Timer? _timer;
  Timer? _preloadTimer;
  Timer? _networkTimer;
  Timer? _noticeTimer;
  Timer? _terminalHeartbeatTimer;

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
    return session.documents
        .where((item) => item.topicId == selectedTopicId)
        .toList();
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

  List<NoteEntry> get currentDocumentNotes {
    final documentId = selectedDocumentId;
    return notes
        .where((item) => (item.documentId ?? documentId) == documentId)
        .toList();
  }

  List<BookmarkEntry> get currentDocumentBookmarks {
    final documentId = selectedDocumentId;
    return bookmarks
        .where((item) => (item.documentId ?? documentId) == documentId)
        .toList();
  }

  bool get isSecretaryMode {
    return currentUser?.role == UserRole.secretary ||
        currentUser?.role == UserRole.host;
  }

  String get currentSyncRoleLabel {
    final userId = currentUser?.id;
    if (userId == null) {
      return '未登录';
    }
    final activeRequest = session.syncRequests
        .where((item) =>
            item.status == SyncRequestStatus.approved ||
            item.status == SyncRequestStatus.pending)
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

  bool get isBootstrapPlaceholder => session.meetingId == 'bootstrap';

  bool get hasNoActiveMeeting => session.meetingId == 'no-meeting';

  bool get shouldShowBootstrapFailure =>
      bootstrapError != null && !bootstrapping && isBootstrapPlaceholder;

  bool get hasOfflineContent {
    return session.documents.isNotEmpty ||
        session.notices.isNotEmpty ||
        cachedResources.isNotEmpty ||
        notes.isNotEmpty ||
        bookmarks.isNotEmpty;
  }

  bool get shouldShowRealtimeDisconnectedScreen {
    return currentUser != null &&
        currentUser!.accessToken?.isNotEmpty == true &&
        connectionStatus == ConnectionStatus.offline &&
        !bootstrapping &&
        !hasNoActiveMeeting &&
        !allowOfflineBrowsing;
  }

  Future<void> loadBootstrapData() async {
    bootstrapping = true;
    bootstrapError = null;
    notifyListeners();
    try {
      final seed = await _repository.loadBootstrapData(config);
      config = seed.config;
      session = seed.session;
      selectedTopicId = seed.session.topics.isNotEmpty
          ? seed.session.topics.first.id
          : selectedTopicId;
      selectedDocumentId = seed.session.documents.isNotEmpty
          ? seed.session.documents.first.id
          : selectedDocumentId;
      currentPage = 1;
      noticeTotal = seed.session.notices.length;
      noticePageNo = 1;
      allowOfflineBrowsing = false;
      _normalizeSelection();
      if (hasNoActiveMeeting) {
        currentUser = null;
        _restoredCurrentUser = null;
        sessionMessage = null;
        unawaited(_disconnectRealtime());
        unawaited(_localStorageService.saveCurrentUser(null));
      } else {
        _restoreCurrentUserIfPossible();
        if (currentUser != null) {
          unawaited(_syncDocumentMarks());
        }
      }
      lastSyncTime = DateTime.now();
      _startNetworkMonitor();
      unawaited(recheckNetworkStatus());
      if (currentUser?.accessToken?.isNotEmpty == true) {
        unawaited(_connectRealtime(currentUser!));
      }
      _startTerminalHeartbeat();
      unawaited(_reportTerminalStatus());
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
    unawaited(
        _localStorageService.saveConfig(config, isConfigured: isConfigured));
    _startNetworkMonitor();
    unawaited(recheckNetworkStatus());
    unawaited(loadBootstrapData());
    notifyListeners();
  }

  void returnToConfiguration() {
    unawaited(_disconnectRealtime());
    _terminalHeartbeatTimer?.cancel();
    currentUser = null;
    _restoredCurrentUser = null;
    sessionMessage = null;
    allowOfflineBrowsing = false;
    isConfigured = false;
    bootstrapping = false;
    unawaited(_localStorageService.saveCurrentUser(null));
    unawaited(
        _localStorageService.saveConfig(config, isConfigured: isConfigured));
    notifyListeners();
  }

  Future<String?> signIn({
    required MeetingUser user,
    String meetingPassword = '',
    String personalPassword = '',
  }) async {
    if (session.meetingPasswordRequired && meetingPassword.isEmpty) {
      return '请输入会议密码';
    }
    if (user.requiresPersonalPassword && personalPassword.isEmpty) {
      return '请输入个人密码';
    }
    try {
      currentUser = await _repository.signIn(
        config: config,
        session: session,
        user: user,
        meetingPassword: meetingPassword,
        personalPassword: personalPassword,
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
    allowOfflineBrowsing = false;
    lastSignedInUserId = currentUser?.id;
    unawaited(_localStorageService.saveLastSignedInUserId(lastSignedInUserId));
    unawaited(_localStorageService.saveCurrentUser(currentUser));
    await _syncDocumentMarks();
    unawaited(_reportTerminalStatus());
    notifyListeners();
    return null;
  }

  void signOut({bool preserveSessionMessage = false}) {
    unawaited(_disconnectRealtime());
    _terminalHeartbeatTimer?.cancel();
    currentUser = null;
    annotationEnabled = false;
    followSync = true;
    syncActive = false;
    currentHomeIndex = 0;
    currentPage = 1;
    signaturePoints.clear();
    _restoredCurrentUser = null;
    allowOfflineBrowsing = false;
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
    unawaited(_reportTerminalStatus());
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
      unawaited(_syncDocumentMarks());
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
    unawaited(_syncDocumentMarks());
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

  Future<void> addNote(String content) async {
    final user = currentUser;
    final documentId = selectedDocumentId;
    final local = NoteEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      documentId: documentId,
      page: currentPage,
      content: content,
      createdBy: user?.name ?? '未知用户',
      updatedAt: DateTime.now(),
    );
    notes.add(local);
    unawaited(_localStorageService.saveNotes(notes));
    notifyListeners();
    if (user == null || documentId.isEmpty) {
      return;
    }
    try {
      final saved = await _repository.saveNote(
        config: config,
        meetingId: session.meetingId,
        userId: user.id,
        documentId: documentId,
        page: currentPage,
        content: content,
        createdBy: user.name,
      );
      notes
        ..removeWhere((item) => identical(item, local))
        ..add(saved);
      unawaited(_localStorageService.saveNotes(notes));
      notifyListeners();
    } catch (_) {
      // Keep local note when sync is unavailable.
    }
  }

  Future<void> addBookmark(String label) async {
    final user = currentUser;
    final documentId = selectedDocumentId;
    final local = BookmarkEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      documentId: documentId,
      page: currentPage,
      label: label,
      updatedAt: DateTime.now(),
    );
    bookmarks.add(local);
    unawaited(_localStorageService.saveBookmarks(bookmarks));
    notifyListeners();
    if (user == null || documentId.isEmpty) {
      return;
    }
    try {
      final saved = await _repository.saveBookmark(
        config: config,
        meetingId: session.meetingId,
        userId: user.id,
        documentId: documentId,
        page: currentPage,
        label: label,
      );
      bookmarks
        ..removeWhere((item) => identical(item, local))
        ..add(saved);
      unawaited(_localStorageService.saveBookmarks(bookmarks));
      notifyListeners();
    } catch (_) {
      // Keep local bookmark when sync is unavailable.
    }
  }

  Future<void> removeNote(NoteEntry entry) async {
    notes.remove(entry);
    unawaited(_localStorageService.saveNotes(notes));
    notifyListeners();
    if (entry.id == null || currentUser == null) {
      return;
    }
    try {
      await _repository.deleteNote(
        config: config,
        userId: currentUser!.id,
        markId: entry.id!,
      );
    } catch (_) {
      // Keep local deletion even if remote cleanup fails.
    }
  }

  Future<void> removeBookmark(BookmarkEntry entry) async {
    bookmarks.remove(entry);
    unawaited(_localStorageService.saveBookmarks(bookmarks));
    notifyListeners();
    if (entry.id == null || currentUser == null) {
      return;
    }
    try {
      await _repository.deleteBookmark(
        config: config,
        userId: currentUser!.id,
        markId: entry.id!,
      );
    } catch (_) {
      // Keep local deletion even if remote cleanup fails.
    }
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
        status: isSecretaryMode
            ? SyncRequestStatus.approved
            : SyncRequestStatus.pending,
      );
      session = _copySession(
          syncRequests: <SyncRequest>[request, ...session.syncRequests]);
    }
    _logMessage(
      SyncMessageType.syncRequest,
      <String, dynamic>{
        'documentTitle': document.title,
        'requester': user.name
      },
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
    _logMessage(
        SyncMessageType.syncApproved, <String, dynamic>{'videoSync': true});
    notifyListeners();
  }

  void openVideoSync(MeetingDocument document) {
    final user = currentUser;
    videoSyncState = VideoSyncState(
      documentId: document.id,
      documentTitle: document.title,
      positionMs: 0,
      playing: true,
      active: true,
      sentAt: DateTime.now(),
    );
    if (realtimeEnabled && user != null) {
      _sendRealtime(
        type: 'meeting-video-control-send',
        payload: <String, dynamic>{
          'meetingId': int.tryParse(session.meetingId) ?? 0,
          'documentId': document.id,
          'documentTitle': document.title,
          'action': 'open',
          'positionMs': 0,
          'playing': true,
        },
      );
    }
    notifyListeners();
  }

  void syncVideoPlayback({
    required String documentId,
    required String documentTitle,
    required int positionMs,
    required bool playing,
  }) {
    final user = currentUser;
    videoSyncState = VideoSyncState(
      documentId: documentId,
      documentTitle: documentTitle,
      positionMs: positionMs,
      playing: playing,
      active: true,
      sentAt: DateTime.now(),
    );
    if (realtimeEnabled && user != null) {
      _sendRealtime(
        type: 'meeting-video-control-send',
        payload: <String, dynamic>{
          'meetingId': int.tryParse(session.meetingId) ?? 0,
          'documentId': documentId,
          'documentTitle': documentTitle,
          'action': 'control',
          'positionMs': positionMs,
          'playing': playing,
        },
      );
    }
  }

  void vote(String optionId) {
    final userId = currentUser?.id;
    if (userId == null ||
        session.voteItem.stage != VoteStage.active ||
        session.voteItem.votedUserIds.contains(userId)) {
      return;
    }
    final options = session.voteItem.options
        .map((item) =>
            item.id == optionId ? item.copyWith(count: item.count + 1) : item)
        .toList();
    final voted = Set<String>.from(session.voteItem.votedUserIds)..add(userId);
    session = _copySession(
        voteItem:
            session.voteItem.copyWith(options: options, votedUserIds: voted));
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
    session = _copySession(
        voteItem: session.voteItem.copyWith(stage: VoteStage.active));
    _logMessage(SyncMessageType.voteStarted,
        <String, dynamic>{'voteId': session.voteItem.id});
    notifyListeners();
  }

  void resetVote() {
    final resetOptions = session.voteItem.options
        .map((item) => item.copyWith(count: 0))
        .toList();
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
    session = _copySession(
        voteItem: session.voteItem.copyWith(stage: VoteStage.finished));
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
    session = _copySession(
        voteItem: session.voteItem.copyWith(stage: VoteStage.published));
    _logMessage(SyncMessageType.votePublished,
        <String, dynamic>{'voteId': session.voteItem.id});
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
    _logMessage(SyncMessageType.serviceRequested,
        <String, dynamic>{'category': category, 'requester': user.name});
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
      final item =
          session.serviceRequests.firstWhere((entry) => entry.id == requestId);
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
    _logMessage(SyncMessageType.serviceUpdated,
        <String, dynamic>{'requestId': requestId, 'status': status.label});
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
      final item =
          session.syncRequests.firstWhere((entry) => entry.id == requestId);
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
    _logMessage(SyncMessageType.syncApproved,
        <String, dynamic>{'requestId': requestId});
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
      final item =
          session.syncRequests.firstWhere((entry) => entry.id == requestId);
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
    _logMessage(SyncMessageType.syncRejected,
        <String, dynamic>{'requestId': requestId});
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
    _logMessage(
        SyncMessageType.noticePublished, <String, dynamic>{'title': title});
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
    allowOfflineBrowsing = false;
    lastSyncTime = DateTime.now();
    if (currentUser != null) {
      unawaited(refreshRealtimeState());
      unawaited(refreshNotices());
      unawaited(refreshVotes());
    }
    if (currentUser?.accessToken?.isNotEmpty == true &&
        !realtimeEnabled &&
        !realtimeConnecting) {
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
      final result = await _repository.fetchNotices(
        config: config,
        meetingId: session.meetingId,
        userId: currentUser?.id,
        pageNo: 1,
        pageSize: 20,
      );
      session = _copySession(notices: result.items);
      noticeTotal = result.total;
      noticePageNo = 1;
      _normalizeNoticeCollections();
      noticeIndex = 0;
      _normalizeNoticeIndex();
      lastSyncTime = DateTime.now();
    } finally {
      refreshingNotices = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreNotices() async {
    if (loadingMoreNotices || session.notices.length >= noticeTotal) {
      return;
    }
    loadingMoreNotices = true;
    notifyListeners();
    try {
      final result = await _repository.fetchNotices(
        config: config,
        meetingId: session.meetingId,
        userId: currentUser?.id,
        pageNo: noticePageNo + 1,
        pageSize: 20,
      );
      final merged = <MeetingNotice>[
        ...session.notices,
        ...result.items.where(
          (item) => !session.notices.any((existing) => existing.id == item.id),
        ),
      ];
      session = _copySession(notices: merged);
      noticeTotal = result.total;
      noticePageNo += 1;
      _normalizeNoticeCollections();
      _normalizeNoticeIndex();
    } finally {
      loadingMoreNotices = false;
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
      } else {
        session = _copySession(
          voteItem: VoteItem(
            id: '0',
            title: '暂无表决',
            description: '当前会议暂无进行中的表决事项。',
            anonymous: false,
            stage: VoteStage.idle,
            options: <VoteOption>[VoteOption(id: '0', label: '待发布')],
            votedUserIds: <String>{},
          ),
        );
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
      videoSyncState = snapshot.videoState;
      if (snapshot.timerState != null) {
        _applyRemoteTimerState(snapshot.timerState!);
      }
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
    if (session.notices.isNotEmpty &&
        noticeIndex < session.notices.length - 1) {
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
    if (currentUser != null) {
      unawaited(_repository.markNoticeRead(
        config: config,
        meetingId: session.meetingId,
        userId: currentUser!.id,
        noticeId: notice.id,
      ));
    }
    session = _copySession(
      notices: session.notices
          .map((item) => item.id == notice.id ? item.copyWith(read: true) : item)
          .toList(),
    );
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

  void continueOfflineBrowsing() {
    allowOfflineBrowsing = true;
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
      controlled: false,
    );
    _timer?.cancel();
    notifyListeners();
  }

  void startTimer() {
    _timer?.cancel();
    timerState = timerState.copyWith(running: true);
    if (isSecretaryMode) {
      _broadcastTimerState();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!timerState.running) return;
      if (timerState.countDown) {
        if (timerState.remainingSeconds <= 0) {
          stopTimer();
          return;
        }
        timerState = timerState.copyWith(
            remainingSeconds: timerState.remainingSeconds - 1);
      } else {
        timerState = timerState.copyWith(
            remainingSeconds: timerState.remainingSeconds + 1);
      }
      if (isSecretaryMode && timerState.remainingSeconds % 5 == 0) {
        _broadcastTimerState();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void stopTimer({bool reset = false}) {
    _timer?.cancel();
    timerState = timerState.copyWith(
      running: false,
      remainingSeconds: reset
          ? (timerState.countDown ? timerState.totalSeconds : 0)
          : timerState.remainingSeconds,
    );
    if (isSecretaryMode) {
      _broadcastTimerState();
    }
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
          createdAt:
              DateTime.tryParse('${envelope.payload['publishedTime'] ?? ''}') ??
                  DateTime.now(),
        );
        session =
            _copySession(notices: <MeetingNotice>[notice, ...session.notices]);
        _normalizeNoticeCollections();
        noticeIndex = 0;
        _normalizeNoticeIndex();
        break;
      case SyncMessageType.syncRequest:
        session = _copySession(
            syncRequests:
                _mergeSyncRequest(_syncRequestFromEnvelope(envelope)));
        break;
      case SyncMessageType.syncApproved:
        syncActive = true;
        followSync = true;
        session = _copySession(
            syncRequests:
                _mergeSyncRequest(_syncRequestFromEnvelope(envelope)));
        break;
      case SyncMessageType.syncRejected:
        session = _copySession(
            syncRequests:
                _mergeSyncRequest(_syncRequestFromEnvelope(envelope)));
        break;
      case SyncMessageType.syncStopped:
        syncActive = false;
        followSync = false;
        session = _copySession(syncRequests: _markSyncStopped(envelope));
        break;
      case SyncMessageType.serviceRequested:
        session = _copySession(
            serviceRequests:
                _mergeServiceRequest(_serviceRequestFromEnvelope(envelope)));
        break;
      case SyncMessageType.serviceUpdated:
        session = _copySession(
            serviceRequests:
                _mergeServiceRequest(_serviceRequestFromEnvelope(envelope)));
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
        session = _copySession(
            voteItem: session.voteItem.copyWith(stage: VoteStage.finished));
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
      case SyncMessageType.videoOpened:
      case SyncMessageType.videoControlled:
        videoSyncState = VideoSyncState(
          documentId: '${envelope.payload['documentId'] ?? ''}',
          documentTitle: envelope.payload['documentTitle'] as String?,
          positionMs: (envelope.payload['positionMs'] as num?)?.toInt() ?? 0,
          playing: envelope.payload['playing'] == true,
          active: '${envelope.payload['documentId'] ?? ''}'.isNotEmpty,
          sentAt: DateTime.tryParse('${envelope.payload['sentTime'] ?? ''}'),
        );
        break;
      case SyncMessageType.timerStarted:
      case SyncMessageType.timerUpdated:
      case SyncMessageType.timerStopped:
        _applyRemoteTimerState(TimerState(
          totalSeconds: (envelope.payload['totalSeconds'] as num?)?.toInt() ?? 0,
          remainingSeconds:
              (envelope.payload['remainingSeconds'] as num?)?.toInt() ?? 0,
          running: envelope.payload['running'] == true,
          countDown: envelope.payload['countDown'] != false,
          speaker: envelope.payload['speaker'] as String?,
          controlled: true,
          sentAt: DateTime.tryParse('${envelope.payload['sentTime'] ?? ''}'),
        ));
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
    if (session.topics.isNotEmpty &&
        !session.topics.any((item) => item.id == selectedTopicId)) {
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
    final pinned = session.notices
        .where((item) => pinnedNoticeIds.contains(item.id))
        .toList();
    final normal = session.notices
        .where((item) => !pinnedNoticeIds.contains(item.id))
        .toList();
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

  Future<void> _syncDocumentMarks() async {
    final user = currentUser;
    final document = currentDocumentOrNull;
    if (user == null || document == null) {
      return;
    }
    try {
      final remoteNotes = await _repository.fetchNotes(
        config: config,
        meetingId: session.meetingId,
        userId: user.id,
        documentId: document.id,
      );
      final remoteBookmarks = await _repository.fetchBookmarks(
        config: config,
        meetingId: session.meetingId,
        userId: user.id,
        documentId: document.id,
      );
      notes.removeWhere((item) => (item.documentId ?? document.id) == document.id);
      bookmarks
          .removeWhere((item) => (item.documentId ?? document.id) == document.id);
      notes.addAll(remoteNotes);
      bookmarks.addAll(remoteBookmarks);
      unawaited(_localStorageService.saveNotes(notes));
      unawaited(_localStorageService.saveBookmarks(bookmarks));
      notifyListeners();
    } catch (_) {
      // Keep local marks if the sync endpoint is unavailable.
    }
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
    final file = File(
        '${dir.path}${Platform.pathSeparator}meeting_message_log_${session.meetingId}.txt');
    final lines = messageLog
        .map((item) =>
            '[${item.timestamp.toIso8601String()}] ${item.type.code} ${item.payload}')
        .join('\n');
    await file.writeAsString(lines, flush: true);
    return file.path;
  }

  void _restoreCurrentUserIfPossible() {
    final restored = _restoredCurrentUser;
    if (restored == null) {
      return;
    }
    if (restored.accessTokenExpiresAt != null &&
        restored.accessTokenExpiresAt!.isBefore(DateTime.now())) {
      _restoredCurrentUser = null;
      unawaited(_localStorageService.saveCurrentUser(null));
      return;
    }
    final matchedUser =
        session.users.where((item) => item.id == restored.id).toList();
    if (matchedUser.isEmpty) {
      return;
    }
    currentUser = MeetingUser(
      id: restored.id,
      name: restored.name.isNotEmpty ? restored.name : matchedUser.first.name,
      role: restored.role,
      seatName: restored.seatName.isNotEmpty
          ? restored.seatName
          : matchedUser.first.seatName,
      signStatus: matchedUser.first.signStatus,
      personalPassword:
          matchedUser.first.personalPassword ?? restored.personalPassword,
      requirePersonalPassword: matchedUser.first.requirePersonalPassword,
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

  void _broadcastTimerState() {
    final user = currentUser;
    if (!realtimeEnabled || user == null) {
      return;
    }
    _sendRealtime(
      type: 'meeting-timer-control-send',
      payload: <String, dynamic>{
        'meetingId': int.tryParse(session.meetingId) ?? 0,
        'totalSeconds': timerState.totalSeconds,
        'remainingSeconds': timerState.remainingSeconds,
        'countDown': timerState.countDown,
        'running': timerState.running,
        'speaker': timerState.speaker,
      },
    );
  }

  void _applyRemoteTimerState(TimerState remote) {
    _timer?.cancel();
    timerState = remote;
    if (!remote.running) {
      notifyListeners();
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!timerState.running) {
        return;
      }
      if (timerState.countDown) {
        if (timerState.remainingSeconds <= 0) {
          _timer?.cancel();
          timerState = timerState.copyWith(running: false, remainingSeconds: 0);
        } else {
          timerState = timerState.copyWith(
            remainingSeconds: timerState.remainingSeconds - 1,
          );
        }
      } else {
        timerState = timerState.copyWith(
          remainingSeconds: timerState.remainingSeconds + 1,
        );
      }
      notifyListeners();
    });
    notifyListeners();
  }

  List<SyncRequest> _mergeSyncRequest(SyncRequest request) {
    final existing =
        session.syncRequests.where((item) => item.id != request.id).toList();
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
          (item) => item.id == requestId
              ? item.copyWith(status: SyncRequestStatus.rejected)
              : item,
        )
        .toList();
  }

  List<ServiceRequest> _mergeServiceRequest(ServiceRequest request) {
    final existing =
        session.serviceRequests.where((item) => item.id != request.id).toList();
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
      status: _syncRequestStatusFromCode(
          '${envelope.payload['status'] ?? 'pending'}', envelope.type),
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
      status:
          _serviceStatusFromCode('${envelope.payload['status'] ?? 'pending'}'),
      handlerUserId: '${envelope.payload['handlerUserId'] ?? ''}',
      handlerName: '${envelope.payload['handlerName'] ?? ''}',
      acceptedAt: DateTime.tryParse('${envelope.payload['acceptedAt'] ?? ''}'),
      completedAt:
          DateTime.tryParse('${envelope.payload['completedAt'] ?? ''}'),
      canceledAt: DateTime.tryParse('${envelope.payload['canceledAt'] ?? ''}'),
      resultRemark: envelope.payload['resultRemark'] as String?,
    );
  }

  SyncRequestStatus _syncRequestStatusFromCode(
      String code, SyncMessageType type) {
    if (type == SyncMessageType.syncRejected ||
        code.toLowerCase() == 'rejected') {
      return SyncRequestStatus.rejected;
    }
    if (type == SyncMessageType.syncApproved ||
        code.toLowerCase() == 'approved') {
      return SyncRequestStatus.approved;
    }
    return SyncRequestStatus.pending;
  }

  ServiceStatus _serviceStatusFromCode(String code) {
    switch (code.toLowerCase()) {
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

  String _serviceStatusCode(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.accepted:
        return 'accepted';
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
          unawaited(_reportTerminalStatus());
          notifyListeners();
        },
        onDisconnected: () {
          realtimeConnecting = false;
          realtimeEnabled = false;
          connectionStatus = ConnectionStatus.offline;
          unawaited(_reportTerminalStatus());
          notifyListeners();
        },
        onError: (Object error) {
          realtimeConnecting = false;
          realtimeEnabled = false;
          connectionStatus = ConnectionStatus.offline;
          bootstrapError = '实时连接失败：$error';
          unawaited(_reportTerminalStatus());
          notifyListeners();
        },
        onMessage: applyEnvelope,
      );
    } catch (error) {
      realtimeConnecting = false;
      realtimeEnabled = false;
      connectionStatus = ConnectionStatus.offline;
      bootstrapError = '实时连接失败：$error';
      unawaited(_reportTerminalStatus());
      notifyListeners();
    }
  }

  Future<void> _disconnectRealtime() async {
    await _websocketService.disconnect();
    realtimeConnecting = false;
    realtimeEnabled = false;
    realtimeEndpoint = null;
    connectionStatus = ConnectionStatus.offline;
    await _reportTerminalStatus();
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

  void _startTerminalHeartbeat() {
    _terminalHeartbeatTimer?.cancel();
    if (!isConfigured) {
      return;
    }
    _terminalHeartbeatTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      unawaited(_reportTerminalStatus());
    });
  }

  Future<void> _reportTerminalStatus() async {
    if (!isConfigured) {
      return;
    }
    await _repository.reportTerminalStatus(
      config: config,
      session: session,
      user: currentUser,
      isDarkMode: isDarkMode,
      connectionStatus: connectionStatus,
    );
  }

  Future<bool> _isServerReachable() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
    try {
      final uri = Uri.http('${config.serverIp}:${config.port}',
          '/meeting/app/bootstrap', <String, String>{
        'roomName': config.roomName,
        'seatName': config.seatName,
        'deviceName': config.deviceName,
      });
      final request =
          await client.getUrl(uri).timeout(const Duration(seconds: 3));
      final response =
          await request.close().timeout(const Duration(seconds: 3));
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
      meetingPasswordRequired: session.meetingPasswordRequired,
      terminalProfile: session.terminalProfile,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _preloadTimer?.cancel();
    _networkTimer?.cancel();
    _noticeTimer?.cancel();
    _terminalHeartbeatTimer?.cancel();
    unawaited(_disconnectRealtime());
    super.dispose();
  }
}

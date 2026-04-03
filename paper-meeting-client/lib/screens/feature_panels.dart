import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../app.dart';
import '../models/app_models.dart';
import '../models/client_protocol.dart';
import '../state/app_controller.dart';
import '../theme/meeting_theme.dart';
import '../widgets/common/meeting_action_button.dart';
import '../widgets/common/meeting_inset_box.dart';
import '../widgets/common/meeting_selectable_card.dart';
import '../widgets/common/meeting_status_pill.dart';
import '../widgets/common/meeting_surface_card.dart';
import '../widgets/signature_pad.dart';

class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MeetingAppScope.of(context);
    final palette = context.meetingPalette;
    final totalUsers = controller.session.users.length;
    final signedUsers =
        controller.session.users.where((user) => user.signedIn).length;
    final unsignedUsers = totalUsers - signedUsers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context, '会议信息', '查看会议简介、议题安排及参会人员名单。'),
        if (controller.bootstrapError != null) ...[
          const SizedBox(height: 12),
          _statusBanner(context, controller.bootstrapError!,
              icon: Icons.error_outline_rounded),
        ],
        const SizedBox(height: 20),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 64,
                child: Column(
                  children: [
                    MeetingSurfaceCard(
                      radius: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.session.meetingName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(fontSize: 30),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      controller.session.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: palette.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              MeetingInsetBox(
                                radius: 20,
                                padding: EdgeInsets.zero,
                                child: Icon(
                                  Icons.corporate_fare_outlined,
                                  size: 52,
                                  color: palette.accent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              MeetingStatusPill(
                                  label: '会议室：${controller.config.roomName}',
                                  icon: Icons.meeting_room_outlined),
                              MeetingStatusPill(
                                  label: '座位：${controller.config.seatName}',
                                  icon: Icons.event_seat_outlined),
                              MeetingStatusPill(
                                label:
                                    '议题数：${controller.session.topics.length}',
                                icon: Icons.topic_outlined,
                                tone: MeetingStatusTone.accent,
                              ),
                              MeetingStatusPill(
                                label:
                                    '文稿数：${controller.session.documents.length}',
                                icon: Icons.description_outlined,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: MeetingSurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text('会议议题',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge),
                                ),
                                Text('当前会议流程',
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.separated(
                                itemCount: controller.session.topics.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final topic =
                                      controller.session.topics[index];
                                  final selected =
                                      controller.selectedTopicId == topic.id;
                                  final relatedCount = controller
                                      .session.documents
                                      .where((item) => item.topicId == topic.id)
                                      .length;
                                  return MeetingSelectableCard(
                                    onTap: () =>
                                        controller.selectTopic(topic.id),
                                    selected: selected,
                                    padding: const EdgeInsets.all(18),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 52,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? palette.accent
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: selected
                                                ? null
                                                : Border.all(
                                                    color: palette.panelBorder),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${index + 1}'.padLeft(2, '0'),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color: selected
                                                      ? Colors.white
                                                      : palette.textPrimary,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(topic.title,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium),
                                              const SizedBox(height: 6),
                                              Text(
                                                '关联 $relatedCount 份文稿${selected ? ' · 当前阅读议题' : ''}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        MeetingStatusPill(
                                          label: selected ? '进行中' : '待查看',
                                          tone: selected
                                              ? MeetingStatusTone.accent
                                              : MeetingStatusTone.neutral,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 36,
                child: MeetingSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('参会人员',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                              child: _statBlock(context, '应到', '$totalUsers')),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _statBlock(context, '签到', '$signedUsers')),
                          const SizedBox(width: 10),
                          Expanded(
                              child:
                                  _statBlock(context, '未签到', '$unsignedUsers')),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: ListView.separated(
                          itemCount: controller.session.users.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final user = controller.session.users[index];
                            return MeetingInsetBox(
                              padding: const EdgeInsets.all(14),
                              radius: 16,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: palette.accentSoft,
                                    foregroundColor: palette.chrome,
                                    child: Text(user.name.substring(0, 1)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(user.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            MeetingStatusPill(
                                              label: user.role.label,
                                              tone: user.role == UserRole.host
                                                  ? MeetingStatusTone.accent
                                                  : user.role ==
                                                          UserRole.secretary
                                                      ? MeetingStatusTone
                                                          .warning
                                                      : MeetingStatusTone
                                                          .neutral,
                                            ),
                                            MeetingStatusPill(
                                                label: user.seatName,
                                                icon:
                                                    Icons.event_seat_outlined),
                                            MeetingStatusPill(
                                              label:
                                                  user.signedIn ? '已签到' : '未签到',
                                              tone: user.signedIn
                                                  ? MeetingStatusTone.accent
                                                  : MeetingStatusTone.warning,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statBlock(BuildContext context, String label, String value) {
    return MeetingInsetBox(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class DocumentPanel extends StatefulWidget {
  const DocumentPanel({super.key});

  @override
  State<DocumentPanel> createState() => _DocumentPanelState();
}

class _DocumentPanelState extends State<DocumentPanel> {
  final noteController = TextEditingController();
  final bookmarkController = TextEditingController(text: '重点页');
  SyncMessageType? logFilter;
  PdfViewerController? _pdfViewerController;
  String? _activeDocumentId;
  String? _activeDocumentUrl;
  int? _loadedPageCount;
  String? _pdfError;

  @override
  void dispose() {
    noteController.dispose();
    bookmarkController.dispose();
    super.dispose();
  }

  void _preparePdfContext(AppController controller, MeetingDocument? document) {
    final resolvedUri =
        document == null ? null : _resolveDocumentUri(controller, document);
    final resolvedUrl = resolvedUri?.toString();
    if (_activeDocumentId == document?.id &&
        _activeDocumentUrl == resolvedUrl) {
      return;
    }
    _activeDocumentId = document?.id;
    _activeDocumentUrl = resolvedUrl;
    _loadedPageCount = null;
    _pdfError = null;
    _pdfViewerController =
        document != null && _isPdfDocument(document) && resolvedUri != null
            ? PdfViewerController()
            : null;
  }

  bool _isPdfDocument(MeetingDocument document) {
    final type = (document.fileType ?? '').toLowerCase();
    final url = (document.fileUrl ?? '').toLowerCase();
    return type.contains('pdf') || url.endsWith('.pdf');
  }

  Uri? _resolveDocumentUri(AppController controller, MeetingDocument document) {
    final raw = document.fileUrl?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final cachedPath = controller.resolveCachedResourcePath(raw);
    if (cachedPath != null && cachedPath.isNotEmpty) {
      return Uri.file(cachedPath);
    }
    final direct = Uri.tryParse(raw);
    if (direct != null && direct.hasScheme) {
      return direct;
    }
    final normalizedPath = raw.startsWith('/') ? raw : '/$raw';
    return Uri.http('${controller.config.serverIp}:${controller.config.port}',
        normalizedPath);
  }

  int _effectivePageCount(MeetingDocument? document) {
    if (document == null) {
      return 1;
    }
    final loaded = _loadedPageCount;
    if (loaded != null && loaded > 0) {
      return loaded;
    }
    return document.pageCount > 0 ? document.pageCount : 1;
  }

  Future<void> _goToDocumentPage(AppController controller, int page) async {
    final document = controller.currentDocumentOrNull;
    if (document == null) {
      return;
    }
    final targetPage = page < 1
        ? 1
        : page > _effectivePageCount(document)
            ? _effectivePageCount(document)
            : page;
    controller.jumpToPage(targetPage);
    final viewerController = _pdfViewerController;
    if (viewerController != null && viewerController.isReady) {
      await viewerController.goToPage(pageNumber: targetPage);
    }
  }

  Widget _notesTab(BuildContext context, AppController controller) {
    return ListView(
      children: [
        TextField(
          controller: noteController,
          decoration: const InputDecoration(labelText: '新增文字批注'),
          maxLines: 4,
        ),
        const SizedBox(height: 10),
        MeetingActionButton(
          onPressed: () {
            final text = noteController.text.trim();
            if (text.isEmpty) return;
            controller.addNote(text);
            noteController.clear();
          },
          tone: MeetingActionTone.primary,
          label: '保存到当前页',
        ),
        const SizedBox(height: 18),
        ...controller.currentDocumentNotes.map(
          (item) => MeetingInsetBox(
            margin: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(item.content,
                          style: Theme.of(context).textTheme.titleSmall),
                    ),
                    IconButton(
                      tooltip: '删除批注',
                      onPressed: () => controller.removeNote(item),
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('${item.createdBy} · 第 ${item.page} 页',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bookmarksTab(BuildContext context, AppController controller) {
    return ListView(
      children: [
        TextField(
            controller: bookmarkController,
            decoration: const InputDecoration(labelText: '书签名称')),
        const SizedBox(height: 10),
        MeetingActionButton(
          onPressed: () => controller.addBookmark(bookmarkController.text.trim()),
          label: '收藏当前页',
        ),
        const SizedBox(height: 18),
        ...controller.currentDocumentBookmarks.map(
          (item) => MeetingInsetBox(
            margin: const EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.zero,
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              title: Text(item.label),
              subtitle: Text('第 ${item.page} 页'),
              trailing: Wrap(
                spacing: 6,
                children: [
                  IconButton(
                    tooltip: '删除书签',
                    onPressed: () => controller.removeBookmark(item),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              onTap: () => _goToDocumentPage(controller, item.page),
            ),
          ),
        ),
      ],
    );
  }

  Widget _syncTab(BuildContext context, AppController controller) {
    final filteredLogs = logFilter == null
        ? controller.messageLog
        : controller.messageLog
            .where((item) => item.type == logFilter)
            .toList();
    return ListView(
      children: [
        MeetingActionButton(
          onPressed: controller.preloading ? null : controller.simulatePreload,
          icon: const Icon(Icons.cloud_download_outlined, size: 18),
          label: '预加载资料',
        ),
        const SizedBox(height: 10),
        MeetingActionButton(
          onPressed: controller.followSync
              ? controller.leaveSync
              : controller.returnToSync,
          icon: Icon(
              controller.followSync
                  ? Icons.exit_to_app_outlined
                  : Icons.reply_all_outlined,
              size: 18),
          label: controller.followSync ? '退出跟随' : '返回同屏',
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<SyncMessageType?>(
                initialValue: logFilter,
                decoration: const InputDecoration(labelText: '日志筛选'),
                items: <DropdownMenuItem<SyncMessageType?>>[
                  const DropdownMenuItem<SyncMessageType?>(
                      value: null, child: Text('全部')),
                  ...SyncMessageType.values.map(
                    (type) => DropdownMenuItem<SyncMessageType?>(
                      value: type,
                      child: Text(type.code),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => logFilter = value),
              ),
            ),
            const SizedBox(width: 10),
            MeetingActionButton(
              onPressed: () async {
                final path = await controller.exportMessageLog();
                if (!mounted || path == null) {
                  return;
                }
                await launchUrl(Uri.file(path),
                    mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.save_alt_outlined, size: 18),
              label: '导出日志',
            ),
          ],
        ),
        const SizedBox(height: 18),
        ...filteredLogs.take(8).map(
              (item) => MeetingInsetBox(
                margin: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.type.code,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Text(_formatTime(item.timestamp),
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildDocumentViewport(
    BuildContext context,
    AppController controller,
    MeetingDocument document,
  ) {
    final palette = context.meetingPalette;
    final resolvedUri = _resolveDocumentUri(controller, document);
    if (!_isPdfDocument(document)) {
      return _panelStateCard(
        context,
        icon: Icons.insert_drive_file_outlined,
        title: '当前资料不是 PDF',
        message: '当前文稿类型为 ${document.fileType ?? '未知'}，暂未接入该类型的在线预览能力。',
      );
    }
    if (resolvedUri == null) {
      return _panelStateCard(
        context,
        icon: Icons.link_off_outlined,
        title: '文稿地址无效',
        message: '当前文稿没有可用的文件地址，无法加载 PDF。',
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          Container(
            color: Colors.white,
            child: PdfViewer.uri(
              resolvedUri,
              key: ValueKey(resolvedUri.toString()),
              controller: _pdfViewerController,
              initialPageNumber: controller.currentPage,
              params: PdfViewerParams(
                backgroundColor: Colors.white,
                margin: 12,
                maxScale: 5,
                onViewerReady: (documentRef, viewerController) {
                  final newPageCount = documentRef.pages.length;
                  if (!mounted) {
                    return;
                  }
                  if (_loadedPageCount != newPageCount) {
                    setState(() {
                      _loadedPageCount = newPageCount;
                    });
                  }
                  if (controller.currentPage > newPageCount) {
                    controller.jumpToPage(newPageCount);
                  }
                },
                onPageChanged: (pageNumber) {
                  if (pageNumber != null &&
                      controller.currentPage != pageNumber) {
                    controller.jumpToPage(pageNumber);
                  }
                },
                pagePaintCallbacks: controller.session.watermarkEnabled
                    ? <PdfViewerPagePaintCallback>[
                        (canvas, pageRect, page) {
                          final watermark =
                              '${controller.currentUser?.name ?? '会议终端'}  ${_formatTime(DateTime.now())}';
                          final textPainter = TextPainter(
                            text: TextSpan(
                              text: watermark,
                              style: const TextStyle(
                                color: Color(0x16000000),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            textDirection: TextDirection.ltr,
                          )..layout(maxWidth: pageRect.width * 0.8);
                          canvas.save();
                          canvas.translate(
                              pageRect.center.dx, pageRect.center.dy);
                          canvas.rotate(-0.85);
                          textPainter.paint(
                            canvas,
                            Offset(-textPainter.width / 2,
                                -textPainter.height / 2),
                          );
                          canvas.restore();
                        },
                      ]
                    : null,
                onDocumentLoadFinished: (documentRef, succeeded) {
                  if (!mounted) {
                    return;
                  }
                  final error =
                      succeeded ? null : documentRef.resolveListenable().error;
                  setState(() {
                    _pdfError = error?.toString();
                  });
                },
                loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
                  final progress = totalBytes == null || totalBytes == 0
                      ? null
                      : bytesDownloaded / totalBytes;
                  return Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 260,
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: palette.panelBorder),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('PDF 加载中'),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: progress),
                        ],
                      ),
                    ),
                  );
                },
                errorBannerBuilder: (context, error, stackTrace, documentRef) {
                  return Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 320,
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4E8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: palette.panelBorder),
                      ),
                      child: Text(
                        'PDF 加载失败：$error',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_pdfViewerController != null)
            Positioned(
              right: 16,
              top: 16,
              bottom: 16,
              child: IgnorePointer(
                ignoring: !_pdfViewerController!.isReady,
                child: Opacity(
                  opacity: 0.92,
                  child: PdfViewerScrollThumb(
                    controller: _pdfViewerController!,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = MeetingAppScope.of(context);
    final palette = context.meetingPalette;
    final currentDocument = controller.currentDocumentOrNull;
    _preparePdfContext(controller, currentDocument);
    final pageCount = _effectivePageCount(currentDocument);
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, '会议文稿', '支持议题切换、翻页、书签、注释和同屏申请。'),
          if (controller.bootstrapError != null) ...[
            const SizedBox(height: 12),
            _statusBanner(context, controller.bootstrapError!,
                icon: Icons.error_outline_rounded),
          ],
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 300,
                  child: MeetingSurfaceCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('议题与文稿',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 52,
                          child: controller.session.topics.isEmpty
                              ? _compactEmptyText(context, '当前会议未配置议题')
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: controller.session.topics.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 10),
                                  itemBuilder: (context, index) {
                                    final topic =
                                        controller.session.topics[index];
                                    final selected =
                                        controller.selectedTopicId == topic.id;
                                    return MeetingSelectableCard(
                                      onTap: () =>
                                          controller.selectTopic(topic.id),
                                      selected: selected,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          '议题${index + 1}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: selected
                                                    ? palette.accent
                                                    : palette.textPrimary,
                                              ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: controller.currentTopicDocuments.isEmpty
                              ? _panelStateCard(
                                  context,
                                  icon: Icons.description_outlined,
                                  title: '当前议题暂无文稿',
                                  message: '请刷新文稿列表，或检查后端是否已为该议题绑定资料。',
                                  compact: true,
                                  actionLabel: '刷新文稿',
                                  onAction: controller.refreshingDocuments
                                      ? null
                                      : controller.refreshDocuments,
                                )
                              : ListView.separated(
                                  itemCount:
                                      controller.currentTopicDocuments.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final doc =
                                        controller.currentTopicDocuments[index];
                                    final selected =
                                        controller.selectedDocumentId == doc.id;
                                    return MeetingSelectableCard(
                                      onTap: () =>
                                          controller.selectDocument(doc.id),
                                      selected: selected,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(doc.title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium),
                                          const SizedBox(height: 6),
                                          Text('${doc.pageCount} 页',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: MeetingSurfaceCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(currentDocument?.title ?? '暂无文稿',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      MeetingStatusPill(
                                        label: currentDocument == null
                                            ? '等待文稿数据'
                                            : '第 ${controller.currentPage} / $pageCount 页',
                                        icon: Icons.menu_book_outlined,
                                      ),
                                      MeetingStatusPill(
                                        label: controller.followSync
                                            ? '正在跟随同屏'
                                            : '自由阅读模式',
                                        tone: controller.followSync
                                            ? MeetingStatusTone.accent
                                            : MeetingStatusTone.warning,
                                        icon: controller.followSync
                                            ? Icons.cast_connected_outlined
                                            : Icons.chrome_reader_mode_outlined,
                                      ),
                                      MeetingStatusPill(
                                        label:
                                            '角色：${controller.currentSyncRoleLabel}',
                                        tone: MeetingStatusTone.neutral,
                                        icon: Icons.groups_2_outlined,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: currentDocument == null
                                  ? null
                                  : controller.requestSync,
                              icon: const Icon(Icons.screen_share_outlined),
                              label: const Text('申请同屏'),
                            ),
                          ],
                        ),
                        if (controller.preloading) ...[
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                              value: controller.preloadProgress),
                        ],
                        const SizedBox(height: 16),
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  color: const Color(0xFFF7FAFD),
                                  border:
                                      Border.all(color: palette.panelBorder),
                                ),
                                padding:
                                    const EdgeInsets.fromLTRB(24, 20, 24, 84),
                                child: currentDocument == null
                                    ? _panelStateCard(
                                        context,
                                        icon: Icons.picture_as_pdf_outlined,
                                        title: '暂无可阅读文稿',
                                        message: '当前会议还没有下发文稿，或当前议题尚未绑定资料。',
                                        actionLabel: '刷新文稿',
                                        onAction: controller.refreshingDocuments
                                            ? null
                                            : controller.refreshDocuments,
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currentDocument.summary,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                    color:
                                                        palette.textSecondary),
                                          ),
                                          if ((currentDocument.fileType ?? '')
                                                  .isNotEmpty ||
                                              (currentDocument.fileUrl ?? '')
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 10),
                                            Text(
                                              '类型：${currentDocument.fileType ?? 'unknown'}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            Text(
                                              '地址：${currentDocument.fileUrl ?? '未提供'}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                          if (_pdfError != null) ...[
                                            const SizedBox(height: 10),
                                            _statusBanner(context, _pdfError!,
                                                icon: Icons
                                                    .warning_amber_rounded),
                                          ],
                                          const SizedBox(height: 22),
                                          Expanded(
                                            child: Center(
                                              child: ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 700),
                                                child: AspectRatio(
                                                  aspectRatio: 0.72,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              28),
                                                      border: Border.all(
                                                          color: palette
                                                              .panelBorder),
                                                    ),
                                                    child:
                                                        _buildDocumentViewport(
                                                            context,
                                                            controller,
                                                            currentDocument),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                              Positioned(
                                left: 20,
                                right: 20,
                                bottom: 18,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border:
                                        Border.all(color: palette.panelBorder),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: currentDocument == null
                                            ? null
                                            : () => _goToDocumentPage(
                                                controller,
                                                controller.currentPage - 1),
                                        icon: const Icon(Icons.chevron_left),
                                      ),
                                      SizedBox(
                                          width: 56,
                                          child: Text(
                                              '${controller.currentPage}',
                                              textAlign: TextAlign.center)),
                                      Text('/ $pageCount',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Slider(
                                          value:
                                              controller.currentPage.toDouble(),
                                          min: 1,
                                          max: pageCount.toDouble(),
                                          divisions: currentDocument != null &&
                                                  pageCount > 1
                                              ? pageCount - 1
                                              : 1,
                                          onChanged: currentDocument == null
                                              ? null
                                              : (value) => _goToDocumentPage(
                                                  controller, value.round()),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: currentDocument == null
                                            ? null
                                            : () => _goToDocumentPage(
                                                controller,
                                                controller.currentPage + 1),
                                        icon: const Icon(Icons.chevron_right),
                                      ),
                                      IconButton(
                                        onPressed: currentDocument == null
                                            ? null
                                            : controller.toggleAnnotation,
                                        icon: Icon(controller.annotationEnabled
                                            ? Icons.draw_rounded
                                            : Icons.draw_outlined),
                                      ),
                                      IconButton(
                                        onPressed:
                                            controller.refreshingDocuments
                                                ? null
                                                : controller.refreshDocuments,
                                        icon:
                                            const Icon(Icons.refresh_outlined),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 340,
                  child: MeetingSurfaceCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('辅助面板',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 14),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAFD),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: palette.panelBorder),
                          ),
                          child: TabBar(
                            labelColor: palette.accent,
                            unselectedLabelColor: palette.textSecondary,
                            dividerColor: Colors.transparent,
                            indicator: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            tabs: const [
                              Tab(text: '批注'),
                              Tab(text: '书签'),
                              Tab(text: '协同'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _notesTab(context, controller),
                              _bookmarksTab(context, controller),
                              _syncTab(context, controller),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MediaPanel extends StatefulWidget {
  const MediaPanel({
    super.key,
    required this.videoMode,
  });

  final bool videoMode;

  @override
  State<MediaPanel> createState() => _MediaPanelState();
}

class _MediaPanelState extends State<MediaPanel> {
  final TextEditingController searchController = TextEditingController();
  String selectedType = '全部';
  String? _autoOpenedVideoId;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = MeetingAppScope.of(context);
    final allItems = controller.session.documents.where((item) {
      final type = (item.fileType ?? '').toLowerCase();
      final isVideo = type.contains('video') ||
          type.contains('mp4') ||
          type.contains('m3u8');
      return widget.videoMode ? isVideo : !isVideo;
    }).toList();
    final categories = <String>{
      '全部',
      ...allItems
          .map((item) => (item.fileType ?? '').trim())
          .where((item) => item.isNotEmpty),
    }.toList();
    if (!categories.contains(selectedType)) {
      selectedType = '全部';
    }
    final keyword = searchController.text.trim().toLowerCase();
    final items = allItems.where((item) {
      final matchesType =
          selectedType == '全部' || (item.fileType ?? '').trim() == selectedType;
      final matchesKeyword = keyword.isEmpty ||
          item.title.toLowerCase().contains(keyword) ||
          item.summary.toLowerCase().contains(keyword);
      return matchesType && matchesKeyword;
    }).toList()
      ..sort((a, b) {
        final recentA = controller.recentDocumentIds.indexOf(a.id);
        final recentB = controller.recentDocumentIds.indexOf(b.id);
        if (recentA == -1 && recentB == -1) return 0;
        if (recentA == -1) return 1;
        if (recentB == -1) return -1;
        return recentA.compareTo(recentB);
      });
    if (widget.videoMode &&
        controller.videoSyncState.active &&
        controller.videoSyncState.documentId != null &&
        _autoOpenedVideoId != controller.videoSyncState.documentId) {
      final syncedItem = items
          .where((item) => item.id == controller.videoSyncState.documentId)
          .cast<MeetingDocument?>()
          .firstWhere((item) => item != null, orElse: () => null);
      if (syncedItem != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          final resourceUri =
              _resolveResourceUri(controller, syncedItem.fileUrl);
          if (resourceUri == null) {
            return;
          }
          _autoOpenedVideoId = syncedItem.id;
          await showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (dialogContext) => _VideoPlayerDialog(
              appController: controller,
              document: syncedItem,
              resourceUri: resourceUri,
            ),
          );
        });
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context, widget.videoMode ? '会议视频' : '公共资料库',
            widget.videoMode ? '支持同步演示。' : '提供长期公共资料查阅。'),
        if (controller.bootstrapError != null) ...[
          const SizedBox(height: 12),
          _statusBanner(context, controller.bootstrapError!,
              icon: Icons.error_outline_rounded),
        ],
        if (!widget.videoMode) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: '搜索资料名称或摘要',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: '分类'),
                  items: categories
                      .map((item) => DropdownMenuItem<String>(
                          value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedType = value ?? '全部'),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Expanded(
          child: items.isEmpty
              ? _panelStateCard(
                  context,
                  icon: widget.videoMode
                      ? Icons.play_circle_outline
                      : Icons.folder_zip_outlined,
                  title: widget.videoMode ? '暂无会议视频' : '暂无公共资料',
                  message:
                      widget.videoMode ? '当前会议还没有配置视频资源。' : '当前筛选条件下没有可查看资料。',
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final resourceUri =
                        _resolveResourceUri(controller, item.fileUrl);
                    final cached = controller.isResourceCached(item.fileUrl);
                    final recent =
                        controller.recentDocumentIds.contains(item.id);
                    return MeetingSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                              widget.videoMode
                                  ? Icons.play_circle_outline
                                  : Icons.folder_zip_outlined,
                              size: 36,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 12),
                          Text(item.title,
                              style: Theme.of(context).textTheme.titleMedium),
                          if ((item.fileType ?? '').isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(item.fileType!,
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (recent)
                                const MeetingStatusPill(
                                    label: '最近访问',
                                    tone: MeetingStatusTone.accent),
                              if (cached)
                                const MeetingStatusPill(
                                    label: '已缓存',
                                    tone: MeetingStatusTone.success),
                            ],
                          ),
                          const Spacer(),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (widget.videoMode)
                                MeetingActionButton(
                                  onPressed: () => controller.openVideoSync(item),
                                  tone: MeetingActionTone.accent,
                                  icon: const Icon(
                                      Icons.cast_connected_outlined,
                                      size: 18),
                                  label: '同步演示',
                                ),
                              MeetingActionButton(
                                onPressed: resourceUri == null
                                    ? null
                                    : () async {
                                        controller
                                            .rememberRecentResource(item.id);
                                        final sourceUrl =
                                            _resolveResourceSourceUrl(
                                                controller, item.fileUrl);
                                        if (sourceUrl != null) {
                                          await controller
                                              .rememberCachedResource(
                                                  sourceUrl);
                                        }
                                        final effectiveUri =
                                            _resolveResourceUri(
                                                    controller, item.fileUrl) ??
                                                resourceUri;
                                        if (widget.videoMode) {
                                          if (!context.mounted) return;
                                          await showDialog<void>(
                                            context: context,
                                            barrierDismissible: true,
                                            builder: (dialogContext) =>
                                                _VideoPlayerDialog(
                                              appController: controller,
                                              document: item,
                                              resourceUri: effectiveUri,
                                            ),
                                          );
                                          return;
                                        }
                                        await launchUrl(effectiveUri,
                                            mode:
                                                LaunchMode.externalApplication);
                                      },
                                icon: Icon(
                                    widget.videoMode
                                        ? Icons.play_arrow_rounded
                                        : Icons.download_outlined,
                                    size: 18),
                                label: widget.videoMode ? '播放视频' : '打开资料',
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _VideoPlayerDialog extends StatefulWidget {
  const _VideoPlayerDialog({
    required this.appController,
    required this.document,
    required this.resourceUri,
  });

  final AppController appController;
  final MeetingDocument document;
  final Uri resourceUri;

  @override
  State<_VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  VideoPlayerController? _playerController;
  bool _loading = true;
  bool _playing = false;
  bool _dragging = false;
  double _dragPositionMs = 0;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    widget.appController.addListener(_handleSyncChanged);
    _initializePlayer();
  }

  @override
  void dispose() {
    widget.appController.removeListener(_handleSyncChanged);
    _playerController?.removeListener(_handlePlayerChanged);
    _playerController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    VideoPlayerController controller;
    final uri = widget.resourceUri;
    try {
      if (uri.scheme == 'file') {
        controller = VideoPlayerController.file(File.fromUri(uri));
      } else {
        controller = VideoPlayerController.networkUrl(uri);
      }
      _playerController = controller;
      controller.addListener(_handlePlayerChanged);
      await controller.initialize();
      final syncState = widget.appController.videoSyncState;
      if (syncState.documentId == widget.document.id && syncState.positionMs > 0) {
        await controller.seekTo(Duration(milliseconds: syncState.positionMs));
      }
      if (syncState.documentId == widget.document.id && syncState.playing == false) {
        await controller.pause();
      } else {
        await controller.play();
      }
      if (!mounted) return;
      setState(() {
        _loading = false;
        _playing = controller.value.isPlaying;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorText = '视频加载失败：$error';
      });
    }
  }

  void _handlePlayerChanged() {
    final controller = _playerController;
    if (!mounted || controller == null) {
      return;
    }
    setState(() {
      _playing = controller.value.isPlaying;
    });
  }

  Future<void> _handleSyncChanged() async {
    final controller = _playerController;
    final syncState = widget.appController.videoSyncState;
    if (!mounted ||
        controller == null ||
        !controller.value.isInitialized ||
        syncState.documentId != widget.document.id) {
      return;
    }
    final remotePosition = Duration(milliseconds: syncState.positionMs);
    final delta = (controller.value.position - remotePosition).inMilliseconds.abs();
    if (delta > 1500) {
      await controller.seekTo(remotePosition);
    }
    if (syncState.playing && !controller.value.isPlaying) {
      await controller.play();
    } else if (!syncState.playing && controller.value.isPlaying) {
      await controller.pause();
    }
  }

  Future<void> _togglePlayback() async {
    final controller = _playerController;
    if (controller == null) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    if (widget.appController.isSecretaryMode) {
      widget.appController.syncVideoPlayback(
        documentId: widget.document.id,
        documentTitle: widget.document.title,
        positionMs: controller.value.position.inMilliseconds,
        playing: controller.value.isPlaying,
      );
    }
  }

  Future<void> _seekTo(double positionMs) async {
    final controller = _playerController;
    if (controller == null) return;
    final clampedMs = positionMs.clamp(
        0, controller.value.duration.inMilliseconds.toDouble());
    await controller.seekTo(Duration(milliseconds: clampedMs.round()));
    if (widget.appController.isSecretaryMode) {
      widget.appController.syncVideoPlayback(
        documentId: widget.document.id,
        documentTitle: widget.document.title,
        positionMs: clampedMs.round(),
        playing: controller.value.isPlaying,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.meetingPalette;
    final controller = _playerController;
    final value = controller?.value;
    final duration = value?.duration ?? Duration.zero;
    final position = _dragging
        ? Duration(milliseconds: _dragPositionMs.round())
        : (value?.position ?? Duration.zero);
    final maxMs =
        duration.inMilliseconds <= 0 ? 1.0 : duration.inMilliseconds.toDouble();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080, maxHeight: 760),
        child: MeetingSurfaceCard(
          radius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.document.title,
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 6),
                        Text(
                          widget.resourceUri.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: palette.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: '关闭',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFF0B1220),
                    child: _buildVideoArea(context),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_errorText != null) ...[
                _statusBanner(context, _errorText!,
                    icon: Icons.warning_amber_rounded),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  MeetingActionButton(
                    onPressed:
                        controller == null || _loading || _errorText != null
                            ? null
                            : _togglePlayback,
                    tone: MeetingActionTone.primary,
                    icon: Icon(
                        _playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 18),
                    label: _playing ? '暂停' : '播放',
                  ),
                  const SizedBox(width: 12),
                  MeetingActionButton(
                    onPressed:
                        controller == null || _loading || _errorText != null
                            ? null
                            : () => _seekTo(0),
                    tone: MeetingActionTone.secondary,
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    label: '重播',
                  ),
                  const SizedBox(width: 12),
                  MeetingActionButton(
                    onPressed: () => launchUrl(widget.resourceUri,
                        mode: LaunchMode.externalApplication),
                    tone: MeetingActionTone.accent,
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: '外部打开',
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Slider(
                          value: position.inMilliseconds
                              .clamp(0, maxMs)
                              .toDouble(),
                          max: maxMs,
                          onChanged: controller == null ||
                                  _loading ||
                                  _errorText != null
                              ? null
                              : (value) {
                                  setState(() {
                                    _dragging = true;
                                    _dragPositionMs = value;
                                  });
                                },
                          onChangeEnd: controller == null ||
                                  _loading ||
                                  _errorText != null
                              ? null
                              : (value) async {
                                  setState(() {
                                    _dragging = false;
                                    _dragPositionMs = value;
                                  });
                                  await _seekTo(value);
                                },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_formatVideoDuration(position)} / ${_formatVideoDuration(duration)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              _playing ? '播放中' : '已暂停',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: palette.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoArea(BuildContext context) {
    final controller = _playerController;
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_errorText != null ||
        controller == null ||
        !controller.value.isInitialized) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.ondemand_video_outlined,
                  size: 52, color: Colors.white70),
              const SizedBox(height: 16),
              Text(
                _errorText ?? '视频暂时无法播放',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio <= 0
            ? 16 / 9
            : controller.value.aspectRatio,
        child: VideoPlayer(controller),
      ),
    );
  }
}

class VotePanel extends StatelessWidget {
  const VotePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MeetingAppScope.of(context);
    final vote = controller.session.voteItem;
    final currentUserId = controller.currentUser!.id;
    final hasVoted = vote.votedUserIds.contains(currentUserId);
    final totalVotes =
        vote.options.fold<int>(0, (sum, item) => sum + item.count);
    final hasActiveVote = vote.id != '0';
    final hideAnonymousStats = vote.anonymous &&
        !controller.isSecretaryMode &&
        vote.stage != VoteStage.published;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child:
                    _header(context, '投票表决', '支持实名或匿名表决，秘书可控制开始、结束、重置和发布结果。')),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed:
                  controller.refreshingVotes ? null : controller.refreshVotes,
              icon: const Icon(Icons.refresh_outlined),
              label: const Text('刷新表决'),
            ),
          ],
        ),
        if (controller.bootstrapError != null) ...[
          const SizedBox(height: 12),
          _statusBanner(context, controller.bootstrapError!,
              icon: Icons.error_outline_rounded),
        ],
        const SizedBox(height: 16),
        Expanded(
          child: !hasActiveVote
              ? _panelStateCard(
                  context,
                  icon: Icons.how_to_vote_outlined,
                  title: '当前暂无表决',
                  message: '秘书发布表决后，当前页面会实时显示表决状态和结果。',
                  actionLabel: '刷新表决',
                  onAction: controller.refreshingVotes
                      ? null
                      : controller.refreshVotes,
                )
              : Row(
                  children: [
                    Expanded(
                      child: MeetingSurfaceCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vote.title,
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 12),
                            Text(vote.description),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                MeetingStatusPill(
                                    label: '状态：${vote.stage.label}'),
                                MeetingStatusPill(
                                    label: vote.anonymous ? '匿名表决' : '实名表决',
                                    tone: MeetingStatusTone.accent),
                                MeetingStatusPill(
                                    label: hideAnonymousStats
                                        ? '已投状态：${hasVoted ? '本人已投' : '等待投票'}'
                                        : '已投人数：${vote.votedUserIds.length}/${controller.session.users.length}'),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ...vote.options.map(
                              (option) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: MeetingActionButton(
                                    onPressed: vote.stage == VoteStage.active &&
                                            !hasVoted
                                        ? () => controller.vote(option.id)
                                        : null,
                                    tone: MeetingActionTone.secondary,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      child: Text(option.label),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (hasVoted)
                              Text('当前账号已提交表决。',
                                  style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MeetingSurfaceCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('实时统计',
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 16),
                            if (hideAnonymousStats)
                              _panelStateCard(
                                context,
                                icon: Icons.visibility_off_outlined,
                                title: '匿名结果暂不公开',
                                message: vote.stage == VoteStage.active
                                    ? '匿名表决进行中，统计结果将在发布后显示。'
                                    : '匿名表决已结束，秘书发布后显示汇总结果。',
                              )
                            else
                            ...vote.options.map(
                              (option) {
                                final percent = totalVotes == 0
                                    ? 0.0
                                    : option.count / totalVotes;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(option.label),
                                          Text('${option.count} 票'),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(value: percent),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class SignaturePanel extends StatefulWidget {
  const SignaturePanel({super.key});

  @override
  State<SignaturePanel> createState() => _SignaturePanelState();
}

class _SignaturePanelState extends State<SignaturePanel> {
  final GlobalKey _signatureBoundaryKey = GlobalKey();
  String? submitMessage;

  Future<List<int>> _capturePngBytes() async {
    final boundary = _signatureBoundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError('签名画布未初始化');
    }
    final image = await boundary.toImage(pixelRatio: 2);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('签名导出失败');
    }
    return byteData.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final controller = MeetingAppScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context, '手写签名', '采集全屏手写笔迹并留存服务器。'),
        const SizedBox(height: 16),
        Expanded(
          child: MeetingSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('请在下方签字区域完成电子签名。',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Expanded(
                  child: RepaintBoundary(
                    key: _signatureBoundaryKey,
                    child: SignaturePad(
                      points: controller.signaturePoints,
                      onPanStart: (details) =>
                          controller.addSignaturePoint(details.localPosition),
                      onPanUpdate: (details) =>
                          controller.addSignaturePoint(details.localPosition),
                      onPanEnd: controller.addSignatureBreak,
                    ),
                  ),
                ),
                if (submitMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(submitMessage!,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    FilledButton(
                      onPressed: controller.submittingSignature
                          ? null
                          : () async {
                              try {
                                final pngBytes = await _capturePngBytes();
                                final message =
                                    await controller.submitSignature(pngBytes);
                                if (!mounted) return;
                                setState(() {
                                  submitMessage = message == null
                                      ? '签名已提交'
                                      : '签名文件：$message';
                                });
                              } catch (error) {
                                if (!mounted) return;
                                setState(() {
                                  submitMessage = '签名导出失败：$error';
                                });
                              }
                            },
                      child: Text(
                          controller.submittingSignature ? '提交中...' : '提交签名'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: controller.clearSignature,
                      child: const Text('清空画板'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ServicePanel extends StatefulWidget {
  const ServicePanel({super.key});

  @override
  State<ServicePanel> createState() => _ServicePanelState();
}

class _ServicePanelState extends State<ServicePanel> {
  String category = '茶水服务';
  final detailController = TextEditingController();

  @override
  void dispose() {
    detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = MeetingAppScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context, '呼叫服务', '会场后勤请求提交与处理进度回执。'),
        if (controller.bootstrapError != null) ...[
          const SizedBox(height: 12),
          _statusBanner(context, controller.bootstrapError!,
              icon: Icons.error_outline_rounded),
        ],
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: MeetingSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('发起服务请求',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: category,
                        decoration: const InputDecoration(labelText: '服务类别'),
                        items: const ['茶水服务', '纸笔服务', '设备支持']
                            .map((item) => DropdownMenuItem<String>(
                                value: item, child: Text(item)))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => category = value ?? category),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: detailController,
                        decoration: const InputDecoration(labelText: '补充说明'),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          controller.addServiceRequest(
                            category: category,
                            detail: detailController.text.trim().isEmpty
                                ? '无补充说明'
                                : detailController.text.trim(),
                          );
                          detailController.clear();
                        },
                        child: const Text('发送请求'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: MeetingSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('服务回执',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      Expanded(
                        child: controller.session.serviceRequests.isEmpty
                            ? _panelStateCard(
                                context,
                                icon: Icons.room_service_outlined,
                                title: '暂无服务回执',
                                message: '提交服务请求后，这里会显示受理与处理进度。',
                                compact: true,
                              )
                            : ListView.separated(
                                itemCount:
                                    controller.session.serviceRequests.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item =
                                      controller.session.serviceRequests[index];
                                  return MeetingInsetBox(
                                    padding: EdgeInsets.zero,
                                    child: ListTile(
                                      title: Text(
                                          '${item.category} · ${item.requesterName}'),
                                      subtitle: Text(
                                          '${item.seatName}｜${item.detail}'),
                                      trailing: MeetingStatusPill(
                                        label: item.status.label,
                                        tone: item.status ==
                                                ServiceStatus.completed
                                            ? MeetingStatusTone.success
                                            : item.status ==
                                                    ServiceStatus.canceled
                                                ? MeetingStatusTone.danger
                                                : item.status ==
                                                        ServiceStatus.processing
                                                    ? MeetingStatusTone.warning
                                                    : MeetingStatusTone.neutral,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class NoticePanel extends StatelessWidget {
  const NoticePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MeetingAppScope.of(context);
    final notice = controller.currentNoticeOrNull;
    final total = controller.session.notices.length;
    final current = notice == null ? 0 : controller.noticeIndex + 1;
    final unreadCount = controller.session.notices
        .where((item) => !controller.isNoticeRead(item.id))
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _header(context, '会议通知', '支持广播消息历史轮播与实时查阅。')),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: controller.refreshingNotices
                  ? null
                  : controller.refreshNotices,
              icon: const Icon(Icons.refresh_outlined),
              label: const Text('刷新通知'),
            ),
          ],
        ),
        if (controller.bootstrapError != null) ...[
          const SizedBox(height: 12),
          _statusBanner(context, controller.bootstrapError!,
              icon: Icons.error_outline_rounded),
        ],
        const SizedBox(height: 16),
        Expanded(
          child: notice == null
              ? _panelStateCard(
                  context,
                  icon: Icons.notifications_none_rounded,
                  title: '暂无通知',
                  message: '当前会议还没有通知记录，秘书发送广播后会出现在这里。',
                  actionLabel: '刷新通知',
                  onAction: controller.refreshingNotices
                      ? null
                      : controller.refreshNotices,
                )
              : MeetingSurfaceCard(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notice.title,
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(_formatTime(notice.createdAt),
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          MeetingStatusPill(label: '第 $current / $total 条'),
                          MeetingStatusPill(
                            label: '未读 $unreadCount 条',
                            tone: unreadCount == 0
                                ? MeetingStatusTone.success
                                : MeetingStatusTone.warning,
                          ),
                          MeetingStatusPill(
                            label: controller.isNoticeRead(notice.id)
                                ? '已读'
                                : '未读',
                            tone: controller.isNoticeRead(notice.id)
                                ? MeetingStatusTone.success
                                : MeetingStatusTone.warning,
                          ),
                          MeetingStatusPill(
                            label: controller.isNoticePinned(notice.id)
                                ? '已置顶'
                                : '普通',
                            tone: controller.isNoticePinned(notice.id)
                                ? MeetingStatusTone.accent
                                : MeetingStatusTone.neutral,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Text(
                          notice.content,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Row(
                        children: [
                          MeetingActionButton(
                            onPressed: controller.toggleNoticeAutoPlay,
                            label: controller.noticeAutoPlay ? '关闭轮播' : '自动轮播',
                          ),
                          const SizedBox(width: 12),
                          MeetingActionButton(
                            onPressed: () =>
                                controller.toggleNoticePinned(notice.id),
                            label: controller.isNoticePinned(notice.id)
                                ? '取消置顶'
                                : '置顶通知',
                          ),
                          const SizedBox(width: 12),
                          MeetingActionButton(
                            onPressed: () {
                              controller.previousNotice();
                            },
                            label: '上一条',
                          ),
                          const SizedBox(width: 12),
                          MeetingActionButton(
                            onPressed: () {
                              controller.nextNotice();
                            },
                            tone: MeetingActionTone.accent,
                            label: '下一条',
                          ),
                          const SizedBox(width: 12),
                          MeetingActionButton(
                            onPressed: controller.loadingMoreNotices ||
                                    controller.session.notices.length >=
                                        controller.noticeTotal
                                ? null
                                : controller.loadMoreNotices,
                            label: controller.loadingMoreNotices
                                ? '加载中...'
                                : '加载更多',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class TimerPanel extends StatefulWidget {
  const TimerPanel({super.key});

  @override
  State<TimerPanel> createState() => _TimerPanelState();
}

class _TimerPanelState extends State<TimerPanel> {
  double minuteValue = 5;
  bool countDown = true;

  @override
  Widget build(BuildContext context) {
    final controller = MeetingAppScope.of(context);
    final timerState = controller.timerState;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context, '会议计时器',
            timerState.controlled ? '当前显示秘书统一下发的计时。' : '支持正计时与倒计时，适用于发言控制。'),
        const SizedBox(height: 16),
        Expanded(
          child: MeetingSurfaceCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const SizedBox(height: 16),
                if (timerState.speaker != null && timerState.speaker!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MeetingStatusPill(
                      label: '当前发言：${timerState.speaker}',
                      tone: MeetingStatusTone.accent,
                    ),
                  ),
                Text(_formatDuration(timerState.remainingSeconds),
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 24),
                Slider(
                  value: minuteValue,
                  min: 1,
                  max: 60,
                  divisions: 59,
                  label: '${minuteValue.round()} 分钟',
                  onChanged: (value) => setState(() => minuteValue = value),
                ),
                MeetingInsetBox(
                  radius: 12,
                  padding: EdgeInsets.zero,
                  child: SwitchListTile(
                    value: countDown,
                    title: const Text('倒计时模式'),
                    subtitle: Text(countDown ? '结束时自动停止' : '从 00:00 开始累计'),
                    onChanged: (value) => setState(() => countDown = value),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: [
                    MeetingActionButton(
                      onPressed: () {
                        controller.setTimer(
                            minutes: minuteValue.round(), countDown: countDown);
                        controller.startTimer();
                      },
                      tone: MeetingActionTone.primary,
                      label: '开始',
                    ),
                    MeetingActionButton(
                      onPressed: controller.stopTimer,
                      label: '暂停',
                    ),
                    MeetingActionButton(
                      onPressed: () => controller.stopTimer(reset: true),
                      label: '重置',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SecretaryPanel extends StatefulWidget {
  const SecretaryPanel({super.key});

  @override
  State<SecretaryPanel> createState() => _SecretaryPanelState();
}

class _SecretaryPanelState extends State<SecretaryPanel> {
  final titleController = TextEditingController(text: '会议广播');
  final contentController = TextEditingController(text: '请相关人员返回同屏，准备进入下一项议题。');
  MeetingUser? forceLogoutTarget;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = MeetingAppScope.of(context);
    final palette = context.meetingPalette;
    final logoutCandidates = controller.session.users
        .where((item) => item.id != controller.currentUser?.id)
        .toList();
    final targetStillExists =
        logoutCandidates.any((item) => item.id == forceLogoutTarget?.id);
    if (!targetStillExists) {
      forceLogoutTarget =
          logoutCandidates.isNotEmpty ? logoutCandidates.first : null;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context, '秘书控制台', '覆盖表决控制、同屏调度、服务处理和全局强制控制。'),
        const SizedBox(height: 20),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    MeetingSurfaceCard(
                      radius: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('表决控制中心',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              MeetingStatusPill(
                                  label:
                                      '当前议题：${controller.session.voteItem.title}',
                                  icon: Icons.how_to_vote_outlined),
                              MeetingStatusPill(
                                label:
                                    '状态：${controller.session.voteItem.stage.label}',
                                tone: controller.session.voteItem.stage ==
                                        VoteStage.active
                                    ? MeetingStatusTone.accent
                                    : controller.session.voteItem.stage ==
                                            VoteStage.finished
                                        ? MeetingStatusTone.warning
                                        : MeetingStatusTone.neutral,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              MeetingActionButton(
                                onPressed: controller.startVote,
                                tone: MeetingActionTone.primary,
                                label: '开始表决',
                              ),
                              MeetingActionButton(
                                onPressed: controller.finishVote,
                                label: '结束表决',
                              ),
                              MeetingActionButton(
                                onPressed: controller.resetVote,
                                label: '重置表决',
                              ),
                              MeetingActionButton(
                                onPressed: controller.publishVote,
                                tone: MeetingActionTone.accent,
                                label: '发布结果',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    MeetingSurfaceCard(
                      radius: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('同屏调度台',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          ...controller.session.syncRequests.map(
                            (item) => MeetingInsetBox(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            '${item.requesterName} · ${item.documentTitle}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium),
                                        const SizedBox(height: 6),
                                        Text('状态：${item.status.label}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                      ],
                                    ),
                                  ),
                                  if (item.status == SyncRequestStatus.pending)
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        MeetingActionButton(
                                          onPressed: () =>
                                              controller.approveSync(item.id),
                                          tone: MeetingActionTone.accent,
                                          label: '同意',
                                        ),
                                        MeetingActionButton(
                                          onPressed: () =>
                                              controller.rejectSync(item.id),
                                          label: '拒绝',
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    MeetingSurfaceCard(
                      radius: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('实时消息记录',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          ...controller.messageLog.take(8).map(
                                (item) => MeetingInsetBox(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: EdgeInsets.zero,
                                  child: ListTile(
                                    title: Text(item.type.code),
                                    subtitle: Text(
                                        '${_formatTime(item.timestamp)} · ${item.payload}'),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ListView(
                  children: [
                    MeetingSurfaceCard(
                      radius: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('呼叫服务后台处理',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          ...controller.session.serviceRequests.map(
                            (item) => MeetingInsetBox(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            '${item.requesterName} · ${item.category}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium),
                                        const SizedBox(height: 6),
                                        Text('${item.seatName}｜${item.detail}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: palette.panelBorder),
                                    ),
                                    child: DropdownButton<ServiceStatus>(
                                      value: item.status,
                                      underline: const SizedBox.shrink(),
                                      items: ServiceStatus.values
                                          .map(
                                            (status) =>
                                                DropdownMenuItem<ServiceStatus>(
                                              value: status,
                                              child: Text(status.label),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (status) {
                                        if (status != null) {
                                          controller.updateServiceStatus(
                                              item.id, status);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    MeetingSurfaceCard(
                      radius: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('全局窗口强制控制中心',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          TextField(
                            controller: titleController,
                            decoration:
                                const InputDecoration(labelText: '消息标题'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: contentController,
                            decoration:
                                const InputDecoration(labelText: '广播内容'),
                            maxLines: 3,
                          ),
                          if (logoutCandidates.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            DropdownButtonFormField<MeetingUser>(
                              initialValue: forceLogoutTarget,
                              decoration:
                                  const InputDecoration(labelText: '强制注销目标'),
                              items: logoutCandidates
                                  .map(
                                    (user) => DropdownMenuItem<MeetingUser>(
                                      value: user,
                                      child: Text(
                                          '${user.name} · ${user.role.label} · ${user.seatName}'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => forceLogoutTarget = value),
                            ),
                          ],
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              MeetingActionButton(
                                onPressed: () => controller.broadcastNotice(
                                    titleController.text,
                                    contentController.text),
                                tone: MeetingActionTone.primary,
                                label: '发送广播消息',
                              ),
                              MeetingActionButton(
                                onPressed: controller.forceStopSync,
                                label: '强制停止同屏',
                              ),
                              MeetingActionButton(
                                onPressed: controller.forceReturnSync,
                                label: '强制返回同屏',
                              ),
                              MeetingActionButton(
                                onPressed: forceLogoutTarget == null
                                    ? null
                                    : () => controller
                                        .forceLogoutUser(forceLogoutTarget!),
                                tone: MeetingActionTone.danger,
                                label: '强制注销终端',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _header(BuildContext context, String title, String subtitle) {
  final palette = context.meetingPalette;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: palette.textPrimary,
              fontSize: 30,
            ),
      ),
      const SizedBox(height: 8),
      Text(
        subtitle,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: palette.textSecondary),
      ),
    ],
  );
}

String _formatDuration(int seconds) {
  final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  final remain = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$remain';
}

String _formatTime(DateTime time) {
  final month = time.month.toString().padLeft(2, '0');
  final day = time.day.toString().padLeft(2, '0');
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '${time.year}-$month-$day $hour:$minute';
}

String _formatVideoDuration(Duration duration) {
  final totalSeconds = duration.inSeconds;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

Uri? _resolveResourceUri(AppController controller, String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }
  final normalized = raw.trim();
  final cachedPath = controller.resolveCachedResourcePath(normalized);
  if (cachedPath != null && cachedPath.isNotEmpty) {
    return Uri.file(cachedPath);
  }
  final direct = Uri.tryParse(normalized);
  if (direct != null && direct.hasScheme) {
    return direct;
  }
  return Uri.http(
    '${controller.config.serverIp}:${controller.config.port}',
    normalized.startsWith('/') ? normalized : '/$normalized',
  );
}

String? _resolveResourceSourceUrl(AppController controller, String? raw) {
  final uri = _resolveResourceUri(controller, raw);
  if (uri == null) {
    return null;
  }
  return uri.scheme == 'file' ? null : uri.toString();
}

Widget _statusBanner(
  BuildContext context,
  String message, {
  required IconData icon,
}) {
  final palette = context.meetingPalette;
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF4E8),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: palette.panelBorder),
    ),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFFB96A1B)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    ),
  );
}

Widget _panelStateCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  bool compact = false,
}) {
  final palette = context.meetingPalette;
  final content = Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? 320 : 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 40 : 52, color: palette.accent),
          const SizedBox(height: 14),
          Text(title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: palette.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            MeetingActionButton(
              onPressed: onAction,
              tone: MeetingActionTone.primary,
              label: actionLabel,
            ),
          ],
        ],
      ),
    ),
  );
  if (compact) {
    return content;
  }
  return MeetingSurfaceCard(child: content);
}

Widget _compactEmptyText(BuildContext context, String text) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium,
    ),
  );
}

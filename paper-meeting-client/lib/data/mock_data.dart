import '../models/app_models.dart';

class MockMeetingData {
  static SeedData build() {
    final users = <MeetingUser>[
      MeetingUser(
          id: 'u1',
          name: '张明',
          role: UserRole.host,
          seatName: '主席位',
          signStatus: 1,
          personalPassword: '123456',
          requirePersonalPassword: true),
      MeetingUser(
          id: 'u2',
          name: '李娜',
          role: UserRole.secretary,
          seatName: '秘书席',
          signStatus: 1),
      MeetingUser(
          id: 'u3',
          name: '王强',
          role: UserRole.attendee,
          seatName: 'A01',
          signStatus: 1),
      MeetingUser(
          id: 'u4',
          name: '陈洁',
          role: UserRole.attendee,
          seatName: 'A02',
          signStatus: 0),
    ];
    final topics = <MeetingTopic>[
      MeetingTopic(id: 't1', title: '议题一：年度经营分析'),
      MeetingTopic(id: 't2', title: '议题二：重点项目推进'),
      MeetingTopic(id: 't3', title: '议题三：预算审议'),
    ];
    final documents = <MeetingDocument>[
      MeetingDocument(
        id: 'd1',
        topicId: 't1',
        title: '2026年第一季度经营报告',
        pageCount: 18,
        summary: '涵盖经营指标、主要问题及改进建议。',
        fileType: 'pdf',
        fileUrl: '/mock/meeting/report-q1.pdf',
      ),
      MeetingDocument(
        id: 'd2',
        topicId: 't2',
        title: '重点项目进度简报',
        pageCount: 12,
        summary: '展示项目里程碑、资金执行与风险点。',
        fileType: 'pdf',
        fileUrl: '/mock/meeting/project-progress.pdf',
      ),
      MeetingDocument(
        id: 'd3',
        topicId: 't3',
        title: '年度预算草案',
        pageCount: 24,
        summary: '预算测算、预算分配及审批建议。',
        fileType: 'pdf',
        fileUrl: '/mock/meeting/budget.pdf',
      ),
    ];

    return SeedData(
      config: ConnectionConfig(
        serverIp: '192.168.10.58',
        port: 48080,
        roomName: '第一会议室',
        seatName: 'A01',
        deviceName: '华为平板-01',
      ),
      session: MeetingSession(
        meetingId: 'm1',
        meetingName: '集团办公会（2026年第5次）',
        description: '围绕季度经营、项目推进和预算审议开展的办公会议。',
        topics: topics,
        documents: documents,
        videoTitles: ['宣传片：重点项目巡礼', '培训视频：预算填报规范'],
        libraryTitles: ['公司章程（2026版）', '财务管理制度', '干部任免管理办法'],
        users: users,
        notices: <MeetingNotice>[
          MeetingNotice(
            id: 'n1',
            title: '会前提醒',
            content: '请各位与会者提前五分钟签到并确认设备静音。',
            createdAt: DateTime(2026, 3, 26, 9, 0),
          ),
          MeetingNotice(
            id: 'n2',
            title: '表决预告',
            content: '预算议题结束后将进入实名表决，请提前准备。',
            createdAt: DateTime(2026, 3, 26, 9, 45),
          ),
        ],
        voteItem: VoteItem(
          id: 'v1',
          title: '关于2026年度预算草案的表决',
          description: '请对预算草案作出同意、不同意或弃权选择。',
          anonymous: false,
          stage: VoteStage.idle,
          options: <VoteOption>[
            VoteOption(id: 'agree', label: '同意'),
            VoteOption(id: 'reject', label: '不同意'),
            VoteOption(id: 'abstain', label: '弃权'),
          ],
          votedUserIds: <String>{},
        ),
        serviceRequests: <ServiceRequest>[
          ServiceRequest(
            id: 's1',
            requesterName: '陈洁',
            seatName: 'A02',
            category: '茶水服务',
            detail: '请补充一杯热水。',
            status: ServiceStatus.pending,
          ),
        ],
        syncRequests: <SyncRequest>[
          SyncRequest(
            id: 'sr1',
            requesterName: '王强',
            documentTitle: '重点项目进度简报',
            status: SyncRequestStatus.pending,
          ),
        ],
        watermarkEnabled: true,
        meetingPasswordRequired: true,
      ),
    );
  }
}

class SeedData {
  SeedData({
    required this.config,
    required this.session,
  });

  final ConnectionConfig config;
  final MeetingSession session;
}

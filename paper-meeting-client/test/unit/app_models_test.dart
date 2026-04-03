import 'package:flutter_test/flutter_test.dart';
import 'package:paper_meeting_client/models/app_models.dart';

/// 单元测试 — 领域模型和业务逻辑
/// 优先级: P0 — 模型是所有功能的基础
void main() {
  group('UserRole', () {
    test('enum labels should be correct', () {
      expect(UserRole.attendee.label, '普通与会者');
      expect(UserRole.secretary.label, '会议秘书');
      expect(UserRole.host.label, '会议主持人');
    });
  });

  group('VoteStage', () {
    test('enum labels should be correct', () {
      expect(VoteStage.idle.label, '未开始');
      expect(VoteStage.active.label, '进行中');
      expect(VoteStage.finished.label, '已结束');
      expect(VoteStage.published.label, '已发布');
    });
  });

  group('MeetingUser', () {
    test('requiresPersonalPassword should be false if no password required', () {
      final user = MeetingUser(
        id: '1',
        name: 'Test',
        role: UserRole.attendee,
        seatName: 'A1',
        requirePersonalPassword: false,
        personalPassword: null,
      );
      expect(user.requiresPersonalPassword, isFalse);
    });

    test('requiresPersonalPassword should be true when config requires it', () {
      final user = MeetingUser(
        id: '1',
        name: 'Test',
        role: UserRole.attendee,
        seatName: 'A1',
        requirePersonalPassword: true,
        personalPassword: null,
      );
      expect(user.requiresPersonalPassword, isTrue);
    });

    test('requiresPersonalPassword should be true when password is set', () {
      final user = MeetingUser(
        id: '1',
        name: 'Test',
        role: UserRole.attendee,
        seatName: 'A1',
        requirePersonalPassword: false,
        personalPassword: 'secret',
      );
      expect(user.requiresPersonalPassword, isTrue);
    });

    test('signedIn should reflect signStatus', () {
      expect(MeetingUser(id: '1', name: 'Test', role: UserRole.attendee, seatName: 'A1', signStatus: 0).signedIn, isFalse);
      expect(MeetingUser(id: '1', name: 'Test', role: UserRole.attendee, seatName: 'A1', signStatus: 1).signedIn, isTrue);
    });
  });

  group('VoteOption', () {
    test('copyWith should update selected fields', () {
      final option = VoteOption(id: '1', label: '赞成', count: 0);
      final updated = option.copyWith(count: 5, label: '赞成票');

      expect(updated.id, '1');
      expect(updated.label, '赞成票');
      expect(updated.count, 5);
    });
  });

  group('VoteItem', () {
    test('copyWith should preserve unchanged fields', () {
      final options = [VoteOption(id: '1', label: 'A')];
      final voted = {'user1'};
      final item = VoteItem(
        id: 'vote1',
        title: '测试投票',
        description: 'desc',
        anonymous: true,
        stage: VoteStage.active,
        options: options,
        votedUserIds: voted,
      );

      final updated = item.copyWith(title: '更新标题');

      expect(updated.title, '更新标题');
      expect(updated.anonymous, true);
      expect(updated.stage, VoteStage.active);
      expect(updated.options, same(options));
      expect(updated.votedUserIds, same(voted));
    });
  });

  group('MeetingNotice', () {
    test('copyWith should update read status', () {
      final now = DateTime.now();
      final notice = MeetingNotice(id: '1', title: '通知', content: '内容', createdAt: now, read: false);
      final readNotice = notice.copyWith(read: true);

      expect(readNotice.read, isTrue);
      expect(readNotice.title, notice.title);
    });
  });

  group('ConnectionConfig', () {
    test('copyWith should update individual fields', () {
      final config = ConnectionConfig(
        serverIp: '192.168.1.1',
        port: 8080,
        roomName: '会议室A',
        seatName: 'A1',
        deviceName: 'Device1',
      );

      final updated = config.copyWith(port: 9090);

      expect(updated.serverIp, '192.168.1.1');
      expect(updated.port, 9090);
      expect(updated.roomName, '会议室A');
    });
  });

  group('VoteItem with VoteStage transitions', () {
    test('stage should transition through lifecycle', () {
      final item = VoteItem(
        id: 'vote1',
        title: '测试',
        description: 'desc',
        anonymous: true,
        stage: VoteStage.idle,
        options: [],
        votedUserIds: {},
      );

      expect(item.stage, VoteStage.idle);

      final active = item.copyWith(stage: VoteStage.active);
      expect(active.stage, VoteStage.active);

      final finished = active.copyWith(stage: VoteStage.finished);
      expect(finished.stage, VoteStage.finished);

      final published = finished.copyWith(stage: VoteStage.published);
      expect(published.stage, VoteStage.published);
    });
  });
}

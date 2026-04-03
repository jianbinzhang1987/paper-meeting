import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paper_meeting_client/widgets/common/meeting_status_pill.dart';

/// Widget 测试 — UI 组件的正确性验证
/// 优先级: P1 — 组件层测试
void main() {
  testWidgets('MeetingStatusPill should render label text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MeetingStatusPill(label: '进行中'),
        ),
      ),
    );

    expect(find.text('进行中'), findsOneWidget);
  });

  testWidgets('MeetingStatusPill should show icon when provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MeetingStatusPill(label: '成功', icon: Icons.check),
        ),
      ),
    );

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('成功'), findsOneWidget);
  });

  testWidgets('MeetingStatusPill should hide icon when not provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MeetingStatusPill(label: '仅文字'),
        ),
      ),
    );

    expect(find.byType(Icon), findsNothing);
  });
}

# 无纸化会议系统客户端工程

本目录为平板客户端独立工程，目标面向 Android 平板与 HarmonyOS 兼容环境，采用 Flutter 构建。

## 当前实现范围

- 连接设置、会议室与座位绑定
- 账号选择式登录签到
- 普通参会者主页与模块导航
- 会议文稿浏览、书签、注释、同屏申请与跟随状态
- 会议视频与公共资料库
- 投票表决
- 手写签名
- 呼叫服务与处理回执
- 会议通知
- 个人计时器
- 秘书控制台：表决控制、同屏审批、服务处理、广播与强制控制
- 断网重连状态模拟、资料预加载进度模拟、实时消息日志
- 资料、通知、表决三类数据的页面内独立刷新

## 当前目录补充

- `lib/models/client_protocol.dart`：客户端 WebSocket/信令协议模型
- `lib/repositories/`：仓储抽象与 Mock 实现
- `lib/repositories/api_meeting_repository.dart`：基于 `/meeting/app/*` 的真实接口仓储，失败时自动回退到 Mock
- `lib/services/meeting_websocket_service.dart`：基于签到返回 `accessToken` 自动连接 `/infra/ws`，接收通知、表决和强制返回等实时消息

## 启动方式

当前工作区未安装 Flutter SDK，因此未执行 `flutter create` 与构建验证。待本机补齐 Flutter 环境后执行：

```bash
flutter pub get
flutter run
```

## 后续对接建议

1. 将同屏申请/审批、服务回执和广播消息继续扩展到完整 WebSocket 协议。
2. 用 PDF 渲染插件替换当前文稿示意视图。
3. 补齐 `android/` 与 HarmonyOS 适配壳工程。

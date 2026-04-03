package cn.iocoder.yudao.module.meeting.controller.admin.notification.vo;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class MeetingNotificationReadDetailRespVO {

    private Integer attendeeCount;

    private Integer readCount;

    private Integer unreadCount;

    private Integer deliveredCount;

    private Integer failedCount;

    private Integer pendingCount;

    private List<UserReadItem> readUsers;

    private List<UserReadItem> unreadUsers;

    private List<TerminalReceiptItem> terminalReceipts;

    @Data
    public static class UserReadItem {
        private Long userId;
        private String nickname;
        private Integer role;
        private String seatId;
        private LocalDateTime readTime;
    }

    @Data
    public static class TerminalReceiptItem {
        private Long userId;
        private String nickname;
        private Integer role;
        private String seatId;
        private Boolean read;
        private LocalDateTime readTime;
        private String roomName;
        private String seatName;
        private String deviceName;
        private Boolean online;
        private String deliveryStatus;
        private String deliveryStatusText;
        private String failureReason;
        private LocalDateTime lastHeartbeatTime;
    }
}

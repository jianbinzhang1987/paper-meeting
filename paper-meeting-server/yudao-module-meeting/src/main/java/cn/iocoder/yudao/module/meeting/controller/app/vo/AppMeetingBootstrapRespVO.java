package cn.iocoder.yudao.module.meeting.controller.app.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Schema(description = "客户端 - 启动初始化 Response VO")
@Data
public class AppMeetingBootstrapRespVO {

    @Schema(description = "会议编号", example = "1001")
    private Long meetingId;

    @Schema(description = "会议名称", example = "集团办公会（2026年第5次）")
    private String meetingName;

    @Schema(description = "会议描述")
    private String description;

    @Schema(description = "会议室名称")
    private String roomName;

    @Schema(description = "设备名称")
    private String deviceName;

    @Schema(description = "座位号")
    private String seatName;

    @Schema(description = "控制方式")
    private Integer controlType;

    @Schema(description = "是否开启水印")
    private Boolean watermark;

    @Schema(description = "会议开始时间")
    private LocalDateTime startTime;

    @Schema(description = "会议结束时间")
    private LocalDateTime endTime;

    @Schema(description = "参会人员列表")
    private List<Attendee> attendees;

    @Schema(description = "议题列表")
    private List<Agenda> agendas;

    @Schema(description = "资料列表")
    private List<Document> documents;

    @Schema(description = "通知列表")
    private List<Notice> notices;

    @Schema(description = "表决列表")
    private List<Vote> votes;

    @Schema(description = "同屏申请列表")
    private List<SyncRequest> syncRequests;

    @Schema(description = "服务请求列表")
    private List<ServiceRequest> serviceRequests;

    @Data
    public static class Attendee {
        private Long attendeeId;
        private Long userId;
        private String name;
        private Integer role;
        private String roleName;
        private Integer signStatus;
        private String seatId;
    }

    @Data
    public static class Agenda {
        private Long id;
        private Long parentId;
        private String title;
        private String content;
        private Integer sort;
        private Boolean vote;
    }

    @Data
    public static class Document {
        private Long id;
        private Long agendaId;
        private String name;
        private String url;
        private String type;
        private String summary;
        private Integer pageCount;
        private String thumbnailUrl;
        private Long size;
    }

    @Data
    public static class Notice {
        private Long id;
        private String content;
        private Integer publishStatus;
        private LocalDateTime publishedTime;
        private LocalDateTime createTime;
    }

    @Data
    public static class Vote {
        private Long id;
        private Long agendaId;
        private String title;
        private Integer type;
        private Boolean secret;
        private Integer status;
        private LocalDateTime createTime;
        private Boolean currentUserVoted;
        private Integer totalVotedCount;
        private List<VoteOption> options;
    }

    @Data
    public static class VoteOption {
        private Long id;
        private String content;
        private Integer sort;
        private Integer voteCount;
    }

    @Data
    public static class SyncRequest {
        private String requestId;
        private Long requesterUserId;
        private String requesterName;
        private String requesterSeatName;
        private String documentId;
        private String documentTitle;
        private Integer page;
        private String status;
        private Long approverUserId;
        private String approverName;
    }

    @Data
    public static class ServiceRequest {
        private String requestId;
        private Long requesterUserId;
        private String requesterName;
        private String requesterSeatName;
        private String category;
        private String detail;
        private String status;
        private Long handlerUserId;
        private String handlerName;
    }
}

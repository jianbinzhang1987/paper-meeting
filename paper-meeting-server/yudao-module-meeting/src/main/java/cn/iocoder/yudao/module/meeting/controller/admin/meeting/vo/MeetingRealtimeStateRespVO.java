package cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.util.List;

@Schema(description = "管理后台 - 会议实时状态 Response VO")
@Data
public class MeetingRealtimeStateRespVO {

    @Schema(description = "同屏申请列表")
    private List<SyncRequest> syncRequests;

    @Schema(description = "服务请求列表")
    private List<ServiceRequest> serviceRequests;

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

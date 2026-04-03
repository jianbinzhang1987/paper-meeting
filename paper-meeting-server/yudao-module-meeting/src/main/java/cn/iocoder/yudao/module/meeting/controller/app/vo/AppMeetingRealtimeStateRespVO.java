package cn.iocoder.yudao.module.meeting.controller.app.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Schema(description = "客户端 - 会议实时状态 Response VO")
@Data
public class AppMeetingRealtimeStateRespVO {

    @Schema(description = "同屏申请列表")
    private List<AppMeetingBootstrapRespVO.SyncRequest> syncRequests;

    @Schema(description = "服务请求列表")
    private List<AppMeetingBootstrapRespVO.ServiceRequest> serviceRequests;

    @Schema(description = "当前视频同步状态")
    private VideoState videoState;

    @Schema(description = "当前会议计时状态")
    private TimerState timerState;

    @Data
    public static class VideoState {
        private String documentId;
        private String documentTitle;
        private String action;
        private Long positionMs;
        private Boolean playing;
        private Long operatorUserId;
        private String operatorName;
        private LocalDateTime sentTime;
    }

    @Data
    public static class TimerState {
        private Integer totalSeconds;
        private Integer remainingSeconds;
        private Boolean countDown;
        private Boolean running;
        private String speaker;
        private Long operatorUserId;
        private String operatorName;
        private LocalDateTime sentTime;
    }
}

package cn.iocoder.yudao.module.meeting.controller.app.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.util.List;

@Schema(description = "客户端 - 会议实时状态 Response VO")
@Data
public class AppMeetingRealtimeStateRespVO {

    @Schema(description = "同屏申请列表")
    private List<AppMeetingBootstrapRespVO.SyncRequest> syncRequests;

    @Schema(description = "服务请求列表")
    private List<AppMeetingBootstrapRespVO.ServiceRequest> serviceRequests;
}

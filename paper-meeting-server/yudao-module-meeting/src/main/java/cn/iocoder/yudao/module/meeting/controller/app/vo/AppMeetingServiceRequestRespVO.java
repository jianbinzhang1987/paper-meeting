package cn.iocoder.yudao.module.meeting.controller.app.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Schema(description = "客户端 - 服务请求 Response VO")
@Data
public class AppMeetingServiceRequestRespVO {

    private String requestId;

    private Long requesterUserId;

    private String requesterName;

    private String requesterSeatName;

    private String category;

    private String detail;

    private String status;

    private Long handlerUserId;

    private String handlerName;

    private LocalDateTime acceptedAt;

    private LocalDateTime completedAt;

    private LocalDateTime canceledAt;

    private String resultRemark;
}

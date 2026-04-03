package cn.iocoder.yudao.module.meeting.controller.admin.terminal.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Schema(description = "管理后台 - 终端状态汇总 Response VO")
@Data
public class MeetingTerminalStatusSummaryRespVO {

    @Schema(description = "终端总数")
    private Integer totalCount;

    @Schema(description = "在线终端数")
    private Integer onlineCount;

    @Schema(description = "命中当前配置终端数")
    private Integer matchedCount;

    @Schema(description = "未命中当前配置终端数")
    private Integer pendingCount;

    @Schema(description = "最近一次心跳时间")
    private LocalDateTime latestHeartbeatTime;
}

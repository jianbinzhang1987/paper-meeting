package cn.iocoder.yudao.module.meeting.controller.admin.terminal.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Schema(description = "管理后台 - 终端配置下发 Response VO")
@Data
public class MeetingTerminalDispatchRespVO {

    @Schema(description = "配置类型", example = "app-version")
    private String targetType;

    @Schema(description = "目标配置编号", example = "12")
    private Long targetId;

    @Schema(description = "总终端数")
    private Integer totalCount;

    @Schema(description = "已下发数")
    private Integer dispatchedCount;

    @Schema(description = "失败数")
    private Integer failedCount;

    @Schema(description = "已命中数")
    private Integer matchedCount;

    @Schema(description = "终端结果列表")
    private List<Item> items;

    @Data
    public static class Item {

        private Long terminalId;

        private Integer clientType;

        private String roomName;

        private String seatName;

        private String deviceName;

        private Boolean online;

        private String currentValue;

        private Boolean matched;

        private String deliveryStatus;

        private String deliveryStatusText;

        private String failureReason;

        private LocalDateTime lastHeartbeatTime;
    }
}

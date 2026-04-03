package cn.iocoder.yudao.module.meeting.controller.admin.terminal.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Schema(description = "管理后台 - 终端状态 Response VO")
@Data
public class MeetingTerminalStatusRespVO {

    private Long id;

    private Integer clientType;

    private String roomName;

    private String seatName;

    private String deviceName;

    private Long meetingId;

    private String meetingName;

    private Long userId;

    private String userName;

    private String themeMode;

    private String connectionStatus;

    private Long appVersionId;

    private String appVersionName;

    private Integer appVersionCode;

    private Long uiConfigId;

    private String uiConfigName;

    private Long brandingId;

    private String brandingName;

    private LocalDateTime lastBootstrapTime;

    private LocalDateTime lastHeartbeatTime;

    @Schema(description = "是否在线")
    private Boolean online;

    @Schema(description = "是否命中当前选中配置")
    private Boolean matchSelected;
}

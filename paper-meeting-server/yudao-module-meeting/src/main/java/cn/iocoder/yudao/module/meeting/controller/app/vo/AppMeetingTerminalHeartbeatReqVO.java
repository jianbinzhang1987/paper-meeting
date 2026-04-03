package cn.iocoder.yudao.module.meeting.controller.app.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Schema(description = "客户端 - 终端心跳上报 Request VO")
@Data
public class AppMeetingTerminalHeartbeatReqVO {

    @Schema(description = "客户端类型", requiredMode = Schema.RequiredMode.REQUIRED, example = "1")
    @NotNull(message = "客户端类型不能为空")
    private Integer clientType;

    @Schema(description = "会议室名称", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank(message = "会议室名称不能为空")
    private String roomName;

    @Schema(description = "座位名称", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank(message = "座位名称不能为空")
    private String seatName;

    @Schema(description = "设备名称", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank(message = "设备名称不能为空")
    private String deviceName;

    @Schema(description = "会议编号", example = "1001")
    private Long meetingId;

    @Schema(description = "会议名称", example = "集团办公会")
    private String meetingName;

    @Schema(description = "登录用户编号", example = "1")
    private Long userId;

    @Schema(description = "登录用户名", example = "张三")
    private String userName;

    @Schema(description = "主题模式", example = "dark")
    private String themeMode;

    @Schema(description = "连接状态", example = "online")
    private String connectionStatus;

    @Schema(description = "当前安装包记录编号", example = "10")
    private Long appVersionId;

    @Schema(description = "当前安装包名称", example = "安卓客户端 0.1.0")
    private String appVersionName;

    @Schema(description = "当前安装包版本号", example = "1")
    private Integer appVersionCode;

    @Schema(description = "当前样式编号", example = "3")
    private Long uiConfigId;

    @Schema(description = "当前样式名称", example = "标准红金")
    private String uiConfigName;

    @Schema(description = "当前贴牌编号", example = "2")
    private Long brandingId;

    @Schema(description = "当前贴牌名称", example = "集团会议中心")
    private String brandingName;
}

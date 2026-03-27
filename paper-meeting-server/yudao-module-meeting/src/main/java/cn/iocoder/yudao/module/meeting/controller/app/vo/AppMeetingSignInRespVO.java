package cn.iocoder.yudao.module.meeting.controller.app.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Schema(description = "客户端 - 会议签到 Response VO")
@Data
public class AppMeetingSignInRespVO {

    @Schema(description = "会议编号", example = "1001")
    private Long meetingId;

    @Schema(description = "用户编号", example = "2001")
    private Long userId;

    @Schema(description = "用户昵称", example = "张明")
    private String nickname;

    @Schema(description = "角色", example = "1")
    private Integer role;

    @Schema(description = "角色名称", example = "主持人")
    private String roleName;

    @Schema(description = "座位号", example = "A01")
    private String seatId;

    @Schema(description = "签到状态", example = "1")
    private Integer signStatus;

    @Schema(description = "签到时间")
    private LocalDateTime signInTime;

    @Schema(description = "实时消息 accessToken")
    private String accessToken;

    @Schema(description = "实时消息 token 过期时间")
    private LocalDateTime accessTokenExpiresTime;

    @Schema(description = "WebSocket 路径", example = "/infra/ws")
    private String websocketPath;
}

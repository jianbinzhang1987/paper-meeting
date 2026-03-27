package cn.iocoder.yudao.module.meeting.controller.app.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Schema(description = "客户端 - 会议签到 Request VO")
@Data
public class AppMeetingSignInReqVO {

    @Schema(description = "会议编号", requiredMode = Schema.RequiredMode.REQUIRED, example = "1001")
    @NotNull(message = "会议编号不能为空")
    private Long meetingId;

    @Schema(description = "用户编号", requiredMode = Schema.RequiredMode.REQUIRED, example = "2001")
    @NotNull(message = "用户编号不能为空")
    private Long userId;

    @Schema(description = "会议密码", example = "123456")
    private String password;

    @Schema(description = "设备名称", example = "华为平板-01")
    private String deviceName;
}

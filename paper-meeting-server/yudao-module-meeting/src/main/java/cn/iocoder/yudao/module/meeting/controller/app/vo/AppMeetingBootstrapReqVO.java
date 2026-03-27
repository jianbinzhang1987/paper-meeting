package cn.iocoder.yudao.module.meeting.controller.app.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Schema(description = "客户端 - 启动初始化 Request VO")
@Data
public class AppMeetingBootstrapReqVO {

    @Schema(description = "会议室名称", requiredMode = Schema.RequiredMode.REQUIRED, example = "第一会议室")
    @NotBlank(message = "会议室名称不能为空")
    private String roomName;

    @Schema(description = "座位号", example = "A01")
    private String seatName;

    @Schema(description = "设备名称", example = "华为平板-01")
    private String deviceName;
}

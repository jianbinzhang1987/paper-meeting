package cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Schema(description = "管理后台 - 会议排座 Request VO")
@Data
public class MeetingSeatAssignReqVO {

    @Schema(description = "参会人编号", requiredMode = Schema.RequiredMode.REQUIRED, example = "1")
    @NotNull(message = "参会人编号不能为空")
    private Long attendeeId;

    @Schema(description = "座位编号，为空时清空座位", example = "A-01")
    private String seatId;
}

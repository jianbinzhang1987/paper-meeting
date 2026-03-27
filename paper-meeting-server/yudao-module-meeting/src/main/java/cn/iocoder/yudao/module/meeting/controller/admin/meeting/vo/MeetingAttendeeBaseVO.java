package cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import jakarta.validation.constraints.NotNull;

@Data
public class MeetingAttendeeBaseVO {

    @Schema(description = "会议编号", requiredMode = Schema.RequiredMode.REQUIRED, example = "1024")
    @NotNull(message = "会议编号不能为空")
    private Long meetingId;

    @Schema(description = "用户编号", requiredMode = Schema.RequiredMode.REQUIRED, example = "2048")
    @NotNull(message = "用户编号不能为空")
    private Long userId;

    @Schema(description = "角色", example = "0")
    private Integer role;

    @Schema(description = "签到状态", example = "0")
    private Integer status;

    @Schema(description = "座次编号", example = "A-1")
    private String seatId;

}

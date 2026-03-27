package cn.iocoder.yudao.module.meeting.controller.admin.notification.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class MeetingNotificationBaseVO {

    @Schema(description = "会议编号", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull(message = "会议编号不能为空")
    private Long meetingId;

    @Schema(description = "通知内容", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull(message = "通知内容不能为空")
    private String content;

    @Schema(description = "发布状态")
    private Integer publishStatus;
}

package cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Schema(description = "管理后台 - 会议审批 Request VO")
@Data
public class MeetingApproveReqVO {

    @Schema(description = "会议编号", requiredMode = Schema.RequiredMode.REQUIRED, example = "1")
    @NotNull(message = "会议编号不能为空")
    private Long id;

    @Schema(description = "是否通过", requiredMode = Schema.RequiredMode.REQUIRED, example = "true")
    @NotNull(message = "审批结果不能为空")
    private Boolean approved;

    @Schema(description = "审批意见", example = "会议安排合理，同意召开")
    private String remark;
}

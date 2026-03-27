package cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Schema(description = "管理后台 - 撤销会议审批 Request VO")
@Data
public class MeetingApprovalCancelReqVO {

    @Schema(description = "会议编号", requiredMode = Schema.RequiredMode.REQUIRED, example = "1")
    @NotNull(message = "会议编号不能为空")
    private Long id;

    @Schema(description = "撤销原因", example = "时间冲突，暂缓提交")
    private String remark;
}

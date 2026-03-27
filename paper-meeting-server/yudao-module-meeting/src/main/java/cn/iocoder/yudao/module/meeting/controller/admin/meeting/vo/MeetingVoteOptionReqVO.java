package cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Schema(description = "管理后台 - 会议表决选项 Request VO")
@Data
public class MeetingVoteOptionReqVO {

    @Schema(description = "选项内容", requiredMode = Schema.RequiredMode.REQUIRED, example = "同意")
    @NotBlank(message = "选项内容不能为空")
    private String content;

    @Schema(description = "排序", example = "1")
    private Integer sort;
}

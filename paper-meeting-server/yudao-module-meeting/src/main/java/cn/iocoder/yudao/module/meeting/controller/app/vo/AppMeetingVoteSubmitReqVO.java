package cn.iocoder.yudao.module.meeting.controller.app.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Schema(description = "客户端 - 提交表决 Request VO")
@Data
public class AppMeetingVoteSubmitReqVO {

    @Schema(description = "表决编号", requiredMode = Schema.RequiredMode.REQUIRED, example = "1")
    @NotNull(message = "表决编号不能为空")
    private Long voteId;

    @Schema(description = "用户编号", requiredMode = Schema.RequiredMode.REQUIRED, example = "2001")
    @NotNull(message = "用户编号不能为空")
    private Long userId;

    @Schema(description = "选项编号", requiredMode = Schema.RequiredMode.REQUIRED, example = "11")
    @NotNull(message = "选项编号不能为空")
    private Long optionId;
}

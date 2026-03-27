package cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo;

import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Schema(description = "管理后台 - 会议表决新增 Request VO")
@Data
public class MeetingVoteCreateReqVO {

    @Schema(description = "会议编号", requiredMode = Schema.RequiredMode.REQUIRED, example = "1024")
    @NotNull(message = "会议编号不能为空")
    private Long meetingId;

    @Schema(description = "关联议题编号", example = "2048")
    private Long agendaId;

    @Schema(description = "表决标题", requiredMode = Schema.RequiredMode.REQUIRED, example = "关于预算方案的表决")
    @NotBlank(message = "表决标题不能为空")
    private String title;

    @Schema(description = "类型", requiredMode = Schema.RequiredMode.REQUIRED, example = "0")
    @NotNull(message = "表决类型不能为空")
    private Integer type;

    @Schema(description = "是否匿名", example = "true")
    private Boolean isSecret;

    @Schema(description = "状态", example = "0")
    private Integer status;

    @ArraySchema(schema = @Schema(implementation = MeetingVoteOptionReqVO.class))
    @NotEmpty(message = "表决选项不能为空")
    @Valid
    private List<MeetingVoteOptionReqVO> options;
}

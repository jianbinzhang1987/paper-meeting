package cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import jakarta.validation.constraints.NotNull;

@Schema(description = "管理后台 - 会议更新 Request VO")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingUpdateReqVO extends MeetingBaseVO {

    @Schema(description = "会议编号", requiredMode = Schema.RequiredMode.REQUIRED, example = "1024")
    @NotNull(message = "会议编号不能为空")
    private Long id;

}

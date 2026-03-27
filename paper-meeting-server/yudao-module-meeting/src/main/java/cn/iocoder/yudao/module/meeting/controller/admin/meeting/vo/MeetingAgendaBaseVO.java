package cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import jakarta.validation.constraints.NotNull;

@Data
public class MeetingAgendaBaseVO {

    @Schema(description = "会议编号", requiredMode = Schema.RequiredMode.REQUIRED, example = "1024")
    @NotNull(message = "会议编号不能为空")
    private Long meetingId;

    @Schema(description = "父议题编号", example = "0")
    private Long parentId;

    @Schema(description = "议题标题", requiredMode = Schema.RequiredMode.REQUIRED, example = "开场白")
    @NotNull(message = "议题标题不能为空")
    private String title;

    @Schema(description = "议题内容", example = "欢迎各位领导莅临")
    private String content;

    @Schema(description = "排序", example = "1")
    private Integer sort;

    @Schema(description = "是否包含表决", example = "false")
    private Boolean isVote;

}

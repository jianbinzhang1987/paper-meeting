package cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;

/**
 * 会议 Base VO
 */
@Data
public class MeetingBaseVO {

    @Schema(description = "会议名称", requiredMode = Schema.RequiredMode.REQUIRED, example = "周例会")
    @NotNull(message = "会议名称不能为空")
    private String name;

    @Schema(description = "会议简述", example = "讨论本周工作计划")
    private String description;

    @Schema(description = "开始时间", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull(message = "开始时间不能为空")
    private LocalDateTime startTime;

    @Schema(description = "结束时间", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull(message = "结束时间不能为空")
    private LocalDateTime endTime;

    @Schema(description = "会议室编号", example = "1024")
    private Long roomId;

    @Schema(description = "状态", requiredMode = Schema.RequiredMode.REQUIRED, example = "0")
    @NotNull(message = "状态不能为空")
    private Integer status;

    @Schema(description = "类型", requiredMode = Schema.RequiredMode.REQUIRED, example = "0")
    @NotNull(message = "类型不能为空")
    private Integer type;

    @Schema(description = "保密级别", example = "0")
    private Integer level;

    @Schema(description = "控制方式（0秘书控制 1自由控制）", example = "0")
    private Integer controlType;

    @Schema(description = "是否需要审批")
    private Boolean requireApproval;

    @Schema(description = "是否添加水印")
    private Boolean watermark;

    @Schema(description = "会议记录")
    private String summary;

}

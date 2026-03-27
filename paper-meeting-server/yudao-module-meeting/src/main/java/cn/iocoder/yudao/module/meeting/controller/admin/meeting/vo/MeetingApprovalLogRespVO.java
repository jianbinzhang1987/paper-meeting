package cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Schema(description = "管理后台 - 会议审批记录 Response VO")
@Data
public class MeetingApprovalLogRespVO {

    @Schema(description = "编号", example = "1")
    private Long id;

    @Schema(description = "会议编号", example = "1")
    private Long meetingId;

    @Schema(description = "操作类型", example = "2")
    private Integer action;

    @Schema(description = "操作类型名称", example = "审批通过")
    private String actionName;

    @Schema(description = "操作人编号", example = "1")
    private Long operatorId;

    @Schema(description = "操作人姓名", example = "管理员")
    private String operatorName;

    @Schema(description = "审批意见", example = "同意召开")
    private String remark;

    @Schema(description = "操作时间")
    private LocalDateTime createTime;
}

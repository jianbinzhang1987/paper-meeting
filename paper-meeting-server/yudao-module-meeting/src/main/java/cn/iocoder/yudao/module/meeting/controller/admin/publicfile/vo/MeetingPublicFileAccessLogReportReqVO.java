package cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class MeetingPublicFileAccessLogReportReqVO {

    @NotNull(message = "资料编号不能为空")
    private Long fileId;

    private Long meetingId;

    private Long userId;

    @NotBlank(message = "访问类型不能为空")
    private String accessType;

    private String source;

    private String operatorName;
}

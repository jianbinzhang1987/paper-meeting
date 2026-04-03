package cn.iocoder.yudao.module.meeting.controller.app.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Schema(description = "客户端 - 通知已读 Request VO")
@Data
public class AppMeetingNoticeReadReqVO {

    @NotNull(message = "会议编号不能为空")
    private Long meetingId;

    @NotNull(message = "用户编号不能为空")
    private Long userId;

    @NotNull(message = "通知编号不能为空")
    private Long noticeId;
}

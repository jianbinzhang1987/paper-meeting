package cn.iocoder.yudao.module.meeting.controller.app.vo;

import cn.iocoder.yudao.framework.common.pojo.PageParam;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Schema(description = "客户端 - 通知分页 Request VO")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class AppMeetingNoticePageReqVO extends PageParam {

    @NotNull(message = "会议编号不能为空")
    private Long meetingId;

    @Schema(description = "用户编号")
    private Long userId;
}

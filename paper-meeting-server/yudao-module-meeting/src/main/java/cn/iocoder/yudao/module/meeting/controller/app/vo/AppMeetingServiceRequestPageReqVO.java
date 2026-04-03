package cn.iocoder.yudao.module.meeting.controller.app.vo;

import cn.iocoder.yudao.framework.common.pojo.PageParam;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Schema(description = "客户端 - 服务请求分页 Request VO")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class AppMeetingServiceRequestPageReqVO extends PageParam {

    @NotNull(message = "会议编号不能为空")
    private Long meetingId;

    @Schema(description = "按当前用户筛选")
    private Long userId;
}

package cn.iocoder.yudao.module.meeting.controller.admin.notification.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Schema(description = "管理后台 - 会议消息统计 Response VO")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingNotificationStatsRespVO extends MeetingNotificationRespVO {

    @Schema(description = "应读人数")
    private Integer attendeeCount;

    @Schema(description = "已读人数")
    private Integer readCount;

    @Schema(description = "未读人数")
    private Integer unreadCount;
}

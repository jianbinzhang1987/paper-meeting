package cn.iocoder.yudao.module.meeting.controller.admin.notification.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Schema(description = "管理后台 - 会议通知创建 Request VO")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingNotificationCreateReqVO extends MeetingNotificationBaseVO {
}

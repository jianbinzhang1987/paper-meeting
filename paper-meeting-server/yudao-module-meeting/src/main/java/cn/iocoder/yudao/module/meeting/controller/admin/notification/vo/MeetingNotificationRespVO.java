package cn.iocoder.yudao.module.meeting.controller.admin.notification.vo;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingNotificationRespVO extends MeetingNotificationBaseVO {

    private Long id;

    private LocalDateTime publishedTime;

    private LocalDateTime createTime;
}

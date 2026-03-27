package cn.iocoder.yudao.module.meeting.controller.admin.notification.vo;

import cn.iocoder.yudao.framework.common.pojo.PageParam;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingNotificationPageReqVO extends PageParam {

    private Long meetingId;

    private Integer publishStatus;

    private String content;
}

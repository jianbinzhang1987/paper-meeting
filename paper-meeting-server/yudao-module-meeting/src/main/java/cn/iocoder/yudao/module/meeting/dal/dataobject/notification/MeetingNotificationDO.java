package cn.iocoder.yudao.module.meeting.dal.dataobject.notification;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import java.time.LocalDateTime;

@TableName("meeting_notification")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingNotificationDO extends TenantBaseDO {

    @TableId
    private Long id;

    private Long meetingId;

    private String content;

    private Integer publishStatus;

    private LocalDateTime publishedTime;
}

package cn.iocoder.yudao.module.meeting.dal.dataobject.meeting;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import java.time.LocalDateTime;

@TableName("meeting_service_request")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingServiceRequestDO extends TenantBaseDO {

    @TableId
    private Long id;

    private String requestId;

    private Long meetingId;

    private Long requesterUserId;

    private String requesterName;

    private String requesterSeatName;

    private String category;

    private String detail;

    private String status;

    private Long handlerUserId;

    private String handlerName;

    private LocalDateTime acceptedAt;

    private LocalDateTime completedAt;

    private LocalDateTime canceledAt;

    private String resultRemark;
}

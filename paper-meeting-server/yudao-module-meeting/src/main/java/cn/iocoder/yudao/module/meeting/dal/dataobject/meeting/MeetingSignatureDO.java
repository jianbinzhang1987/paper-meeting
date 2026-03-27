package cn.iocoder.yudao.module.meeting.dal.dataobject.meeting;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import java.time.LocalDateTime;

@TableName("meeting_signature")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingSignatureDO extends TenantBaseDO {

    @TableId
    private Long id;

    private Long meetingId;

    private Long userId;

    private String seatId;

    private String fileUrl;

    private Integer strokeCount;

    private LocalDateTime submitTime;
}

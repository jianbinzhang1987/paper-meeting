package cn.iocoder.yudao.module.meeting.dal.dataobject.publicfile;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@TableName("meeting_public_file_access_log")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingPublicFileAccessLogDO extends TenantBaseDO {

    @TableId
    private Long id;

    private Long fileId;

    private String fileName;

    private Long meetingId;

    private Long userId;

    private String accessType;

    private String source;

    private String operatorName;
}

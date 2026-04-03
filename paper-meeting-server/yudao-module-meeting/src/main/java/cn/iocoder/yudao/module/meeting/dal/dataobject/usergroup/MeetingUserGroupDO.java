package cn.iocoder.yudao.module.meeting.dal.dataobject.usergroup;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@TableName("meeting_user_group")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingUserGroupDO extends TenantBaseDO {

    @TableId
    private Long id;

    private String name;

    private String description;

    private String userIds;

    private Boolean active;

    private String remark;
}

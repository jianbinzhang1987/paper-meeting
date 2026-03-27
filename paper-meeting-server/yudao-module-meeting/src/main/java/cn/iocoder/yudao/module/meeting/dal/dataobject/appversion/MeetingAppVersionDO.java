package cn.iocoder.yudao.module.meeting.dal.dataobject.appversion;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@TableName("meeting_app_version")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingAppVersionDO extends TenantBaseDO {

    @TableId
    private Long id;

    private Integer clientType;

    private String name;

    private String versionName;

    private Integer versionCode;

    private String downloadUrl;

    private String md5;

    private Boolean forceUpdate;

    private Boolean active;

    private String remark;
}

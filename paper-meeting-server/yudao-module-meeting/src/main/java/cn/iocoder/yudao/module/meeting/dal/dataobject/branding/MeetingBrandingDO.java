package cn.iocoder.yudao.module.meeting.dal.dataobject.branding;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@TableName("meeting_branding")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingBrandingDO extends TenantBaseDO {

    @TableId
    private Long id;

    private String siteName;

    private String siteLogoUrl;

    private String sidebarTitle;

    private String sidebarSubtitle;

    private Boolean active;

    private String remark;
}

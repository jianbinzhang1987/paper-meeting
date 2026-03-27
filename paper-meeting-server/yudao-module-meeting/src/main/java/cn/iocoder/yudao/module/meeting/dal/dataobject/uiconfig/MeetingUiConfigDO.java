package cn.iocoder.yudao.module.meeting.dal.dataobject.uiconfig;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@TableName("meeting_ui_config")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingUiConfigDO extends TenantBaseDO {

    @TableId
    private Long id;

    private String name;

    private Integer fontSize;

    private String primaryColor;

    private String accentColor;

    private String backgroundImageUrl;

    private String logoUrl;

    private String extraCss;

    private Boolean active;

    private String remark;
}

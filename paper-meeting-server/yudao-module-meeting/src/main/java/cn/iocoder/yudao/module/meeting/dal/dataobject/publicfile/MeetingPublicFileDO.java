package cn.iocoder.yudao.module.meeting.dal.dataobject.publicfile;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@TableName("meeting_public_file")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingPublicFileDO extends TenantBaseDO {

    @TableId
    private Long id;

    private String category;

    private String name;

    private String url;

    private String fileType;

    private Integer sort;

    private Boolean enabled;

    private String remark;
}

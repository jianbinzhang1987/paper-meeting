package cn.iocoder.yudao.module.meeting.controller.admin.branding.vo;

import cn.iocoder.yudao.framework.common.pojo.PageParam;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingBrandingPageReqVO extends PageParam {

    private String siteName;

    private Boolean active;
}

package cn.iocoder.yudao.module.meeting.controller.admin.appversion.vo;

import cn.iocoder.yudao.framework.common.pojo.PageParam;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingAppVersionPageReqVO extends PageParam {

    private Integer clientType;

    private Boolean active;

    private String name;
}

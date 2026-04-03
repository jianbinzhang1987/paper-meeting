package cn.iocoder.yudao.module.meeting.controller.admin.usergroup.vo;

import cn.iocoder.yudao.framework.common.pojo.PageParam;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingUserGroupPageReqVO extends PageParam {

    private String name;

    private Boolean active;
}

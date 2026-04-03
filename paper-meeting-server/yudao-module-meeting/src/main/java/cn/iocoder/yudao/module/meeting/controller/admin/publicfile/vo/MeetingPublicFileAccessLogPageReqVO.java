package cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo;

import cn.iocoder.yudao.framework.common.pojo.PageParam;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingPublicFileAccessLogPageReqVO extends PageParam {

    private Long fileId;
}

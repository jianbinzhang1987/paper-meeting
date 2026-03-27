package cn.iocoder.yudao.module.meeting.controller.admin.appversion.vo;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingAppVersionRespVO extends MeetingAppVersionBaseVO {

    private Long id;

    private LocalDateTime createTime;
}

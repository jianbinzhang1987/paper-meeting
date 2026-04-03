package cn.iocoder.yudao.module.meeting.controller.admin.usergroup.vo;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingUserGroupRespVO extends MeetingUserGroupBaseVO {

    private Long id;

    private LocalDateTime createTime;
}

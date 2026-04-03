package cn.iocoder.yudao.module.meeting.controller.admin.usergroup.vo;

import lombok.Data;

import java.util.List;

@Data
public class MeetingUserGroupSimpleRespVO {

    private Long id;

    private String name;

    private List<Long> userIds;
}

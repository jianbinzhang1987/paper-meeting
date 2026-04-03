package cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class MeetingAttendeeImportGroupReqVO {

    @NotNull(message = "会议编号不能为空")
    private Long meetingId;

    @NotEmpty(message = "用户组不能为空")
    private List<Long> groupIds;

    @NotNull(message = "角色不能为空")
    private Integer role;
}

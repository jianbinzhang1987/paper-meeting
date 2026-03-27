package cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingPublicFileRespVO extends MeetingPublicFileBaseVO {

    private Long id;

    private LocalDateTime createTime;
}

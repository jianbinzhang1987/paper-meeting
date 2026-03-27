package cn.iocoder.yudao.module.meeting.controller.admin.uiconfig.vo;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingUiConfigRespVO extends MeetingUiConfigBaseVO {

    private Long id;

    private LocalDateTime createTime;
}

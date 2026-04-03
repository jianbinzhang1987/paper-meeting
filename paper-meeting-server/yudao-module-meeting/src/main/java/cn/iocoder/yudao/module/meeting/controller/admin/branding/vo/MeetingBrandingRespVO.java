package cn.iocoder.yudao.module.meeting.controller.admin.branding.vo;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingBrandingRespVO extends MeetingBrandingBaseVO {

    private Long id;

    private LocalDateTime createTime;
}

package cn.iocoder.yudao.module.meeting.controller.admin.branding.vo;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingBrandingUpdateReqVO extends MeetingBrandingBaseVO {

    @NotNull(message = "编号不能为空")
    private Long id;
}

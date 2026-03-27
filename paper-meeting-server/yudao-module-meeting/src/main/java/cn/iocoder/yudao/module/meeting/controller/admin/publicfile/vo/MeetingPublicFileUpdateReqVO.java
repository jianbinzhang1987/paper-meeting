package cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingPublicFileUpdateReqVO extends MeetingPublicFileBaseVO {

    @NotNull(message = "编号不能为空")
    private Long id;
}

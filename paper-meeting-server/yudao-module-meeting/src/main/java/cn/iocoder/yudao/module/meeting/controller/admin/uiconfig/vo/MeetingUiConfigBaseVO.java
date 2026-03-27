package cn.iocoder.yudao.module.meeting.controller.admin.uiconfig.vo;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class MeetingUiConfigBaseVO {

    @NotNull(message = "样式名称不能为空")
    private String name;

    private Integer fontSize;

    @NotNull(message = "主色不能为空")
    private String primaryColor;

    private String accentColor;

    private String backgroundImageUrl;

    private String logoUrl;

    private String extraCss;

    private Boolean active;

    private String remark;
}

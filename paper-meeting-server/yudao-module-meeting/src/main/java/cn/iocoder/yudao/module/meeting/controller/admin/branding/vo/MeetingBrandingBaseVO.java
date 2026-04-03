package cn.iocoder.yudao.module.meeting.controller.admin.branding.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class MeetingBrandingBaseVO {

    @Schema(description = "网站名称", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank(message = "网站名称不能为空")
    private String siteName;

    @Schema(description = "站点 Logo")
    private String siteLogoUrl;

    @Schema(description = "侧边栏标题")
    private String sidebarTitle;

    @Schema(description = "侧边栏副标题")
    private String sidebarSubtitle;

    @Schema(description = "是否启用")
    private Boolean active;

    @Schema(description = "备注")
    private String remark;
}

package cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class MeetingPublicFileBaseVO {

    @Schema(description = "资料分类", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull(message = "资料分类不能为空")
    private String category;

    @Schema(description = "资料名称", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull(message = "资料名称不能为空")
    private String name;

    @Schema(description = "资料地址", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull(message = "资料地址不能为空")
    private String url;

    private String fileType;

    private Integer sort;

    private Boolean enabled;

    private String remark;
}

package cn.iocoder.yudao.module.meeting.controller.admin.usergroup.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

import java.util.List;

@Data
public class MeetingUserGroupBaseVO {

    @Schema(description = "组名", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank(message = "组名不能为空")
    private String name;

    @Schema(description = "描述")
    private String description;

    @Schema(description = "用户编号列表", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotEmpty(message = "用户不能为空")
    private List<Long> userIds;

    @Schema(description = "是否启用")
    private Boolean active;

    @Schema(description = "备注")
    private String remark;
}

package cn.iocoder.yudao.module.meeting.controller.admin.room.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import jakarta.validation.constraints.NotNull;

/**
 * 会议室 Base VO
 */
@Data
public class MeetingRoomBaseVO {

    @Schema(description = "房间名称", requiredMode = Schema.RequiredMode.REQUIRED, example = "第一会议室")
    @NotNull(message = "房间名称不能为空")
    private String name;

    @Schema(description = "所在位置", example = "办公楼 3 楼")
    private String location;

    @Schema(description = "容纳人数", example = "10")
    private Integer capacity;

    @Schema(description = "状态", requiredMode = Schema.RequiredMode.REQUIRED, example = "0")
    @NotNull(message = "状态不能为空")
    private Integer status;

    @Schema(description = "座位配置(JSON)")
    private String config;

}

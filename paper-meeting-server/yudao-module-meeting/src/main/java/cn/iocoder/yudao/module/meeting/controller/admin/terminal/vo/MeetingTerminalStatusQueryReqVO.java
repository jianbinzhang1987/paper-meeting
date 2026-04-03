package cn.iocoder.yudao.module.meeting.controller.admin.terminal.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Schema(description = "管理后台 - 终端状态查询 Request VO")
@Data
public class MeetingTerminalStatusQueryReqVO {

    @Schema(description = "客户端类型", example = "1")
    private Integer clientType;

    @Schema(description = "安装包记录编号", example = "10")
    private Long appVersionId;

    @Schema(description = "样式记录编号", example = "3")
    private Long uiConfigId;
}

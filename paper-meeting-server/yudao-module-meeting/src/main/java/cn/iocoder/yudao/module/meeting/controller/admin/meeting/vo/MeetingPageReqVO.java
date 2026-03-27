package cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo;

import cn.iocoder.yudao.framework.common.pojo.PageParam;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import java.time.LocalDateTime;

@Schema(description = "管理后台 - 会议分页 Request VO")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingPageReqVO extends PageParam {

    @Schema(description = "会议名称", example = "周例会")
    private String name;

    @Schema(description = "状态", example = "0")
    private Integer status;

    @Schema(description = "类型", example = "2")
    private Integer type;

    @Schema(description = "开始时间")
    private LocalDateTime[] startTime;

}

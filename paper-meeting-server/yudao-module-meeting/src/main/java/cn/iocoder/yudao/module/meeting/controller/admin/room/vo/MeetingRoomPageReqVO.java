package cn.iocoder.yudao.module.meeting.controller.admin.room.vo;

import cn.iocoder.yudao.framework.common.pojo.PageParam;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Schema(description = "管理后台 - 会议室分页 Request VO")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingRoomPageReqVO extends PageParam {

    @Schema(description = "房间名称", example = "第一会议室")
    private String name;

    @Schema(description = "状态", example = "0")
    private Integer status;

}

package cn.iocoder.yudao.module.meeting.controller.admin.room.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Schema(description = "管理后台 - 今日会议 Response VO")
@Data
public class MeetingRoomTodayMeetingRespVO {

    @Schema(description = "会议编号", example = "100")
    private Long meetingId;

    @Schema(description = "会议名称", example = "管理例会")
    private String meetingName;

    @Schema(description = "会议室编号", example = "1")
    private Long roomId;

    @Schema(description = "会议室名称", example = "第一会议室")
    private String roomName;

    @Schema(description = "会议状态", example = "2")
    private Integer status;

    @Schema(description = "保密级别", example = "0")
    private Integer level;

    @Schema(description = "开始时间")
    private LocalDateTime startTime;

    @Schema(description = "结束时间")
    private LocalDateTime endTime;
}

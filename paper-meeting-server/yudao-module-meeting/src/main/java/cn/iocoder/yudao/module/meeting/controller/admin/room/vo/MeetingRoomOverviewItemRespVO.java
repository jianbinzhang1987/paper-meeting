package cn.iocoder.yudao.module.meeting.controller.admin.room.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Schema(description = "管理后台 - 会议室概览条目 Response VO")
@Data
public class MeetingRoomOverviewItemRespVO {

    @Schema(description = "会议室编号", example = "1")
    private Long roomId;

    @Schema(description = "会议室名称", example = "第一会议室")
    private String roomName;

    @Schema(description = "所在位置", example = "3F A301")
    private String location;

    @Schema(description = "容纳人数", example = "24")
    private Integer capacity;

    @Schema(description = "会议室状态", example = "0")
    private Integer roomStatus;

    @Schema(description = "当前是否占用", example = "true")
    private Boolean busyNow;

    @Schema(description = "今日会议数量", example = "3")
    private Integer todayMeetingCount;

    @Schema(description = "当前会议编号", example = "100")
    private Long currentMeetingId;

    @Schema(description = "当前会议名称", example = "季度经营分析会")
    private String currentMeetingName;

    @Schema(description = "当前会议开始时间")
    private LocalDateTime currentMeetingStartTime;

    @Schema(description = "当前会议结束时间")
    private LocalDateTime currentMeetingEndTime;

    @Schema(description = "下一场会议编号", example = "101")
    private Long nextMeetingId;

    @Schema(description = "下一场会议名称", example = "管理例会")
    private String nextMeetingName;

    @Schema(description = "下一场会议开始时间")
    private LocalDateTime nextMeetingStartTime;

    @Schema(description = "下一场会议结束时间")
    private LocalDateTime nextMeetingEndTime;
}

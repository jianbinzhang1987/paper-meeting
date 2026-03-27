package cn.iocoder.yudao.module.meeting.controller.admin.room.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Schema(description = "管理后台 - 会议室概览 Response VO")
@Data
public class MeetingRoomOverviewRespVO {

    @Schema(description = "统计时间")
    private LocalDateTime now;

    @Schema(description = "会议室总数", example = "8")
    private Integer roomTotal;

    @Schema(description = "当前空闲数", example = "5")
    private Integer availableRoomCount;

    @Schema(description = "当前占用数", example = "3")
    private Integer busyRoomCount;

    @Schema(description = "今日会议数", example = "12")
    private Integer todayMeetingCount;

    @Schema(description = "今日待开始会议数", example = "4")
    private Integer upcomingMeetingCount;

    @Schema(description = "会议室概览列表")
    private List<MeetingRoomOverviewItemRespVO> rooms;

    @Schema(description = "今日会议列表")
    private List<MeetingRoomTodayMeetingRespVO> todayMeetings;
}

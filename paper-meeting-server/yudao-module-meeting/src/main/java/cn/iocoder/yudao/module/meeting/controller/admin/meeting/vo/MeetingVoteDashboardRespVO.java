package cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Schema(description = "管理后台 - 表决控制中心 Response VO")
@Data
public class MeetingVoteDashboardRespVO {

    @Schema(description = "会议编号")
    private Long meetingId;

    @Schema(description = "参会总人数")
    private Integer attendeeCount;

    @Schema(description = "表决列表")
    private List<VoteItem> votes;

    @Data
    public static class VoteItem {
        private Long id;
        private Long agendaId;
        private String agendaTitle;
        private String title;
        private Integer type;
        private Boolean secret;
        private Integer status;
        private Integer attendeeCount;
        private Integer votedCount;
        private Integer pendingCount;
        private BigDecimal turnoutRate;
        private LocalDateTime createTime;
        private List<OptionItem> options;
    }

    @Data
    public static class OptionItem {
        private Long id;
        private String content;
        private Integer sort;
        private Integer voteCount;
        private BigDecimal voteRate;
    }
}

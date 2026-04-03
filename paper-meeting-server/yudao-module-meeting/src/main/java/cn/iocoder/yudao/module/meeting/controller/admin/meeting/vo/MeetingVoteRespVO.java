package cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Schema(description = "管理后台 - 会议表决 Response VO")
@Data
public class MeetingVoteRespVO {

    @Schema(description = "表决编号", requiredMode = Schema.RequiredMode.REQUIRED, example = "1")
    private Long id;

    @Schema(description = "会议编号", requiredMode = Schema.RequiredMode.REQUIRED, example = "1024")
    private Long meetingId;

    @Schema(description = "关联议题编号", example = "2048")
    private Long agendaId;

    @Schema(description = "表决标题", requiredMode = Schema.RequiredMode.REQUIRED, example = "关于预算方案的表决")
    private String title;

    @Schema(description = "类型", example = "0")
    private Integer type;

    @Schema(description = "是否匿名", example = "true")
    private Boolean isSecret;

    @Schema(description = "状态", example = "0")
    private Integer status;

    @Schema(description = "结果发布时间")
    private LocalDateTime publishedTime;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @Schema(description = "选项列表")
    private List<Option> options;

    @Schema(description = "管理后台 - 会议表决选项 Response VO")
    @Data
    public static class Option {
        @Schema(description = "选项编号", example = "1")
        private Long id;

        @Schema(description = "表决编号", example = "1")
        private Long voteId;

        @Schema(description = "选项内容", example = "同意")
        private String content;

        @Schema(description = "排序", example = "1")
        private Integer sort;
    }
}

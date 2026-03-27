package cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Schema(description = "管理后台 - 会议资料新增 Request VO")
@Data
public class MeetingFileCreateReqVO {

    @Schema(description = "会议编号", requiredMode = Schema.RequiredMode.REQUIRED, example = "1024")
    @NotNull(message = "会议编号不能为空")
    private Long meetingId;

    @Schema(description = "关联议题编号", example = "2048")
    private Long agendaId;

    @Schema(description = "文件名称", requiredMode = Schema.RequiredMode.REQUIRED, example = "会议议程.pdf")
    @NotBlank(message = "文件名称不能为空")
    private String name;

    @Schema(description = "文件访问地址", requiredMode = Schema.RequiredMode.REQUIRED, example = "/infra/file/xxx.pdf")
    @NotBlank(message = "文件地址不能为空")
    private String url;

    @Schema(description = "文件类型", example = "application/pdf")
    private String type;

    @Schema(description = "文件摘要", example = "经营分析报告")
    private String summary;

    @Schema(description = "页数", example = "18")
    private Integer pageCount;

    @Schema(description = "缩略图地址", example = "/infra/file/thumb.png")
    private String thumbnailUrl;

    @Schema(description = "文件大小", example = "102400")
    private Long size;
}

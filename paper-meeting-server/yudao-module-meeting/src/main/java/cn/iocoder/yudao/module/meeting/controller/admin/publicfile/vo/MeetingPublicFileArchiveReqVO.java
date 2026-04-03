package cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.util.List;

@Schema(description = "管理后台 - 公共资料归档 Request VO")
@Data
public class MeetingPublicFileArchiveReqVO {

    @Schema(description = "指定归档资料编号列表（传值时优先生效）")
    private List<Long> fileIds;

    @Schema(description = "归档规则：创建时间早于 N 天", example = "180")
    private Integer beforeDays;

    @Schema(description = "筛选分类前缀", example = "会议资料/历史")
    private String sourceCategoryPrefix;

    @Schema(description = "归档分类根目录", example = "归档资料")
    private String targetCategoryPrefix;

    @Schema(description = "归档后是否停用", example = "true")
    private Boolean disableAfterArchive;
}

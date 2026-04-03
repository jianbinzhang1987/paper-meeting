package cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.util.List;

@Schema(description = "管理后台 - 公共资料分类树 Response VO")
@Data
public class MeetingPublicFileCategoryTreeRespVO {

    @Schema(description = "节点名称")
    private String label;

    @Schema(description = "路径")
    private String path;

    @Schema(description = "资料数量")
    private Integer count;

    @Schema(description = "子节点")
    private List<MeetingPublicFileCategoryTreeRespVO> children;
}

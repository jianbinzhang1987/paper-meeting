package cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo;

import cn.idev.excel.annotation.ExcelIgnoreUnannotated;
import cn.idev.excel.annotation.ExcelProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Schema(description = "管理后台 - 会议表决结果导出 Response VO")
@Data
@ExcelIgnoreUnannotated
public class MeetingVoteResultExportVO {

    @ExcelProperty("表决标题")
    private String voteTitle;

    @ExcelProperty("表决类型")
    private String voteType;

    @ExcelProperty("匿名方式")
    private String secretType;

    @ExcelProperty("表决状态")
    private String voteStatus;

    @ExcelProperty("选项")
    private String optionContent;

    @ExcelProperty("得票数")
    private Long voteCount;

    @ExcelProperty("创建时间")
    private LocalDateTime createTime;
}

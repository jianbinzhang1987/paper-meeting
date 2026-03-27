package cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo;

import cn.idev.excel.annotation.ExcelIgnoreUnannotated;
import cn.idev.excel.annotation.ExcelProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Schema(description = "管理后台 - 会议资料导出 Response VO")
@Data
@ExcelIgnoreUnannotated
public class MeetingFileExportVO {

    @ExcelProperty("文件名称")
    private String name;

    @ExcelProperty("关联议题ID")
    private Long agendaId;

    @ExcelProperty("文件类型")
    private String type;

    @ExcelProperty("文件摘要")
    private String summary;

    @ExcelProperty("页数")
    private Integer pageCount;

    @ExcelProperty("缩略图地址")
    private String thumbnailUrl;

    @ExcelProperty("文件大小(B)")
    private Long size;

    @ExcelProperty("文件地址")
    private String url;

    @ExcelProperty("上传时间")
    private LocalDateTime createTime;
}

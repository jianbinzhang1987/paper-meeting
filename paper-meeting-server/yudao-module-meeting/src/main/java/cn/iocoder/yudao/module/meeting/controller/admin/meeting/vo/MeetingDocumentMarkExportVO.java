package cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo;

import cn.idev.excel.annotation.ExcelIgnoreUnannotated;
import cn.idev.excel.annotation.ExcelProperty;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@ExcelIgnoreUnannotated
public class MeetingDocumentMarkExportVO {

    @ExcelProperty("资料名称")
    private String documentName;

    @ExcelProperty("资料类型")
    private String documentType;

    @ExcelProperty("标记类型")
    private String markType;

    @ExcelProperty("页码")
    private Integer page;

    @ExcelProperty("内容")
    private String content;

    @ExcelProperty("提交人")
    private String userName;

    @ExcelProperty("更新时间")
    private LocalDateTime updatedAt;
}

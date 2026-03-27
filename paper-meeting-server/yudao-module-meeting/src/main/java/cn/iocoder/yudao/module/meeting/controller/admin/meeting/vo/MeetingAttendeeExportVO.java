package cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo;

import cn.idev.excel.annotation.ExcelIgnoreUnannotated;
import cn.idev.excel.annotation.ExcelProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Schema(description = "管理后台 - 参会人员签到导出 Response VO")
@Data
@ExcelIgnoreUnannotated
public class MeetingAttendeeExportVO {

    @ExcelProperty("姓名")
    private String nickname;

    @ExcelProperty("角色")
    private String roleName;

    @ExcelProperty("签到状态")
    private String signStatus;

    @ExcelProperty("签到时间")
    private LocalDateTime signInTime;

    @ExcelProperty("座位号")
    private String seatId;
}

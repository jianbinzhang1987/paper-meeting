package cn.iocoder.yudao.module.meeting.controller.admin.meeting;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.framework.excel.core.util.ExcelUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingFileCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingFileExportVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingFileDO;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingFileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

@Tag(name = "管理后台 - 会议资料")
@RestController
@RequestMapping("/meeting/file")
@Validated
public class MeetingFileController {

    @Resource
    private MeetingFileService meetingFileService;

    @PostMapping("/create")
    @Operation(summary = "创建文件记录")
    @PreAuthorize("@ss.hasPermission('meeting:file:create')")
    public CommonResult<Long> createFile(@Valid @RequestBody MeetingFileCreateReqVO createReqVO) {
        return success(meetingFileService.createFile(createReqVO));
    }

    @DeleteMapping("/delete")
    @Operation(summary = "删除文件记录")
    @Parameter(name = "id", description = "编号", required = true)
    @PreAuthorize("@ss.hasPermission('meeting:file:delete')")
    public CommonResult<Boolean> deleteFile(@RequestParam("id") Long id) {
        meetingFileService.deleteFile(id);
        return success(true);
    }

    @GetMapping("/list")
    @Operation(summary = "获得文件列表")
    @Parameter(name = "meetingId", description = "会议编号", required = true)
    @PreAuthorize("@ss.hasPermission('meeting:file:query')")
    public CommonResult<List<MeetingFileDO>> getFileList(@RequestParam("meetingId") Long meetingId) {
        return success(meetingFileService.getFileListByMeetingId(meetingId));
    }

    @GetMapping("/export-excel")
    @Operation(summary = "导出会议资料清单")
    @Parameter(name = "meetingId", description = "会议编号", required = true)
    @PreAuthorize("@ss.hasPermission('meeting:file:query')")
    public void exportFileExcel(@RequestParam("meetingId") Long meetingId,
                                HttpServletResponse response) throws IOException {
        List<MeetingFileExportVO> data = meetingFileService.getFileExportList(meetingId);
        ExcelUtils.write(response, "会议资料清单.xls", "资料清单", MeetingFileExportVO.class, data);
    }

}

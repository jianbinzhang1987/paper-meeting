package cn.iocoder.yudao.module.meeting.controller.admin.publicfile;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileAccessLogPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileAccessLogReportReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileAccessLogRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileAccessSummaryRespVO;
import cn.iocoder.yudao.module.meeting.service.publicfile.MeetingPublicFileAccessLogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.Arrays;
import java.util.List;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

@Tag(name = "管理后台 - 公共资料访问日志")
@RestController
@RequestMapping("/meeting/public-file/access-log")
@Validated
public class MeetingPublicFileAccessLogController {

    @Resource
    private MeetingPublicFileAccessLogService accessLogService;

    @PostMapping("/report")
    @Operation(summary = "上报资料访问日志")
    @PreAuthorize("@ss.hasPermission('meeting:public-file:query')")
    public CommonResult<Boolean> report(@Valid @RequestBody MeetingPublicFileAccessLogReportReqVO reqVO) {
        accessLogService.reportAccess(reqVO);
        return success(true);
    }

    @GetMapping("/page")
    @Operation(summary = "获得资料访问日志分页")
    @PreAuthorize("@ss.hasPermission('meeting:public-file:query')")
    public CommonResult<PageResult<MeetingPublicFileAccessLogRespVO>> getPage(@Valid MeetingPublicFileAccessLogPageReqVO reqVO) {
        return success(accessLogService.getPage(reqVO));
    }

    @GetMapping("/summary")
    @Operation(summary = "获得资料访问汇总")
    @PreAuthorize("@ss.hasPermission('meeting:public-file:query')")
    public CommonResult<List<MeetingPublicFileAccessSummaryRespVO>> getSummary(@RequestParam("fileIds") String fileIds) {
        List<Long> ids = Arrays.stream(fileIds.split(",")).filter(item -> !item.isBlank()).map(Long::valueOf).toList();
        return success(accessLogService.getSummaryList(ids));
    }
}

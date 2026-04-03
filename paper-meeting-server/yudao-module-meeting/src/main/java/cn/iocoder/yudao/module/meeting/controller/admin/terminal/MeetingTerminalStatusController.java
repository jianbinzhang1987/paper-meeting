package cn.iocoder.yudao.module.meeting.controller.admin.terminal;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.module.meeting.controller.admin.terminal.vo.MeetingTerminalDispatchRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.terminal.vo.MeetingTerminalStatusQueryReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.terminal.vo.MeetingTerminalStatusRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.terminal.vo.MeetingTerminalStatusSummaryRespVO;
import cn.iocoder.yudao.module.meeting.service.terminal.MeetingTerminalStatusService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

@Tag(name = "管理后台 - 终端状态")
@RestController
@RequestMapping("/meeting/terminal-status")
@Validated
public class MeetingTerminalStatusController {

    @Resource
    private MeetingTerminalStatusService meetingTerminalStatusService;

    @GetMapping("/list")
    @Operation(summary = "获得终端状态列表")
    @PreAuthorize("@ss.hasPermission('meeting:terminal-status:query')")
    public CommonResult<List<MeetingTerminalStatusRespVO>> getList(MeetingTerminalStatusQueryReqVO reqVO) {
        return success(meetingTerminalStatusService.getTerminalStatusList(reqVO));
    }

    @GetMapping("/summary")
    @Operation(summary = "获得终端状态汇总")
    @PreAuthorize("@ss.hasPermission('meeting:terminal-status:query')")
    public CommonResult<MeetingTerminalStatusSummaryRespVO> getSummary(MeetingTerminalStatusQueryReqVO reqVO) {
        return success(meetingTerminalStatusService.getTerminalStatusSummary(reqVO));
    }

    @PostMapping("/dispatch-app-version")
    @Operation(summary = "下发安装包检查更新指令")
    @PreAuthorize("@ss.hasPermission('meeting:app-version:update')")
    public CommonResult<MeetingTerminalDispatchRespVO> dispatchAppVersion(@RequestParam("appVersionId") Long appVersionId,
                                                                          @RequestParam(value = "clientType", required = false) Integer clientType,
                                                                          @RequestParam(value = "onlyPending", defaultValue = "false") boolean onlyPending) {
        return success(meetingTerminalStatusService.dispatchAppVersion(appVersionId, clientType, onlyPending));
    }

    @PostMapping("/dispatch-ui-config")
    @Operation(summary = "下发客户端样式更新指令")
    @PreAuthorize("@ss.hasPermission('meeting:ui-config:update')")
    public CommonResult<MeetingTerminalDispatchRespVO> dispatchUiConfig(@RequestParam("uiConfigId") Long uiConfigId,
                                                                        @RequestParam(value = "clientType", required = false) Integer clientType,
                                                                        @RequestParam(value = "onlyPending", defaultValue = "false") boolean onlyPending) {
        return success(meetingTerminalStatusService.dispatchUiConfig(uiConfigId, clientType, onlyPending));
    }
}

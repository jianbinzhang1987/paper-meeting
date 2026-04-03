package cn.iocoder.yudao.module.meeting.controller.admin.meeting;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.framework.excel.core.util.ExcelUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteDashboardRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteResultExportVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteRecordDO;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingVoteService;
import cn.iocoder.yudao.module.meeting.websocket.MeetingWebSocketMessageType;
import cn.iocoder.yudao.module.meeting.websocket.MeetingWebSocketSender;
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
import java.time.LocalDateTime;
import java.util.List;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

@Tag(name = "管理后台 - 会议表决")
@RestController
@RequestMapping("/meeting/vote")
@Validated
public class MeetingVoteController {

    @Resource
    private MeetingVoteService meetingVoteService;
    @Resource
    private MeetingWebSocketSender meetingWebSocketSender;

    @PostMapping("/create")
    @Operation(summary = "创建表决")
    @PreAuthorize("@ss.hasPermission('meeting:vote:create')")
    public CommonResult<Long> createVote(@Valid @RequestBody MeetingVoteCreateReqVO createReqVO) {
        return success(meetingVoteService.createVote(createReqVO));
    }

    @DeleteMapping("/delete")
    @Operation(summary = "删除表决")
    @Parameter(name = "id", description = "编号", required = true)
    @PreAuthorize("@ss.hasPermission('meeting:vote:delete')")
    public CommonResult<Boolean> deleteVote(@RequestParam("id") Long id) {
        meetingVoteService.deleteVote(id);
        return success(true);
    }

    @GetMapping("/list")
    @Operation(summary = "获得表决列表")
    @Parameter(name = "meetingId", description = "会议编号", required = true)
    @PreAuthorize("@ss.hasPermission('meeting:vote:query')")
    public CommonResult<List<MeetingVoteRespVO>> getVoteList(@RequestParam("meetingId") Long meetingId) {
        return success(meetingVoteService.getVoteListByMeetingId(meetingId));
    }

    @GetMapping("/dashboard")
    @Operation(summary = "获得表决控制中心数据")
    @Parameter(name = "meetingId", description = "会议编号", required = true)
    @PreAuthorize("@ss.hasPermission('meeting:vote:query')")
    public CommonResult<MeetingVoteDashboardRespVO> getVoteDashboard(@RequestParam("meetingId") Long meetingId) {
        return success(meetingVoteService.getVoteDashboardByMeetingId(meetingId));
    }

    @GetMapping("/export-excel")
    @Operation(summary = "导出表决结果")
    @Parameter(name = "meetingId", description = "会议编号", required = true)
    @PreAuthorize("@ss.hasPermission('meeting:vote:export')")
    public void exportVoteExcel(@RequestParam("meetingId") Long meetingId,
                                HttpServletResponse response) throws IOException {
        List<MeetingVoteResultExportVO> data = meetingVoteService.getVoteResultExportList(meetingId);
        ExcelUtils.write(response, "会议表决结果.xls", "表决结果", MeetingVoteResultExportVO.class, data);
    }

    @PostMapping("/submit")
    @Operation(summary = "提交表决")
    public CommonResult<Boolean> submitVote(@Valid @RequestBody MeetingVoteRecordDO recordDO) {
        meetingVoteService.submitVote(recordDO);
        return success(true);
    }

    @PostMapping("/start")
    @Operation(summary = "开始表决")
    @PreAuthorize("@ss.hasPermission('meeting:vote:update')")
    public CommonResult<Boolean> startVote(@RequestParam("id") Long id) {
        return updateVoteStatus(id, 1, MeetingWebSocketMessageType.VOTE_STARTED);
    }

    @PostMapping("/finish")
    @Operation(summary = "结束表决")
    @PreAuthorize("@ss.hasPermission('meeting:vote:update')")
    public CommonResult<Boolean> finishVote(@RequestParam("id") Long id) {
        return updateVoteStatus(id, 2, MeetingWebSocketMessageType.VOTE_FINISHED);
    }

    @PostMapping("/publish")
    @Operation(summary = "发布表决结果")
    @PreAuthorize("@ss.hasPermission('meeting:vote:publish')")
    public CommonResult<Boolean> publishVote(@RequestParam("id") Long id) {
        meetingVoteService.markVotePublished(id, LocalDateTime.now());
        MeetingVoteDO vote = meetingVoteService.getVote(id);
        if (vote != null) {
            meetingWebSocketSender.sendVoteStatus(vote, MeetingWebSocketMessageType.VOTE_PUBLISHED);
        }
        return success(true);
    }

    @PostMapping("/force-return")
    @Operation(summary = "强制返回同屏")
    @PreAuthorize("@ss.hasPermission('meeting:vote:force-return')")
    public CommonResult<Boolean> forceReturn(@RequestParam("meetingId") Long meetingId) {
        meetingWebSocketSender.sendForceReturn(meetingId);
        return success(true);
    }

    private CommonResult<Boolean> updateVoteStatus(Long id, Integer status, String messageType) {
        meetingVoteService.updateVoteStatus(id, status);
        MeetingVoteDO vote = meetingVoteService.getVote(id);
        if (vote != null) {
            meetingWebSocketSender.sendVoteStatus(vote, messageType);
        }
        return success(true);
    }

}

package cn.iocoder.yudao.module.meeting.controller.admin.meeting;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.*;
import cn.iocoder.yudao.module.meeting.convert.meeting.MeetingConvert;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingDO;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingService;
import cn.iocoder.yudao.module.meeting.service.realtime.MeetingRealtimeStateService;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

@Tag(name = "管理后台 - 会议")
@RestController
@RequestMapping("/meeting/info")
@Validated
public class MeetingController {

    @Resource
    private MeetingService meetingService;
    @Resource
    private MeetingRealtimeStateService meetingRealtimeStateService;

    @PostMapping("/create")
    @Operation(summary = "创建会议")
    @PreAuthorize("@ss.hasPermission('meeting:info:create')")
    public CommonResult<Long> createMeeting(@Valid @RequestBody MeetingCreateReqVO createReqVO) {
        return success(meetingService.createMeeting(createReqVO));
    }

    @PutMapping("/update")
    @Operation(summary = "更新会议")
    @PreAuthorize("@ss.hasPermission('meeting:info:update')")
    public CommonResult<Boolean> updateMeeting(@Valid @RequestBody MeetingUpdateReqVO updateReqVO) {
        meetingService.updateMeeting(updateReqVO);
        return success(true);
    }

    @DeleteMapping("/delete")
    @Operation(summary = "删除会议")
    @Parameter(name = "id", description = "编号", required = true)
    @PreAuthorize("@ss.hasPermission('meeting:info:delete')")
    public CommonResult<Boolean> deleteMeeting(@RequestParam("id") Long id) {
        meetingService.deleteMeeting(id);
        return success(true);
    }

    @GetMapping("/get")
    @Operation(summary = "获得会议")
    @Parameter(name = "id", description = "编号", required = true, example = "1024")
    @PreAuthorize("@ss.hasPermission('meeting:info:query')")
    public CommonResult<MeetingRespVO> getMeeting(@RequestParam("id") Long id) {
        MeetingDO meeting = meetingService.getMeeting(id);
        return success(fillMeetingOperator(MeetingConvert.INSTANCE.convert(meeting)));
    }

    @GetMapping("/page")
    @Operation(summary = "获得会议分页")
    @PreAuthorize("@ss.hasPermission('meeting:info:query')")
    public CommonResult<PageResult<MeetingRespVO>> getMeetingPage(@Valid MeetingPageReqVO pageVO) {
        PageResult<MeetingDO> pageResult = meetingService.getMeetingPage(pageVO);
        PageResult<MeetingRespVO> respPage = MeetingConvert.INSTANCE.convertPage(pageResult);
        respPage.getList().forEach(this::fillMeetingOperator);
        return success(respPage);
    }

    @PostMapping("/submit-booking")
    @Operation(summary = "提交预约")
    public CommonResult<Boolean> submitBooking(@RequestParam("id") Long id) {
        meetingService.submitBooking(id);
        return success(true);
    }

    @PostMapping("/approve-booking")
    @Operation(summary = "审批预约")
    @PreAuthorize("@ss.hasPermission('meeting:info:approve')")
    public CommonResult<Boolean> approveBooking(@Valid @RequestBody MeetingApproveReqVO reqVO) {
        meetingService.approveBooking(reqVO);
        return success(true);
    }

    @PostMapping("/cancel-approval")
    @Operation(summary = "撤销审核")
    @PreAuthorize("@ss.hasPermission('meeting:info:update')")
    public CommonResult<Boolean> cancelApproval(@Valid @RequestBody MeetingApprovalCancelReqVO reqVO) {
        meetingService.cancelApproval(reqVO);
        return success(true);
    }

    @GetMapping("/approval-log")
    @Operation(summary = "获得审批历史")
    @Parameter(name = "meetingId", description = "会议编号", required = true)
    @PreAuthorize("@ss.hasPermission('meeting:info:query')")
    public CommonResult<java.util.List<MeetingApprovalLogRespVO>> getApprovalLogList(@RequestParam("meetingId") Long meetingId) {
        return success(meetingService.getApprovalLogList(meetingId));
    }

    @GetMapping("/realtime-state")
    @Operation(summary = "获得会议实时调度状态")
    @Parameter(name = "meetingId", description = "会议编号", required = true)
    @PreAuthorize("@ss.hasPermission('meeting:info:query')")
    public CommonResult<MeetingRealtimeStateRespVO> getRealtimeState(@RequestParam("meetingId") Long meetingId) {
        MeetingRealtimeStateRespVO respVO = new MeetingRealtimeStateRespVO();
        respVO.setSyncRequests(meetingRealtimeStateService.getSyncRequests(meetingId).stream()
                .map(item -> BeanUtils.toBean(item, MeetingRealtimeStateRespVO.SyncRequest.class))
                .toList());
        respVO.setServiceRequests(meetingRealtimeStateService.getServiceRequests(meetingId).stream()
                .map(item -> BeanUtils.toBean(item, MeetingRealtimeStateRespVO.ServiceRequest.class))
                .toList());
        return success(respVO);
    }

    @PostMapping("/start")
    @Operation(summary = "开始会议")
    @PreAuthorize("@ss.hasPermission('meeting:info:update')")
    public CommonResult<Boolean> startMeeting(@RequestParam("id") Long id) {
        meetingService.startMeeting(id);
        return success(true);
    }

    @PostMapping("/stop")
    @Operation(summary = "结束会议")
    @PreAuthorize("@ss.hasPermission('meeting:info:update')")
    public CommonResult<Boolean> stopMeeting(@RequestParam("id") Long id) {
        meetingService.stopMeeting(id);
        return success(true);
    }

    @PostMapping("/archive")
    @Operation(summary = "归档会议")
    @PreAuthorize("@ss.hasPermission('meeting:info:archive')")
    public CommonResult<Boolean> archiveMeeting(@RequestParam("id") Long id) {
        meetingService.archiveMeeting(id);
        return success(true);
    }

    @PostMapping("/rollback-archive")
    @Operation(summary = "撤回归档")
    @PreAuthorize("@ss.hasPermission('meeting:info:archive')")
    public CommonResult<Boolean> rollbackArchive(@RequestParam("id") Long id) {
        meetingService.rollbackArchive(id);
        return success(true);
    }

    @PostMapping("/copy")
    @Operation(summary = "复制会议")
    @PreAuthorize("@ss.hasPermission('meeting:info:create')")
    public CommonResult<Long> copyMeeting(@RequestParam("id") Long id) {
        return success(meetingService.copyMeeting(id));
    }

    @PostMapping("/save-template")
    @Operation(summary = "保存为模板")
    @PreAuthorize("@ss.hasPermission('meeting:info:create')")
    public CommonResult<Long> saveAsTemplate(@RequestParam("id") Long id) {
        return success(meetingService.saveAsTemplate(id));
    }

    private MeetingRespVO fillMeetingOperator(MeetingRespVO meeting) {
        if (meeting == null) {
            return null;
        }
        meeting.setCreatorName(meeting.getCreator());
        return meeting;
    }

}

package cn.iocoder.yudao.module.meeting.controller.admin.meeting;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.framework.excel.core.util.ExcelUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingAttendeeExportVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingAttendeeBaseVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingSeatAssignReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAttendeeDO;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingAttendeeService;
import cn.iocoder.yudao.module.system.api.user.AdminUserApi;
import cn.iocoder.yudao.module.system.api.user.dto.AdminUserRespDTO;
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
import java.util.Map;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;
import static cn.iocoder.yudao.framework.common.util.collection.CollectionUtils.convertList;

@Tag(name = "管理后台 - 参会人员")
@RestController
@RequestMapping("/meeting/attendee")
@Validated
public class MeetingAttendeeController {

    @Resource
    private MeetingAttendeeService meetingAttendeeService;
    @Resource
    private AdminUserApi adminUserApi;

    @PostMapping("/create")
    @Operation(summary = "添加参会人")
    @PreAuthorize("@ss.hasPermission('meeting:attendee:create')")
    public CommonResult<Boolean> createAttendee(@Valid @RequestBody MeetingAttendeeBaseVO createReqVO) {
        meetingAttendeeService.createAttendee(createReqVO);
        return success(true);
    }

    @DeleteMapping("/delete")
    @Operation(summary = "移除参会人")
    @Parameter(name = "id", description = "编号", required = true)
    @PreAuthorize("@ss.hasPermission('meeting:attendee:delete')")
    public CommonResult<Boolean> deleteAttendee(@RequestParam("id") Long id) {
        meetingAttendeeService.deleteAttendee(id);
        return success(true);
    }

    @GetMapping("/list")
    @Operation(summary = "获得参会人列表")
    @Parameter(name = "meetingId", description = "会议编号", required = true)
    @PreAuthorize("@ss.hasPermission('meeting:attendee:query')")
    public CommonResult<List<MeetingAttendeeDO>> getAttendeeList(@RequestParam("meetingId") Long meetingId) {
        return success(meetingAttendeeService.getAttendeeListByMeetingId(meetingId));
    }

    @PostMapping("/sign-in")
    @Operation(summary = "签到")
    public CommonResult<Boolean> signIn(@RequestParam("meetingId") Long meetingId, @RequestParam("userId") Long userId) {
        meetingAttendeeService.signIn(meetingId, userId);
        return success(true);
    }

    @PutMapping("/assign-seats")
    @Operation(summary = "批量分配座位")
    @PreAuthorize("@ss.hasPermission('meeting:attendee:update')")
    public CommonResult<Boolean> assignSeats(@Valid @RequestBody List<MeetingSeatAssignReqVO> assignReqVOList) {
        meetingAttendeeService.assignSeats(assignReqVOList);
        return success(true);
    }

    @GetMapping("/export-excel")
    @Operation(summary = "导出签到表")
    @PreAuthorize("@ss.hasPermission('meeting:attendee:query')")
    public void exportAttendeeExcel(@RequestParam("meetingId") Long meetingId,
                                    HttpServletResponse response) throws IOException {
        List<MeetingAttendeeDO> attendeeList = meetingAttendeeService.getAttendeeListByMeetingId(meetingId);
        Map<Long, AdminUserRespDTO> userMap = adminUserApi.getUserMap(convertList(attendeeList, MeetingAttendeeDO::getUserId));
        ExcelUtils.write(response, "会议签到表.xls", "签到表", MeetingAttendeeExportVO.class,
                convertList(attendeeList, attendee -> {
                    MeetingAttendeeExportVO vo = new MeetingAttendeeExportVO();
                    AdminUserRespDTO user = userMap.get(attendee.getUserId());
                    vo.setNickname(user != null ? user.getNickname() : "用户#" + attendee.getUserId());
                    vo.setRoleName(resolveRoleName(attendee.getRole()));
                    vo.setSignStatus(attendee.getStatus() != null && attendee.getStatus() == 1 ? "已签到" : "未签到");
                    vo.setSignInTime(attendee.getSignInTime());
                    vo.setSeatId(attendee.getSeatId());
                    return vo;
                }));
    }

    private String resolveRoleName(Integer role) {
        if (role == null) {
            return "与会人员";
        }
        return switch (role) {
            case 1 -> "主持人";
            case 2 -> "会议秘书";
            default -> "与会人员";
        };
    }

}

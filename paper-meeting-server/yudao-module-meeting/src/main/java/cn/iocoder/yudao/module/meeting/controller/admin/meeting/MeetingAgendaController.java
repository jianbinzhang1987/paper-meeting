package cn.iocoder.yudao.module.meeting.controller.admin.meeting;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingAgendaBaseVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAgendaDO;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingAgendaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import java.util.List;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

@Tag(name = "管理后台 - 会议议题")
@RestController
@RequestMapping("/meeting/agenda")
@Validated
public class MeetingAgendaController {

    @Resource
    private MeetingAgendaService meetingAgendaService;

    @PostMapping("/create")
    @Operation(summary = "创建议题")
    @PreAuthorize("@ss.hasPermission('meeting:agenda:create')")
    public CommonResult<Boolean> createAgenda(@Valid @RequestBody MeetingAgendaBaseVO createReqVO) {
        meetingAgendaService.createAgenda(createReqVO);
        return success(true);
    }

    @DeleteMapping("/delete")
    @Operation(summary = "删除议题")
    @Parameter(name = "id", description = "编号", required = true)
    @PreAuthorize("@ss.hasPermission('meeting:agenda:delete')")
    public CommonResult<Boolean> deleteAgenda(@RequestParam("id") Long id) {
        meetingAgendaService.deleteAgenda(id);
        return success(true);
    }

    @GetMapping("/list")
    @Operation(summary = "获得议题列表")
    @Parameter(name = "meetingId", description = "会议编号", required = true)
    @PreAuthorize("@ss.hasPermission('meeting:agenda:query')")
    public CommonResult<List<MeetingAgendaDO>> getAgendaList(@RequestParam("meetingId") Long meetingId) {
        return success(meetingAgendaService.getAgendaListByMeetingId(meetingId));
    }

}

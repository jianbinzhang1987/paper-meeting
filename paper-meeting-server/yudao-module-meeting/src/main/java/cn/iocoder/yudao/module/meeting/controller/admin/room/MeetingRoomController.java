package cn.iocoder.yudao.module.meeting.controller.admin.room;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.meeting.controller.admin.room.vo.*;
import cn.iocoder.yudao.module.meeting.convert.room.MeetingRoomConvert;
import cn.iocoder.yudao.module.meeting.dal.dataobject.room.MeetingRoomDO;
import cn.iocoder.yudao.module.meeting.service.room.MeetingRoomService;
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

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

@Tag(name = "管理后台 - 会议室")
@RestController
@RequestMapping("/meeting/room")
@Validated
public class MeetingRoomController {

    @Resource
    private MeetingRoomService meetingRoomService;

    @PostMapping("/create")
    @Operation(summary = "创建会议室")
    @PreAuthorize("@ss.hasPermission('meeting:room:create')")
    public CommonResult<Long> createRoom(@Valid @RequestBody MeetingRoomCreateReqVO createReqVO) {
        return success(meetingRoomService.createRoom(createReqVO));
    }

    @PutMapping("/update")
    @Operation(summary = "更新会议室")
    @PreAuthorize("@ss.hasPermission('meeting:room:update')")
    public CommonResult<Boolean> updateRoom(@Valid @RequestBody MeetingRoomUpdateReqVO updateReqVO) {
        meetingRoomService.updateRoom(updateReqVO);
        return success(true);
    }

    @DeleteMapping("/delete")
    @Operation(summary = "删除会议室")
    @Parameter(name = "id", description = "编号", required = true)
    @PreAuthorize("@ss.hasPermission('meeting:room:delete')")
    public CommonResult<Boolean> deleteRoom(@RequestParam("id") Long id) {
        meetingRoomService.deleteRoom(id);
        return success(true);
    }

    @GetMapping("/get")
    @Operation(summary = "获得会议室")
    @Parameter(name = "id", description = "编号", required = true, example = "1024")
    @PreAuthorize("@ss.hasPermission('meeting:room:query')")
    public CommonResult<MeetingRoomRespVO> getRoom(@RequestParam("id") Long id) {
        MeetingRoomDO room = meetingRoomService.getRoom(id);
        return success(MeetingRoomConvert.INSTANCE.convert(room));
    }

    @GetMapping("/page")
    @Operation(summary = "获得会议室分页")
    @PreAuthorize("@ss.hasPermission('meeting:room:query')")
    public CommonResult<PageResult<MeetingRoomRespVO>> getRoomPage(@Valid MeetingRoomPageReqVO pageVO) {
        PageResult<MeetingRoomDO> pageResult = meetingRoomService.getRoomPage(pageVO);
        return success(MeetingRoomConvert.INSTANCE.convertPage(pageResult));
    }

    @GetMapping("/overview")
    @Operation(summary = "获得会议室占用概览")
    @PreAuthorize("@ss.hasPermission('meeting:room:query')")
    public CommonResult<MeetingRoomOverviewRespVO> getRoomOverview() {
        return success(meetingRoomService.getRoomOverview());
    }

}

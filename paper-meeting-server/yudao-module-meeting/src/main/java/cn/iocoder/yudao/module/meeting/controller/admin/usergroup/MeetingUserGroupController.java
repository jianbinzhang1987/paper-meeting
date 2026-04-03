package cn.iocoder.yudao.module.meeting.controller.admin.usergroup;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.meeting.controller.admin.usergroup.vo.MeetingUserGroupCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.usergroup.vo.MeetingUserGroupPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.usergroup.vo.MeetingUserGroupRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.usergroup.vo.MeetingUserGroupSimpleRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.usergroup.vo.MeetingUserGroupUpdateReqVO;
import cn.iocoder.yudao.module.meeting.service.usergroup.MeetingUserGroupService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

@Tag(name = "管理后台 - 会议用户组")
@RestController
@RequestMapping("/meeting/user-group")
@Validated
public class MeetingUserGroupController {

    @Resource
    private MeetingUserGroupService meetingUserGroupService;

    @PostMapping("/create")
    @Operation(summary = "创建会议用户组")
    @PreAuthorize("@ss.hasPermission('meeting:user-group:create')")
    public CommonResult<Long> create(@Valid @RequestBody MeetingUserGroupCreateReqVO createReqVO) {
        return success(meetingUserGroupService.create(createReqVO));
    }

    @PutMapping("/update")
    @Operation(summary = "更新会议用户组")
    @PreAuthorize("@ss.hasPermission('meeting:user-group:update')")
    public CommonResult<Boolean> update(@Valid @RequestBody MeetingUserGroupUpdateReqVO updateReqVO) {
        meetingUserGroupService.update(updateReqVO);
        return success(true);
    }

    @DeleteMapping("/delete")
    @Operation(summary = "删除会议用户组")
    @PreAuthorize("@ss.hasPermission('meeting:user-group:delete')")
    public CommonResult<Boolean> delete(@RequestParam("id") Long id) {
        meetingUserGroupService.delete(id);
        return success(true);
    }

    @GetMapping("/get")
    @Operation(summary = "获得会议用户组")
    @PreAuthorize("@ss.hasPermission('meeting:user-group:query')")
    public CommonResult<MeetingUserGroupRespVO> get(@RequestParam("id") Long id) {
        return success(meetingUserGroupService.get(id));
    }

    @GetMapping("/page")
    @Operation(summary = "获得会议用户组分页")
    @PreAuthorize("@ss.hasPermission('meeting:user-group:query')")
    public CommonResult<PageResult<MeetingUserGroupRespVO>> getPage(@Valid MeetingUserGroupPageReqVO pageReqVO) {
        return success(meetingUserGroupService.getPage(pageReqVO));
    }

    @GetMapping("/simple-list")
    @Operation(summary = "获得会议用户组精简列表")
    @PreAuthorize("@ss.hasPermission('meeting:user-group:query')")
    public CommonResult<List<MeetingUserGroupSimpleRespVO>> getSimpleList() {
        return success(meetingUserGroupService.getSimpleList());
    }
}

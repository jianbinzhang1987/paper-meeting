package cn.iocoder.yudao.module.meeting.controller.admin.appversion;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.appversion.vo.MeetingAppVersionCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.appversion.vo.MeetingAppVersionPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.appversion.vo.MeetingAppVersionRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.appversion.vo.MeetingAppVersionUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.appversion.MeetingAppVersionDO;
import cn.iocoder.yudao.module.meeting.service.appversion.MeetingAppVersionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

@Tag(name = "管理后台 - 安装包管理")
@RestController
@RequestMapping("/meeting/app-version")
@Validated
public class MeetingAppVersionController {

    @Resource
    private MeetingAppVersionService meetingAppVersionService;

    @PostMapping("/create")
    @Operation(summary = "创建安装包版本")
    @PreAuthorize("@ss.hasPermission('meeting:app-version:create')")
    public CommonResult<Long> create(@Valid @RequestBody MeetingAppVersionCreateReqVO createReqVO) {
        return success(meetingAppVersionService.create(createReqVO));
    }

    @PutMapping("/update")
    @Operation(summary = "更新安装包版本")
    @PreAuthorize("@ss.hasPermission('meeting:app-version:update')")
    public CommonResult<Boolean> update(@Valid @RequestBody MeetingAppVersionUpdateReqVO updateReqVO) {
        meetingAppVersionService.update(updateReqVO);
        return success(true);
    }

    @DeleteMapping("/delete")
    @Operation(summary = "删除安装包版本")
    @PreAuthorize("@ss.hasPermission('meeting:app-version:delete')")
    public CommonResult<Boolean> delete(@RequestParam("id") Long id) {
        meetingAppVersionService.delete(id);
        return success(true);
    }

    @GetMapping("/get")
    @Operation(summary = "获得安装包版本")
    @PreAuthorize("@ss.hasPermission('meeting:app-version:query')")
    public CommonResult<MeetingAppVersionRespVO> get(@RequestParam("id") Long id) {
        return success(BeanUtils.toBean(meetingAppVersionService.get(id), MeetingAppVersionRespVO.class));
    }

    @GetMapping("/page")
    @Operation(summary = "获得安装包版本分页")
    @PreAuthorize("@ss.hasPermission('meeting:app-version:query')")
    public CommonResult<PageResult<MeetingAppVersionRespVO>> getPage(@Valid MeetingAppVersionPageReqVO pageReqVO) {
        PageResult<MeetingAppVersionDO> page = meetingAppVersionService.getPage(pageReqVO);
        return success(new PageResult<>(BeanUtils.toBean(page.getList(), MeetingAppVersionRespVO.class), page.getTotal()));
    }

    @PostMapping("/activate")
    @Operation(summary = "启用安装包版本")
    @PreAuthorize("@ss.hasPermission('meeting:app-version:update')")
    public CommonResult<Boolean> activate(@RequestParam("id") Long id) {
        meetingAppVersionService.activate(id);
        return success(true);
    }
}

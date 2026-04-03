package cn.iocoder.yudao.module.meeting.controller.admin.branding;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.branding.vo.MeetingBrandingCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.branding.vo.MeetingBrandingPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.branding.vo.MeetingBrandingRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.branding.vo.MeetingBrandingUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.branding.MeetingBrandingDO;
import cn.iocoder.yudao.module.meeting.service.branding.MeetingBrandingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

@Tag(name = "管理后台 - 会议贴牌")
@RestController
@RequestMapping("/meeting/branding")
@Validated
public class MeetingBrandingController {

    @Resource
    private MeetingBrandingService meetingBrandingService;

    @PostMapping("/create")
    @Operation(summary = "创建会议贴牌")
    @PreAuthorize("@ss.hasPermission('meeting:branding:create')")
    public CommonResult<Long> create(@Valid @RequestBody MeetingBrandingCreateReqVO createReqVO) {
        return success(meetingBrandingService.create(createReqVO));
    }

    @PutMapping("/update")
    @Operation(summary = "更新会议贴牌")
    @PreAuthorize("@ss.hasPermission('meeting:branding:update')")
    public CommonResult<Boolean> update(@Valid @RequestBody MeetingBrandingUpdateReqVO updateReqVO) {
        meetingBrandingService.update(updateReqVO);
        return success(true);
    }

    @DeleteMapping("/delete")
    @Operation(summary = "删除会议贴牌")
    @PreAuthorize("@ss.hasPermission('meeting:branding:delete')")
    public CommonResult<Boolean> delete(@RequestParam("id") Long id) {
        meetingBrandingService.delete(id);
        return success(true);
    }

    @GetMapping("/get")
    @Operation(summary = "获得会议贴牌")
    @PreAuthorize("@ss.hasPermission('meeting:branding:query')")
    public CommonResult<MeetingBrandingRespVO> get(@RequestParam("id") Long id) {
        return success(BeanUtils.toBean(meetingBrandingService.get(id), MeetingBrandingRespVO.class));
    }

    @GetMapping("/page")
    @Operation(summary = "获得会议贴牌分页")
    @PreAuthorize("@ss.hasPermission('meeting:branding:query')")
    public CommonResult<PageResult<MeetingBrandingRespVO>> getPage(@Valid MeetingBrandingPageReqVO pageReqVO) {
        PageResult<MeetingBrandingDO> page = meetingBrandingService.getPage(pageReqVO);
        return success(new PageResult<>(BeanUtils.toBean(page.getList(), MeetingBrandingRespVO.class), page.getTotal()));
    }

    @GetMapping("/active")
    @Operation(summary = "获得当前启用贴牌")
    @PreAuthorize("@ss.hasPermission('meeting:branding:query')")
    public CommonResult<MeetingBrandingRespVO> getActive() {
        return success(BeanUtils.toBean(meetingBrandingService.getActive(), MeetingBrandingRespVO.class));
    }

    @PostMapping("/activate")
    @Operation(summary = "启用会议贴牌")
    @PreAuthorize("@ss.hasPermission('meeting:branding:update')")
    public CommonResult<Boolean> activate(@RequestParam("id") Long id) {
        meetingBrandingService.activate(id);
        return success(true);
    }
}

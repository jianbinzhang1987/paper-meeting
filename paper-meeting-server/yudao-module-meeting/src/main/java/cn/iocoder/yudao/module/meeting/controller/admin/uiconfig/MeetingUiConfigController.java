package cn.iocoder.yudao.module.meeting.controller.admin.uiconfig;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.uiconfig.vo.MeetingUiConfigCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.uiconfig.vo.MeetingUiConfigPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.uiconfig.vo.MeetingUiConfigRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.uiconfig.vo.MeetingUiConfigUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.uiconfig.MeetingUiConfigDO;
import cn.iocoder.yudao.module.meeting.service.uiconfig.MeetingUiConfigService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

@Tag(name = "管理后台 - 客户端样式")
@RestController
@RequestMapping("/meeting/ui-config")
@Validated
public class MeetingUiConfigController {

    @Resource
    private MeetingUiConfigService meetingUiConfigService;

    @PostMapping("/create")
    @Operation(summary = "创建客户端样式")
    @PreAuthorize("@ss.hasPermission('meeting:ui-config:create')")
    public CommonResult<Long> create(@Valid @RequestBody MeetingUiConfigCreateReqVO createReqVO) {
        return success(meetingUiConfigService.create(createReqVO));
    }

    @PutMapping("/update")
    @Operation(summary = "更新客户端样式")
    @PreAuthorize("@ss.hasPermission('meeting:ui-config:update')")
    public CommonResult<Boolean> update(@Valid @RequestBody MeetingUiConfigUpdateReqVO updateReqVO) {
        meetingUiConfigService.update(updateReqVO);
        return success(true);
    }

    @DeleteMapping("/delete")
    @Operation(summary = "删除客户端样式")
    @PreAuthorize("@ss.hasPermission('meeting:ui-config:delete')")
    public CommonResult<Boolean> delete(@RequestParam("id") Long id) {
        meetingUiConfigService.delete(id);
        return success(true);
    }

    @GetMapping("/get")
    @Operation(summary = "获得客户端样式")
    @PreAuthorize("@ss.hasPermission('meeting:ui-config:query')")
    public CommonResult<MeetingUiConfigRespVO> get(@RequestParam("id") Long id) {
        return success(BeanUtils.toBean(meetingUiConfigService.get(id), MeetingUiConfigRespVO.class));
    }

    @GetMapping("/page")
    @Operation(summary = "获得客户端样式分页")
    @PreAuthorize("@ss.hasPermission('meeting:ui-config:query')")
    public CommonResult<PageResult<MeetingUiConfigRespVO>> getPage(@Valid MeetingUiConfigPageReqVO pageReqVO) {
        PageResult<MeetingUiConfigDO> page = meetingUiConfigService.getPage(pageReqVO);
        return success(new PageResult<>(BeanUtils.toBean(page.getList(), MeetingUiConfigRespVO.class), page.getTotal()));
    }

    @PostMapping("/activate")
    @Operation(summary = "启用客户端样式")
    @PreAuthorize("@ss.hasPermission('meeting:ui-config:update')")
    public CommonResult<Boolean> activate(@RequestParam("id") Long id) {
        meetingUiConfigService.activate(id);
        return success(true);
    }
}

package cn.iocoder.yudao.module.meeting.controller.admin.notification;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.notification.vo.MeetingNotificationCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.notification.vo.MeetingNotificationPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.notification.vo.MeetingNotificationRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.notification.vo.MeetingNotificationUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.notification.MeetingNotificationDO;
import cn.iocoder.yudao.module.meeting.service.notification.MeetingNotificationService;
import cn.iocoder.yudao.module.meeting.websocket.MeetingWebSocketSender;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

@Tag(name = "管理后台 - 会议消息")
@RestController
@RequestMapping("/meeting/notification")
@Validated
public class MeetingNotificationController {

    @Resource
    private MeetingNotificationService meetingNotificationService;
    @Resource
    private MeetingWebSocketSender meetingWebSocketSender;

    @PostMapping("/create")
    @Operation(summary = "创建会议消息")
    @PreAuthorize("@ss.hasPermission('meeting:notification:create')")
    public CommonResult<Long> create(@Valid @RequestBody MeetingNotificationCreateReqVO createReqVO) {
        return success(meetingNotificationService.create(createReqVO));
    }

    @PutMapping("/update")
    @Operation(summary = "更新会议消息")
    @PreAuthorize("@ss.hasPermission('meeting:notification:update')")
    public CommonResult<Boolean> update(@Valid @RequestBody MeetingNotificationUpdateReqVO updateReqVO) {
        meetingNotificationService.update(updateReqVO);
        return success(true);
    }

    @DeleteMapping("/delete")
    @Operation(summary = "删除会议消息")
    @Parameter(name = "id", required = true)
    @PreAuthorize("@ss.hasPermission('meeting:notification:delete')")
    public CommonResult<Boolean> delete(@RequestParam("id") Long id) {
        meetingNotificationService.delete(id);
        return success(true);
    }

    @GetMapping("/get")
    @Operation(summary = "获得会议消息")
    @PreAuthorize("@ss.hasPermission('meeting:notification:query')")
    public CommonResult<MeetingNotificationRespVO> get(@RequestParam("id") Long id) {
        return success(BeanUtils.toBean(meetingNotificationService.get(id), MeetingNotificationRespVO.class));
    }

    @GetMapping("/page")
    @Operation(summary = "获得会议消息分页")
    @PreAuthorize("@ss.hasPermission('meeting:notification:query')")
    public CommonResult<PageResult<MeetingNotificationRespVO>> getPage(@Valid MeetingNotificationPageReqVO pageReqVO) {
        PageResult<MeetingNotificationDO> page = meetingNotificationService.getPage(pageReqVO);
        return success(new PageResult<>(BeanUtils.toBean(page.getList(), MeetingNotificationRespVO.class), page.getTotal()));
    }

    @PostMapping("/publish")
    @Operation(summary = "发布会议消息")
    @PreAuthorize("@ss.hasPermission('meeting:notification:update')")
    public CommonResult<Boolean> publish(@RequestParam("id") Long id) {
        meetingNotificationService.publish(id);
        MeetingNotificationDO notice = meetingNotificationService.get(id);
        if (notice != null) {
            meetingWebSocketSender.sendNoticePublished(notice);
        }
        return success(true);
    }
}

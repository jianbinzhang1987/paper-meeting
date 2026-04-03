package cn.iocoder.yudao.module.meeting.controller.admin.publicfile;

import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileArchiveReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileCategoryTreeRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFilePageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.publicfile.MeetingPublicFileDO;
import cn.iocoder.yudao.module.meeting.service.publicfile.MeetingPublicFileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

@Tag(name = "管理后台 - 公共资料库")
@RestController
@RequestMapping("/meeting/public-file")
@Validated
public class MeetingPublicFileController {

    @Resource
    private MeetingPublicFileService meetingPublicFileService;

    @PostMapping("/create")
    @Operation(summary = "创建公共资料")
    @PreAuthorize("@ss.hasPermission('meeting:public-file:create')")
    public CommonResult<Long> create(@Valid @RequestBody MeetingPublicFileCreateReqVO createReqVO) {
        return success(meetingPublicFileService.create(createReqVO));
    }

    @PutMapping("/update")
    @Operation(summary = "更新公共资料")
    @PreAuthorize("@ss.hasPermission('meeting:public-file:update')")
    public CommonResult<Boolean> update(@Valid @RequestBody MeetingPublicFileUpdateReqVO updateReqVO) {
        meetingPublicFileService.update(updateReqVO);
        return success(true);
    }

    @DeleteMapping("/delete")
    @Operation(summary = "删除公共资料")
    @PreAuthorize("@ss.hasPermission('meeting:public-file:delete')")
    public CommonResult<Boolean> delete(@RequestParam("id") Long id) {
        meetingPublicFileService.delete(id);
        return success(true);
    }

    @GetMapping("/get")
    @Operation(summary = "获得公共资料")
    @PreAuthorize("@ss.hasPermission('meeting:public-file:query')")
    public CommonResult<MeetingPublicFileRespVO> get(@RequestParam("id") Long id) {
        return success(BeanUtils.toBean(meetingPublicFileService.get(id), MeetingPublicFileRespVO.class));
    }

    @GetMapping("/page")
    @Operation(summary = "获得公共资料分页")
    @PreAuthorize("@ss.hasPermission('meeting:public-file:query')")
    public CommonResult<PageResult<MeetingPublicFileRespVO>> getPage(@Valid MeetingPublicFilePageReqVO pageReqVO) {
        PageResult<MeetingPublicFileDO> page = meetingPublicFileService.getPage(pageReqVO);
        return success(new PageResult<>(BeanUtils.toBean(page.getList(), MeetingPublicFileRespVO.class), page.getTotal()));
    }

    @GetMapping("/category-tree")
    @Operation(summary = "获得公共资料分类树")
    @PreAuthorize("@ss.hasPermission('meeting:public-file:query')")
    public CommonResult<List<MeetingPublicFileCategoryTreeRespVO>> getCategoryTree() {
        return success(meetingPublicFileService.getCategoryTree());
    }

    @PostMapping("/archive")
    @Operation(summary = "执行公共资料归档")
    @PreAuthorize("@ss.hasPermission('meeting:public-file:update')")
    public CommonResult<Integer> archive(@RequestBody MeetingPublicFileArchiveReqVO reqVO) {
        return success(meetingPublicFileService.archive(reqVO));
    }
}

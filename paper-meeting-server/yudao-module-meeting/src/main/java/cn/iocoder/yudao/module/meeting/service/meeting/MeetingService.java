package cn.iocoder.yudao.module.meeting.service.meeting;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingApprovalCancelReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingApprovalLogRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingApproveReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingDO;

import jakarta.validation.Valid;
import java.util.Collection;
import java.util.List;

/**
 * 会议 Service 接口
 *
 * @author 芋道源码
 */
public interface MeetingService {

    /**
     * 创建会议
     *
     * @param createReqVO 创建信息
     * @return 编号
     */
    Long createMeeting(@Valid MeetingCreateReqVO createReqVO);

    /**
     * 更新会议
     *
     * @param updateReqVO 更新信息
     */
    void updateMeeting(@Valid MeetingUpdateReqVO updateReqVO);

    /**
     * 删除会议
     *
     * @param id 编号
     */
    void deleteMeeting(Long id);

    /**
     * 获得会议
     *
     * @param id 编号
     * @return 会议
     */
    MeetingDO getMeeting(Long id);

    /**
     * 获得会议列表
     *
     * @param ids 编号数组
     * @return 会议列表
     */
    List<MeetingDO> getMeetingList(Collection<Long> ids);

    /**
     * 获得会议室当前会议
     *
     * @param roomId 会议室编号
     * @return 当前会议
     */
    MeetingDO getCurrentMeetingByRoomId(Long roomId);

    /**
     * 获得会议分页
     *
     * @param pageReqVO 分页查询
     * @return 会议分页
     */
    PageResult<MeetingDO> getMeetingPage(MeetingPageReqVO pageReqVO);

    /**
     * 提交预约申请
     * @param id 会议编号
     */
    void submitBooking(Long id);

    /**
     * 审批预约申请
     * @param id 会议编号
     * @param approved 是否通过
     */
    void approveBooking(@Valid MeetingApproveReqVO reqVO);

    /**
     * 撤销审核
     *
     * @param reqVO 撤销信息
     */
    void cancelApproval(@Valid MeetingApprovalCancelReqVO reqVO);

    /**
     * 查询审批历史
     *
     * @param meetingId 会议编号
     * @return 审批记录
     */
    List<MeetingApprovalLogRespVO> getApprovalLogList(Long meetingId);

    /**
     * 开始会议
     * @param id 会议编号
     */
    void startMeeting(Long id);

    /**
     * 结束会议
     * @param id 会议编号
     */
    void stopMeeting(Long id);

    /**
     * 归档会议
     * @param id 会议编号
     */
    void archiveMeeting(Long id);

    /**
     * 撤回归档
     *
     * @param id 会议编号
     */
    void rollbackArchive(Long id);

    /**
     * 复制会议
     *
     * @param id 原会议编号
     * @return 新会议编号
     */
    Long copyMeeting(Long id);

    /**
     * 保存为模板
     *
     * @param id 原会议编号
     * @return 模板会议编号
     */
    Long saveAsTemplate(Long id);

}

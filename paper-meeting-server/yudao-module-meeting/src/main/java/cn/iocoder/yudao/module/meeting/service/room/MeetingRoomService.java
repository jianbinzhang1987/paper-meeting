package cn.iocoder.yudao.module.meeting.service.room;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.meeting.controller.admin.room.vo.MeetingRoomCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.room.vo.MeetingRoomOverviewRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.room.vo.MeetingRoomPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.room.vo.MeetingRoomUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.room.MeetingRoomDO;

import jakarta.validation.Valid;
import java.util.Collection;
import java.util.List;

/**
 * 会议室 Service 接口
 *
 * @author 芋道源码
 */
public interface MeetingRoomService {

    /**
     * 创建会议室
     *
     * @param createReqVO 创建信息
     * @return 编号
     */
    Long createRoom(@Valid MeetingRoomCreateReqVO createReqVO);

    /**
     * 更新会议室
     *
     * @param updateReqVO 更新信息
     */
    void updateRoom(@Valid MeetingRoomUpdateReqVO updateReqVO);

    /**
     * 删除会议室
     *
     * @param id 编号
     */
    void deleteRoom(Long id);

    /**
     * 获得会议室
     *
     * @param id 编号
     * @return 会议室
     */
    MeetingRoomDO getRoom(Long id);

    /**
     * 获得会议室列表
     *
     * @param ids 编号数组
     * @return 会议室列表
     */
    List<MeetingRoomDO> getRoomList(Collection<Long> ids);

    /**
     * 获得会议室分页
     *
     * @param pageReqVO 分页查询
     * @return 会议室分页
     */
    PageResult<MeetingRoomDO> getRoomPage(MeetingRoomPageReqVO pageReqVO);

    /**
     * 获得会议室占用概览
     *
     * @return 会议室概览
     */
    MeetingRoomOverviewRespVO getRoomOverview();

    /**
     * 获得所有会议室列表
     *
     * @return 会议室列表
     */
    List<MeetingRoomDO> getRoomList();

}

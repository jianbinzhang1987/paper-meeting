package cn.iocoder.yudao.module.meeting.dal.mysql.meeting;

import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingPageReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingDO;
import org.apache.ibatis.annotations.Mapper;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 会议 Mapper
 *
 * @author 芋道源码
 */
@Mapper
public interface MeetingMapper extends BaseMapperX<MeetingDO> {

    default List<MeetingDO> selectListByRoomId(Long roomId) {
        return selectList(MeetingDO::getRoomId, roomId);
    }

    default cn.iocoder.yudao.framework.common.pojo.PageResult<MeetingDO> selectPage(MeetingPageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<MeetingDO>()
                .likeIfPresent(MeetingDO::getName, reqVO.getName())
                .eqIfPresent(MeetingDO::getStatus, reqVO.getStatus())
                .eqIfPresent(MeetingDO::getType, reqVO.getType())
                .betweenIfPresent(MeetingDO::getStartTime, reqVO.getStartTime())
                .orderByDesc(MeetingDO::getId));
    }

    default MeetingDO selectConflictMeeting(Long roomId, LocalDateTime startTime, LocalDateTime endTime, Long excludeId) {
        return selectOne(new LambdaQueryWrapperX<MeetingDO>()
                .eq(MeetingDO::getRoomId, roomId)
                .neIfPresent(MeetingDO::getId, excludeId)
                .in(MeetingDO::getStatus, 1, 2, 3)
                .lt(MeetingDO::getStartTime, endTime)
                .gt(MeetingDO::getEndTime, startTime)
                .last("LIMIT 1"));
    }

    default MeetingDO selectCurrentMeetingByRoomId(Long roomId, LocalDateTime now) {
        return selectOne(new LambdaQueryWrapperX<MeetingDO>()
                .eq(MeetingDO::getRoomId, roomId)
                .in(MeetingDO::getStatus, 2, 3)
                .le(MeetingDO::getStartTime, now)
                .ge(MeetingDO::getEndTime, now)
                .orderByAsc(MeetingDO::getStartTime)
                .last("LIMIT 1"));
    }

    default List<MeetingDO> selectListByRoomIdsAndTimeRange(List<Long> roomIds, LocalDateTime startTime, LocalDateTime endTime) {
        return selectList(new LambdaQueryWrapperX<MeetingDO>()
                .inIfPresent(MeetingDO::getRoomId, roomIds)
                .ne(MeetingDO::getType, 2)
                .in(MeetingDO::getStatus, 1, 2, 3, 4, 5)
                .lt(MeetingDO::getStartTime, endTime)
                .gt(MeetingDO::getEndTime, startTime)
                .orderByAsc(MeetingDO::getStartTime));
    }

}

package cn.iocoder.yudao.module.meeting.dal.mysql.meeting;

import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAttendeeDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

/**
 * 参会人员 Mapper
 *
 * @author 芋道源码
 */
@Mapper
public interface MeetingAttendeeMapper extends BaseMapperX<MeetingAttendeeDO> {

    default List<MeetingAttendeeDO> selectListByMeetingId(Long meetingId) {
        return selectList(MeetingAttendeeDO::getMeetingId, meetingId);
    }

    default MeetingAttendeeDO selectByMeetingIdAndUserId(Long meetingId, Long userId) {
        return selectOne(MeetingAttendeeDO::getMeetingId, meetingId,
                MeetingAttendeeDO::getUserId, userId);
    }

}

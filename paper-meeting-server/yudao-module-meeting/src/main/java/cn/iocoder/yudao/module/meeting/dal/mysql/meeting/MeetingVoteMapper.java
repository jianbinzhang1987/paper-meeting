package cn.iocoder.yudao.module.meeting.dal.mysql.meeting;

import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

/**
 * 会议表决 Mapper
 *
 * @author 芋道源码
 */
@Mapper
public interface MeetingVoteMapper extends BaseMapperX<MeetingVoteDO> {

    default List<MeetingVoteDO> selectListByMeetingId(Long meetingId) {
        return selectList(MeetingVoteDO::getMeetingId, meetingId);
    }

}

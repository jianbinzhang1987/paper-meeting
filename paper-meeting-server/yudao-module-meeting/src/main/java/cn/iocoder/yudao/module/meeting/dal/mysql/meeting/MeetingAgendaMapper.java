package cn.iocoder.yudao.module.meeting.dal.mysql.meeting;

import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAgendaDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

/**
 * 会议议题 Mapper
 *
 * @author 芋道源码
 */
@Mapper
public interface MeetingAgendaMapper extends BaseMapperX<MeetingAgendaDO> {

    default List<MeetingAgendaDO> selectListByMeetingId(Long meetingId) {
        return selectList(MeetingAgendaDO::getMeetingId, meetingId);
    }

}

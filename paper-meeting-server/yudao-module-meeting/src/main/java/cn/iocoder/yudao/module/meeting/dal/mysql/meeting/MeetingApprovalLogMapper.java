package cn.iocoder.yudao.module.meeting.dal.mysql.meeting;

import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingApprovalLogDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface MeetingApprovalLogMapper extends BaseMapperX<MeetingApprovalLogDO> {

    default List<MeetingApprovalLogDO> selectListByMeetingId(Long meetingId) {
        return selectList(MeetingApprovalLogDO::getMeetingId, meetingId);
    }
}

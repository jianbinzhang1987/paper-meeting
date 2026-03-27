package cn.iocoder.yudao.module.meeting.dal.mysql.meeting;

import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteRecordDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface MeetingVoteRecordMapper extends BaseMapperX<MeetingVoteRecordDO> {
    default List<MeetingVoteRecordDO> selectListByVoteId(Long voteId) {
        return selectList(MeetingVoteRecordDO::getVoteId, voteId);
    }

    default int deleteByVoteId(Long voteId) {
        return delete(MeetingVoteRecordDO::getVoteId, voteId);
    }
}

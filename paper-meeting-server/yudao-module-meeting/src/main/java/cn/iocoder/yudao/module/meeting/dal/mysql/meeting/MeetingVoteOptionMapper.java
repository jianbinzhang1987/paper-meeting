package cn.iocoder.yudao.module.meeting.dal.mysql.meeting;

import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteOptionDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface MeetingVoteOptionMapper extends BaseMapperX<MeetingVoteOptionDO> {
    default List<MeetingVoteOptionDO> selectListByVoteId(Long voteId) {
        return selectList(MeetingVoteOptionDO::getVoteId, voteId);
    }

    default int deleteByVoteId(Long voteId) {
        return delete(MeetingVoteOptionDO::getVoteId, voteId);
    }
}

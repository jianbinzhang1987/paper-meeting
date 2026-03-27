package cn.iocoder.yudao.module.meeting.dal.mysql.meeting;

import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingSignatureDO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MeetingSignatureMapper extends BaseMapperX<MeetingSignatureDO> {

    default MeetingSignatureDO selectLatest(Long meetingId, Long userId) {
        return selectOne(new LambdaQueryWrapperX<MeetingSignatureDO>()
                .eq(MeetingSignatureDO::getMeetingId, meetingId)
                .eq(MeetingSignatureDO::getUserId, userId)
                .orderByDesc(MeetingSignatureDO::getId)
                .last("LIMIT 1"));
    }
}

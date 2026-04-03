package cn.iocoder.yudao.module.meeting.dal.mysql.notification;

import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.module.meeting.dal.dataobject.notification.MeetingNoticeReadDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.Collection;
import java.util.List;

@Mapper
public interface MeetingNoticeReadMapper extends BaseMapperX<MeetingNoticeReadDO> {

    default MeetingNoticeReadDO selectByUniqueKey(Long meetingId, Long userId, Long noticeId) {
        return selectOne(new LambdaQueryWrapperX<MeetingNoticeReadDO>()
                .eq(MeetingNoticeReadDO::getMeetingId, meetingId)
                .eq(MeetingNoticeReadDO::getUserId, userId)
                .eq(MeetingNoticeReadDO::getNoticeId, noticeId)
                .last("LIMIT 1"));
    }

    default List<MeetingNoticeReadDO> selectList(Long meetingId, Long userId, Collection<Long> noticeIds) {
        return selectList(new LambdaQueryWrapperX<MeetingNoticeReadDO>()
                .eq(MeetingNoticeReadDO::getMeetingId, meetingId)
                .eq(MeetingNoticeReadDO::getUserId, userId)
                .inIfPresent(MeetingNoticeReadDO::getNoticeId, noticeIds));
    }

    default List<MeetingNoticeReadDO> selectListByNoticeIds(Collection<Long> noticeIds) {
        return selectList(new LambdaQueryWrapperX<MeetingNoticeReadDO>()
                .inIfPresent(MeetingNoticeReadDO::getNoticeId, noticeIds));
    }
}

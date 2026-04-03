package cn.iocoder.yudao.module.meeting.service.notification;

import cn.iocoder.yudao.module.meeting.dal.dataobject.notification.MeetingNoticeReadDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.notification.MeetingNoticeReadMapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;

@Service
@Validated
public class MeetingNoticeReadServiceImpl implements MeetingNoticeReadService {

    @Resource
    private MeetingNoticeReadMapper meetingNoticeReadMapper;

    @Override
    public void markRead(Long meetingId, Long userId, Long noticeId) {
        MeetingNoticeReadDO read = meetingNoticeReadMapper.selectByUniqueKey(meetingId, userId, noticeId);
        if (read != null) {
            return;
        }
        read = new MeetingNoticeReadDO();
        read.setMeetingId(meetingId);
        read.setUserId(userId);
        read.setNoticeId(noticeId);
        read.setReadTime(LocalDateTime.now());
        meetingNoticeReadMapper.insert(read);
    }

    @Override
    public List<MeetingNoticeReadDO> getReadList(Long meetingId, Long userId, Collection<Long> noticeIds) {
        return meetingNoticeReadMapper.selectList(meetingId, userId, noticeIds);
    }
}

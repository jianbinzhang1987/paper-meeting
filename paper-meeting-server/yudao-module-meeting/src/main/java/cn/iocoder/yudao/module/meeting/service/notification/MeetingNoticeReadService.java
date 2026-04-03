package cn.iocoder.yudao.module.meeting.service.notification;

import cn.iocoder.yudao.module.meeting.dal.dataobject.notification.MeetingNoticeReadDO;

import java.util.Collection;
import java.util.List;

public interface MeetingNoticeReadService {

    void markRead(Long meetingId, Long userId, Long noticeId);

    List<MeetingNoticeReadDO> getReadList(Long meetingId, Long userId, Collection<Long> noticeIds);
}

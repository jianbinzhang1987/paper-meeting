package cn.iocoder.yudao.module.meeting.service.meeting;

import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingSignatureDO;

public interface MeetingSignatureService {

    MeetingSignatureDO submitSignature(Long meetingId, Long userId, String seatId, byte[] imageContent, Integer strokeCount);

    MeetingSignatureDO getLatestSignature(Long meetingId, Long userId);
}

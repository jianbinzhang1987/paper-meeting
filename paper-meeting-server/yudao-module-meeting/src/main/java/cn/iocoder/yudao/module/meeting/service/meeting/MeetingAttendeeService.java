package cn.iocoder.yudao.module.meeting.service.meeting;

import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingAttendeeBaseVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingSeatAssignReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAttendeeDO;

import java.util.List;

public interface MeetingAttendeeService {

    void createAttendee(MeetingAttendeeBaseVO createReqVO);

    void deleteAttendee(Long id);

    List<MeetingAttendeeDO> getAttendeeListByMeetingId(Long meetingId);

    MeetingAttendeeDO getAttendee(Long meetingId, Long userId);

    void signIn(Long meetingId, Long userId);

    void assignSeats(List<MeetingSeatAssignReqVO> assignReqVOList);

}

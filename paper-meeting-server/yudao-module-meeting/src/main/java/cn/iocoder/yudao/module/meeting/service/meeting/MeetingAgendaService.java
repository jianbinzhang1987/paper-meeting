package cn.iocoder.yudao.module.meeting.service.meeting;

import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingAgendaBaseVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAgendaDO;

import java.util.List;

public interface MeetingAgendaService {

    void createAgenda(MeetingAgendaBaseVO createReqVO);

    void updateAgenda(MeetingAgendaBaseVO updateReqVO);

    void deleteAgenda(Long id);

    List<MeetingAgendaDO> getAgendaListByMeetingId(Long meetingId);

}

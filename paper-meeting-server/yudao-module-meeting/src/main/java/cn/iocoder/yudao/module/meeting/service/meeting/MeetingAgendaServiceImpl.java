package cn.iocoder.yudao.module.meeting.service.meeting;

import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingAgendaBaseVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAgendaDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingAgendaMapper;
import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

import jakarta.annotation.Resource;
import java.util.List;

@Service
@Validated
public class MeetingAgendaServiceImpl implements MeetingAgendaService {

    @Resource
    private MeetingAgendaMapper meetingAgendaMapper;

    @Override
    public void createAgenda(MeetingAgendaBaseVO createReqVO) {
        MeetingAgendaDO agenda = new MeetingAgendaDO();
        agenda.setMeetingId(createReqVO.getMeetingId());
        agenda.setParentId(createReqVO.getParentId());
        agenda.setTitle(createReqVO.getTitle());
        agenda.setContent(createReqVO.getContent());
        agenda.setSort(createReqVO.getSort());
        agenda.setIsVote(createReqVO.getIsVote());
        meetingAgendaMapper.insert(agenda);
    }

    @Override
    public void updateAgenda(MeetingAgendaBaseVO updateReqVO) {
        // Implementation for update
    }

    @Override
    public void deleteAgenda(Long id) {
        meetingAgendaMapper.deleteById(id);
    }

    @Override
    public List<MeetingAgendaDO> getAgendaListByMeetingId(Long meetingId) {
        return meetingAgendaMapper.selectListByMeetingId(meetingId);
    }
}

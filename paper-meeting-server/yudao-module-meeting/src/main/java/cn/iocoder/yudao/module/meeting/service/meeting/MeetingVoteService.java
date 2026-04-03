package cn.iocoder.yudao.module.meeting.service.meeting;

import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteDashboardRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteResultExportVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteRespVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteRecordDO;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public interface MeetingVoteService {
    Long createVote(MeetingVoteCreateReqVO createReqVO);
    void deleteVote(Long id);
    MeetingVoteDO getVote(Long id);
    List<MeetingVoteRespVO> getVoteListByMeetingId(Long meetingId);
    MeetingVoteDashboardRespVO getVoteDashboardByMeetingId(Long meetingId);
    List<MeetingVoteResultExportVO> getVoteResultExportList(Long meetingId);
    void submitVote(MeetingVoteRecordDO recordDO);
    void updateVoteStatus(Long id, Integer status);
    void markVotePublished(Long id, LocalDateTime publishedTime);
    Map<Long, Long> getVoteOptionCountMap(Long voteId);
    boolean hasUserVoted(Long voteId, Long userId);
}

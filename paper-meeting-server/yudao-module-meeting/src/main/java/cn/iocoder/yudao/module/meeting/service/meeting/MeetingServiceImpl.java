package cn.iocoder.yudao.module.meeting.service.meeting;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.framework.security.core.util.SecurityFrameworkUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingApprovalCancelReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingApprovalLogRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingApproveReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAgendaDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingApprovalLogDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAttendeeDO;
import cn.iocoder.yudao.module.meeting.convert.meeting.MeetingConvert;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingFileDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteOptionDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingAgendaMapper;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingApprovalLogMapper;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingAttendeeMapper;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingFileMapper;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingMapper;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingVoteMapper;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingVoteOptionMapper;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingVoteRecordMapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.annotation.Validated;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static cn.iocoder.yudao.framework.common.exception.util.ServiceExceptionUtil.exception;
import static cn.iocoder.yudao.module.meeting.enums.ErrorCodeConstants.MEETING_NOT_EXISTS;
import static cn.iocoder.yudao.module.meeting.enums.ErrorCodeConstants.MEETING_TIME_CONFLICT;

/**
 * 会议 Service 实现类
 *
 * @author 芋道源码
 */
@Service
@Validated
public class MeetingServiceImpl implements MeetingService {

    @Resource
    private MeetingMapper meetingMapper;
    @Resource
    private MeetingAgendaMapper meetingAgendaMapper;
    @Resource
    private MeetingApprovalLogMapper meetingApprovalLogMapper;
    @Resource
    private MeetingAttendeeMapper meetingAttendeeMapper;
    @Resource
    private MeetingFileMapper meetingFileMapper;
    @Resource
    private MeetingVoteMapper meetingVoteMapper;
    @Resource
    private MeetingVoteOptionMapper meetingVoteOptionMapper;
    @Resource
    private MeetingVoteRecordMapper meetingVoteRecordMapper;

    @Override
    public Long createMeeting(MeetingCreateReqVO createReqVO) {
        validateMeetingConflict(null, createReqVO.getRoomId(), createReqVO.getStartTime(), createReqVO.getEndTime());
        // 插入
        MeetingDO meeting = MeetingConvert.INSTANCE.convert(createReqVO);
        meeting.setStatus(Boolean.TRUE.equals(createReqVO.getRequireApproval()) && Integer.valueOf(1).equals(createReqVO.getType()) ? 0 : 2);
        meetingMapper.insert(meeting);
        // 返回
        return meeting.getId();
    }

    @Override
    public void updateMeeting(MeetingUpdateReqVO updateReqVO) {
        // 校验存在
        validateMeetingExists(updateReqVO.getId());
        validateMeetingConflict(updateReqVO.getId(), updateReqVO.getRoomId(), updateReqVO.getStartTime(), updateReqVO.getEndTime());
        // 更新
        MeetingDO updateObj = MeetingConvert.INSTANCE.convert(updateReqVO);
        meetingMapper.updateById(updateObj);
    }

    @Override
    public void deleteMeeting(Long id) {
        // 校验存在
        validateMeetingExists(id);
        // 删除
        meetingMapper.deleteById(id);
    }

    private void validateMeetingExists(Long id) {
        validateMeetingExists0(id);
    }

    private MeetingDO validateMeetingExists0(Long id) {
        MeetingDO meeting = meetingMapper.selectById(id);
        if (meeting == null) {
            throw exception(MEETING_NOT_EXISTS);
        }
        return meeting;
    }

    private void validateMeetingConflict(Long id, Long roomId, LocalDateTime startTime, LocalDateTime endTime) {
        if (roomId == null || startTime == null || endTime == null) {
            return;
        }
        MeetingDO conflict = meetingMapper.selectConflictMeeting(roomId, startTime, endTime, id);
        if (conflict != null) {
            throw exception(MEETING_TIME_CONFLICT);
        }
    }

    @Override
    public MeetingDO getMeeting(Long id) {
        return meetingMapper.selectById(id);
    }

    @Override
    public List<MeetingDO> getMeetingList(Collection<Long> ids) {
        return meetingMapper.selectBatchIds(ids);
    }

    @Override
    public MeetingDO getCurrentMeetingByRoomId(Long roomId) {
        return meetingMapper.selectCurrentMeetingByRoomId(roomId, LocalDateTime.now());
    }

    @Override
    public PageResult<MeetingDO> getMeetingPage(MeetingPageReqVO pageReqVO) {
        return meetingMapper.selectPage(pageReqVO);
    }

    @Override
    public void submitBooking(Long id) {
        MeetingDO meeting = validateMeetingExists0(id);
        validateMeetingConflict(id, meeting.getRoomId(), meeting.getStartTime(), meeting.getEndTime());
        meetingMapper.updateById(new MeetingDO().setId(id).setStatus(1)); // 待审批
        createApprovalLog(id, 1, "提交预约");
    }

    @Override
    public void approveBooking(MeetingApproveReqVO reqVO) {
        validateMeetingExists(reqVO.getId());
        meetingMapper.updateById(new MeetingDO().setId(reqVO.getId()).setStatus(Boolean.TRUE.equals(reqVO.getApproved()) ? 2 : 0));
        createApprovalLog(reqVO.getId(), Boolean.TRUE.equals(reqVO.getApproved()) ? 2 : 3, reqVO.getRemark());
    }

    @Override
    public void cancelApproval(MeetingApprovalCancelReqVO reqVO) {
        validateMeetingExists(reqVO.getId());
        meetingMapper.updateById(new MeetingDO().setId(reqVO.getId()).setStatus(0));
        createApprovalLog(reqVO.getId(), 4, reqVO.getRemark());
    }

    @Override
    public List<MeetingApprovalLogRespVO> getApprovalLogList(Long meetingId) {
        validateMeetingExists(meetingId);
        List<MeetingApprovalLogDO> logList = meetingApprovalLogMapper.selectListByMeetingId(meetingId);
        logList.sort(Comparator.comparing(MeetingApprovalLogDO::getCreateTime).reversed());
        List<MeetingApprovalLogRespVO> respList = new ArrayList<>(logList.size());
        for (MeetingApprovalLogDO log : logList) {
            MeetingApprovalLogRespVO vo = BeanUtils.toBean(log, MeetingApprovalLogRespVO.class);
            vo.setActionName(resolveApprovalActionName(log.getAction()));
            respList.add(vo);
        }
        return respList;
    }

    @Override
    public void startMeeting(Long id) {
        MeetingDO meeting = validateMeetingExists0(id);
        validateMeetingConflict(id, meeting.getRoomId(), meeting.getStartTime(), meeting.getEndTime());
        meetingMapper.updateById(new MeetingDO().setId(id).setStatus(3)); // 进行中
    }

    @Override
    public void stopMeeting(Long id) {
        MeetingDO meeting = validateMeetingExists0(id);
        if (Integer.valueOf(1).equals(meeting.getLevel())) {
            cleanupMeetingArtifacts(id);
            meetingMapper.updateById(new MeetingDO().setId(id).setStatus(4));
            return;
        }
        meetingMapper.updateById(new MeetingDO().setId(id).setStatus(5).setArchiveTime(LocalDateTime.now()));
    }

    @Override
    public void archiveMeeting(Long id) {
        validateMeetingExists(id);
        meetingMapper.updateById(new MeetingDO().setId(id).setStatus(5).setArchiveTime(LocalDateTime.now()));
    }

    @Override
    public void rollbackArchive(Long id) {
        validateMeetingExists(id);
        meetingMapper.updateById(new MeetingDO().setId(id).setStatus(4).setArchiveTime(null)); // 还原为已结束
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long copyMeeting(Long id) {
        return cloneMeeting(id, false);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long saveAsTemplate(Long id) {
        return cloneMeeting(id, true);
    }

    private Long cloneMeeting(Long id, boolean asTemplate) {
        MeetingDO source = meetingMapper.selectById(id);
        if (source == null) {
            throw exception(MEETING_NOT_EXISTS);
        }

        MeetingDO target = BeanUtils.toBean(source, MeetingDO.class);
        target.setId(null);
        target.setName(source.getName() + (asTemplate ? " - 模板" : " - 复制"));
        target.setStatus(0);
        target.setType(asTemplate ? 2 : source.getType());
        target.setStartTime(LocalDateTime.now());
        target.setEndTime(LocalDateTime.now().plusHours(1));
        target.setArchiveTime(null);
        meetingMapper.insert(target);

        Map<Long, Long> agendaIdMap = copyAgendas(source.getId(), target.getId());
        copyAttendees(source.getId(), target.getId());
        copyFiles(source.getId(), target.getId(), agendaIdMap);
        copyVotes(source.getId(), target.getId(), agendaIdMap);
        return target.getId();
    }

    private Map<Long, Long> copyAgendas(Long sourceMeetingId, Long targetMeetingId) {
        List<MeetingAgendaDO> sourceAgendaList = meetingAgendaMapper.selectListByMeetingId(sourceMeetingId);
        Map<Long, Long> agendaIdMap = new HashMap<>();
        List<MeetingAgendaDO> pendingList = new ArrayList<>(sourceAgendaList);
        while (!pendingList.isEmpty()) {
            int handled = 0;
            for (int i = 0; i < pendingList.size(); i++) {
                MeetingAgendaDO agenda = pendingList.get(i);
                if (agenda.getParentId() != null && agenda.getParentId() > 0 && !agendaIdMap.containsKey(agenda.getParentId())) {
                    continue;
                }
                MeetingAgendaDO targetAgenda = BeanUtils.toBean(agenda, MeetingAgendaDO.class);
                targetAgenda.setId(null);
                targetAgenda.setMeetingId(targetMeetingId);
                targetAgenda.setParentId(agenda.getParentId() != null && agenda.getParentId() > 0
                        ? agendaIdMap.get(agenda.getParentId()) : 0L);
                meetingAgendaMapper.insert(targetAgenda);
                agendaIdMap.put(agenda.getId(), targetAgenda.getId());
                pendingList.remove(i);
                i--;
                handled++;
            }
            if (handled == 0) {
                break;
            }
        }
        return agendaIdMap;
    }

    private void copyAttendees(Long sourceMeetingId, Long targetMeetingId) {
        List<MeetingAttendeeDO> attendeeList = meetingAttendeeMapper.selectListByMeetingId(sourceMeetingId);
        attendeeList.forEach(attendee -> {
            MeetingAttendeeDO targetAttendee = BeanUtils.toBean(attendee, MeetingAttendeeDO.class);
            targetAttendee.setId(null);
            targetAttendee.setMeetingId(targetMeetingId);
            targetAttendee.setStatus(0);
            targetAttendee.setSignInTime(null);
            targetAttendee.setSeatId(null);
            meetingAttendeeMapper.insert(targetAttendee);
        });
    }

    private void copyFiles(Long sourceMeetingId, Long targetMeetingId, Map<Long, Long> agendaIdMap) {
        List<MeetingFileDO> fileList = meetingFileMapper.selectListByMeetingId(sourceMeetingId);
        fileList.forEach(file -> {
            MeetingFileDO targetFile = BeanUtils.toBean(file, MeetingFileDO.class);
            targetFile.setId(null);
            targetFile.setMeetingId(targetMeetingId);
            targetFile.setAgendaId(file.getAgendaId() != null ? agendaIdMap.get(file.getAgendaId()) : null);
            meetingFileMapper.insert(targetFile);
        });
    }

    private void copyVotes(Long sourceMeetingId, Long targetMeetingId, Map<Long, Long> agendaIdMap) {
        List<MeetingVoteDO> voteList = meetingVoteMapper.selectListByMeetingId(sourceMeetingId);
        voteList.forEach(vote -> {
            MeetingVoteDO targetVote = BeanUtils.toBean(vote, MeetingVoteDO.class);
            targetVote.setId(null);
            targetVote.setMeetingId(targetMeetingId);
            targetVote.setAgendaId(vote.getAgendaId() != null ? agendaIdMap.get(vote.getAgendaId()) : null);
            targetVote.setStatus(0);
            meetingVoteMapper.insert(targetVote);

            List<MeetingVoteOptionDO> optionList = meetingVoteOptionMapper.selectListByVoteId(vote.getId());
            optionList.forEach(option -> {
                MeetingVoteOptionDO targetOption = BeanUtils.toBean(option, MeetingVoteOptionDO.class);
                targetOption.setId(null);
                targetOption.setVoteId(targetVote.getId());
                meetingVoteOptionMapper.insert(targetOption);
            });
        });
    }

    private void createApprovalLog(Long meetingId, Integer action, String remark) {
        MeetingApprovalLogDO log = new MeetingApprovalLogDO();
        log.setMeetingId(meetingId);
        log.setAction(action);
        log.setOperatorId(SecurityFrameworkUtils.getLoginUserId());
        log.setOperatorName(SecurityFrameworkUtils.getLoginUserNickname());
        log.setRemark(remark);
        meetingApprovalLogMapper.insert(log);
    }

    private String resolveApprovalActionName(Integer action) {
        if (action == null) {
            return "未知操作";
        }
        return switch (action) {
            case 1 -> "提交预约";
            case 2 -> "审批通过";
            case 3 -> "审批驳回";
            case 4 -> "撤销审核";
            default -> "未知操作";
        };
    }

    private void cleanupMeetingArtifacts(Long meetingId) {
        meetingAgendaMapper.delete(MeetingAgendaDO::getMeetingId, meetingId);
        meetingAttendeeMapper.delete(MeetingAttendeeDO::getMeetingId, meetingId);
        meetingFileMapper.delete(MeetingFileDO::getMeetingId, meetingId);
        List<MeetingVoteDO> voteList = meetingVoteMapper.selectListByMeetingId(meetingId);
        voteList.forEach(vote -> {
            meetingVoteOptionMapper.delete(MeetingVoteOptionDO::getVoteId, vote.getId());
            meetingVoteRecordMapper.deleteByVoteId(vote.getId());
            meetingVoteMapper.deleteById(vote.getId());
        });
    }

}

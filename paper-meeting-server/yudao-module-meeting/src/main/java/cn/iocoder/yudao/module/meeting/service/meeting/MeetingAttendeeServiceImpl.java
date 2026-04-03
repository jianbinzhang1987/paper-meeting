package cn.iocoder.yudao.module.meeting.service.meeting;

import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingAttendeeBaseVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingAttendeeImportGroupReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingSeatAssignReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAttendeeDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingAttendeeMapper;
import cn.iocoder.yudao.module.meeting.dal.dataobject.usergroup.MeetingUserGroupDO;
import cn.iocoder.yudao.module.meeting.service.usergroup.MeetingUserGroupService;
import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.validation.annotation.Validated;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
@Validated
public class MeetingAttendeeServiceImpl implements MeetingAttendeeService {

    @Resource
    private MeetingAttendeeMapper meetingAttendeeMapper;
    @Resource
    private MeetingUserGroupService meetingUserGroupService;

    @Override
    public void createAttendee(MeetingAttendeeBaseVO createReqVO) {
        MeetingAttendeeDO attendee = new MeetingAttendeeDO();
        attendee.setMeetingId(createReqVO.getMeetingId());
        attendee.setUserId(createReqVO.getUserId());
        attendee.setRole(createReqVO.getRole());
        attendee.setStatus(createReqVO.getStatus());
        attendee.setSeatId(createReqVO.getSeatId());
        meetingAttendeeMapper.insert(attendee);
    }

    @Override
    public void deleteAttendee(Long id) {
        meetingAttendeeMapper.deleteById(id);
    }

    @Override
    public List<MeetingAttendeeDO> getAttendeeListByMeetingId(Long meetingId) {
        return meetingAttendeeMapper.selectListByMeetingId(meetingId);
    }

    @Override
    public MeetingAttendeeDO getAttendee(Long meetingId, Long userId) {
        return meetingAttendeeMapper.selectByMeetingIdAndUserId(meetingId, userId);
    }

    @Override
    public void signIn(Long meetingId, Long userId) {
        MeetingAttendeeDO attendee = meetingAttendeeMapper.selectByMeetingIdAndUserId(meetingId, userId);
        if (attendee != null) {
            attendee.setStatus(1); // 已签到
            attendee.setSignInTime(LocalDateTime.now());
            meetingAttendeeMapper.updateById(attendee);
        }
    }

    @Override
    public void assignSeats(List<MeetingSeatAssignReqVO> assignReqVOList) {
        for (MeetingSeatAssignReqVO assignReqVO : assignReqVOList) {
            MeetingAttendeeDO attendee = meetingAttendeeMapper.selectById(assignReqVO.getAttendeeId());
            if (attendee == null) {
                continue;
            }
            attendee.setSeatId(StringUtils.hasText(assignReqVO.getSeatId()) ? assignReqVO.getSeatId() : null);
            meetingAttendeeMapper.updateById(attendee);
        }
    }

    @Override
    public void importByGroups(MeetingAttendeeImportGroupReqVO reqVO) {
        Set<Long> existingUserIds = new HashSet<>(getAttendeeListByMeetingId(reqVO.getMeetingId()).stream()
                .map(MeetingAttendeeDO::getUserId)
                .toList());
        List<MeetingUserGroupDO> groups = meetingUserGroupService.getListByIds(reqVO.getGroupIds());
        for (MeetingUserGroupDO group : groups) {
            if (!StringUtils.hasText(group.getUserIds())) {
                continue;
            }
            List<Long> userIds = Arrays.stream(group.getUserIds().split(","))
                    .filter(StringUtils::hasText)
                    .map(Long::valueOf)
                    .toList();
            for (Long userId : userIds) {
                if (existingUserIds.contains(userId)) {
                    continue;
                }
                MeetingAttendeeDO attendee = new MeetingAttendeeDO();
                attendee.setMeetingId(reqVO.getMeetingId());
                attendee.setUserId(userId);
                attendee.setRole(reqVO.getRole());
                attendee.setStatus(0);
                meetingAttendeeMapper.insert(attendee);
                existingUserIds.add(userId);
            }
        }
    }
}

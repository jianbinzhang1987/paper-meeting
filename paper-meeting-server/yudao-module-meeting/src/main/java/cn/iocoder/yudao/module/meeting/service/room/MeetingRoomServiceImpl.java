package cn.iocoder.yudao.module.meeting.service.room;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.meeting.controller.admin.room.vo.MeetingRoomCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.room.vo.MeetingRoomOverviewItemRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.room.vo.MeetingRoomOverviewRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.room.vo.MeetingRoomPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.room.vo.MeetingRoomTodayMeetingRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.room.vo.MeetingRoomUpdateReqVO;
import cn.iocoder.yudao.module.meeting.convert.room.MeetingRoomConvert;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.room.MeetingRoomDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingMapper;
import cn.iocoder.yudao.module.meeting.dal.mysql.room.MeetingRoomMapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.Comparator;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import static cn.iocoder.yudao.framework.common.exception.util.ServiceExceptionUtil.exception;
import static cn.iocoder.yudao.module.meeting.enums.ErrorCodeConstants.MEETING_ROOM_NOT_EXISTS;

/**
 * 会议室 Service 实现类
 *
 * @author 芋道源码
 */
@Service
@Validated
public class MeetingRoomServiceImpl implements MeetingRoomService {

    @Resource
    private MeetingRoomMapper meetingRoomMapper;
    @Resource
    private MeetingMapper meetingMapper;

    @Override
    public Long createRoom(MeetingRoomCreateReqVO createReqVO) {
        // 插入
        MeetingRoomDO room = MeetingRoomConvert.INSTANCE.convert(createReqVO);
        meetingRoomMapper.insert(room);
        // 返回
        return room.getId();
    }

    @Override
    public void updateRoom(MeetingRoomUpdateReqVO updateReqVO) {
        // 校验存在
        validateRoomExists(updateReqVO.getId());
        // 更新
        MeetingRoomDO updateObj = MeetingRoomConvert.INSTANCE.convert(updateReqVO);
        meetingRoomMapper.updateById(updateObj);
    }

    @Override
    public void deleteRoom(Long id) {
        // 校验存在
        validateRoomExists(id);
        // 删除
        meetingRoomMapper.deleteById(id);
    }

    private void validateRoomExists(Long id) {
        if (meetingRoomMapper.selectById(id) == null) {
            throw exception(MEETING_ROOM_NOT_EXISTS);
        }
    }

    @Override
    public MeetingRoomDO getRoom(Long id) {
        return meetingRoomMapper.selectById(id);
    }

    @Override
    public List<MeetingRoomDO> getRoomList(Collection<Long> ids) {
        return meetingRoomMapper.selectBatchIds(ids);
    }

    @Override
    public PageResult<MeetingRoomDO> getRoomPage(MeetingRoomPageReqVO pageReqVO) {
        return meetingRoomMapper.selectPage(pageReqVO, null); // 这里可以添加查询条件
    }

    @Override
    public MeetingRoomOverviewRespVO getRoomOverview() {
        List<MeetingRoomDO> rooms = meetingRoomMapper.selectList();
        MeetingRoomOverviewRespVO respVO = new MeetingRoomOverviewRespVO();
        LocalDateTime now = LocalDateTime.now();
        respVO.setNow(now);
        respVO.setRoomTotal(rooms.size());
        if (rooms.isEmpty()) {
            respVO.setAvailableRoomCount(0);
            respVO.setBusyRoomCount(0);
            respVO.setTodayMeetingCount(0);
            respVO.setUpcomingMeetingCount(0);
            respVO.setRooms(Collections.emptyList());
            return respVO;
        }

        LocalDateTime dayStart = LocalDate.now().atStartOfDay();
        LocalDateTime dayEnd = dayStart.plusDays(1);
        List<Long> roomIds = rooms.stream().map(MeetingRoomDO::getId).filter(Objects::nonNull).toList();
        List<MeetingDO> meetings = meetingMapper.selectListByRoomIdsAndTimeRange(roomIds, dayStart, dayEnd);
        Map<Long, List<MeetingDO>> roomMeetingMap = meetings.stream()
                .filter(meeting -> meeting.getRoomId() != null)
                .collect(Collectors.groupingBy(MeetingDO::getRoomId));
        Map<Long, String> roomNameMap = rooms.stream()
                .collect(Collectors.toMap(MeetingRoomDO::getId, MeetingRoomDO::getName));

        List<MeetingRoomOverviewItemRespVO> items = rooms.stream()
                .sorted(Comparator.comparing(MeetingRoomDO::getName, Comparator.nullsLast(String::compareTo)))
                .map(room -> {
                    List<MeetingDO> roomMeetings = roomMeetingMap.getOrDefault(room.getId(), Collections.emptyList());
                    MeetingDO currentMeeting = roomMeetings.stream()
                            .filter(meeting -> meeting.getStartTime() != null && meeting.getEndTime() != null)
                            .filter(meeting -> !meeting.getStartTime().isAfter(now) && !meeting.getEndTime().isBefore(now))
                            .filter(meeting -> meeting.getStatus() != null && (meeting.getStatus() == 2 || meeting.getStatus() == 3))
                            .min(Comparator.comparing(MeetingDO::getStartTime))
                            .orElse(null);
                    MeetingDO nextMeeting = roomMeetings.stream()
                            .filter(meeting -> meeting.getStartTime() != null && meeting.getStartTime().isAfter(now))
                            .filter(meeting -> meeting.getStatus() != null && (meeting.getStatus() == 1 || meeting.getStatus() == 2))
                            .min(Comparator.comparing(MeetingDO::getStartTime))
                            .orElse(null);
                    boolean busyNow = currentMeeting != null;
                    MeetingRoomOverviewItemRespVO item = new MeetingRoomOverviewItemRespVO();
                    item.setRoomId(room.getId());
                    item.setRoomName(room.getName());
                    item.setLocation(room.getLocation());
                    item.setCapacity(room.getCapacity());
                    item.setRoomStatus(room.getStatus());
                    item.setBusyNow(busyNow);
                    item.setTodayMeetingCount(roomMeetings.size());
                    if (currentMeeting != null) {
                        item.setCurrentMeetingId(currentMeeting.getId());
                        item.setCurrentMeetingName(currentMeeting.getName());
                        item.setCurrentMeetingStartTime(currentMeeting.getStartTime());
                        item.setCurrentMeetingEndTime(currentMeeting.getEndTime());
                    }
                    if (nextMeeting != null) {
                        item.setNextMeetingId(nextMeeting.getId());
                        item.setNextMeetingName(nextMeeting.getName());
                        item.setNextMeetingStartTime(nextMeeting.getStartTime());
                        item.setNextMeetingEndTime(nextMeeting.getEndTime());
                    }
                    return item;
                })
                .toList();

        respVO.setAvailableRoomCount((int) items.stream()
                .filter(item -> item.getRoomStatus() != null && item.getRoomStatus() == 0)
                .filter(item -> Boolean.FALSE.equals(item.getBusyNow()))
                .count());
        respVO.setBusyRoomCount((int) items.stream()
                .filter(item -> item.getRoomStatus() != null && item.getRoomStatus() == 0)
                .filter(item -> Boolean.TRUE.equals(item.getBusyNow()))
                .count());
        respVO.setTodayMeetingCount(meetings.size());
        respVO.setUpcomingMeetingCount((int) items.stream()
                .filter(item -> item.getNextMeetingId() != null)
                .count());
        respVO.setRooms(items);
        respVO.setTodayMeetings(meetings.stream()
                .sorted(Comparator.comparing(MeetingDO::getStartTime, Comparator.nullsLast(LocalDateTime::compareTo)))
                .map(meeting -> {
                    MeetingRoomTodayMeetingRespVO item = new MeetingRoomTodayMeetingRespVO();
                    item.setMeetingId(meeting.getId());
                    item.setMeetingName(meeting.getName());
                    item.setRoomId(meeting.getRoomId());
                    item.setRoomName(roomNameMap.get(meeting.getRoomId()));
                    item.setStatus(meeting.getStatus());
                    item.setLevel(meeting.getLevel());
                    item.setStartTime(meeting.getStartTime());
                    item.setEndTime(meeting.getEndTime());
                    return item;
                })
                .toList());
        return respVO;
    }

    @Override
    public List<MeetingRoomDO> getRoomList() {
        return meetingRoomMapper.selectList();
    }

}

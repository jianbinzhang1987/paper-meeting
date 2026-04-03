package cn.iocoder.yudao.module.meeting.service.notification;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.notification.vo.MeetingNotificationCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.notification.vo.MeetingNotificationPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.notification.vo.MeetingNotificationReadDetailRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.notification.vo.MeetingNotificationStatsRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.notification.vo.MeetingNotificationUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAttendeeDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.notification.MeetingNoticeReadDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.notification.MeetingNotificationDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.terminal.MeetingTerminalStatusDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.notification.MeetingNoticeReadMapper;
import cn.iocoder.yudao.module.meeting.dal.mysql.notification.MeetingNotificationMapper;
import cn.iocoder.yudao.module.meeting.dal.mysql.terminal.MeetingTerminalStatusMapper;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingAttendeeService;
import cn.iocoder.yudao.module.system.api.user.AdminUserApi;
import cn.iocoder.yudao.module.system.api.user.dto.AdminUserRespDTO;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

import static cn.iocoder.yudao.framework.common.util.collection.CollectionUtils.convertList;
import static cn.iocoder.yudao.framework.common.util.collection.CollectionUtils.convertSet;

@Service
@Validated
public class MeetingNotificationServiceImpl implements MeetingNotificationService {

    private static final long ONLINE_MINUTES = 10;
    private static final long FAILED_MINUTES = 30;

    @Resource
    private MeetingNotificationMapper meetingNotificationMapper;
    @Resource
    private MeetingNoticeReadMapper meetingNoticeReadMapper;
    @Resource
    private MeetingAttendeeService meetingAttendeeService;
    @Resource
    private MeetingTerminalStatusMapper meetingTerminalStatusMapper;
    @Resource
    private AdminUserApi adminUserApi;

    @Override
    public Long create(MeetingNotificationCreateReqVO createReqVO) {
        MeetingNotificationDO notification = BeanUtils.toBean(createReqVO, MeetingNotificationDO.class);
        if (notification.getPublishStatus() == null) {
            notification.setPublishStatus(0);
        }
        meetingNotificationMapper.insert(notification);
        return notification.getId();
    }

    @Override
    public void update(MeetingNotificationUpdateReqVO updateReqVO) {
        meetingNotificationMapper.updateById(BeanUtils.toBean(updateReqVO, MeetingNotificationDO.class));
    }

    @Override
    public void delete(Long id) {
        meetingNotificationMapper.deleteById(id);
    }

    @Override
    public MeetingNotificationDO get(Long id) {
        return meetingNotificationMapper.selectById(id);
    }

    @Override
    public PageResult<MeetingNotificationDO> getPage(MeetingNotificationPageReqVO pageReqVO) {
        return meetingNotificationMapper.selectPage(pageReqVO);
    }

    @Override
    public PageResult<MeetingNotificationStatsRespVO> getPageWithStats(MeetingNotificationPageReqVO pageReqVO) {
        PageResult<MeetingNotificationDO> page = meetingNotificationMapper.selectPage(pageReqVO);
        List<MeetingNotificationDO> notices = page.getList();
        Map<Long, Integer> attendeeCountMap = new HashMap<>();
        for (MeetingNotificationDO notice : notices) {
            attendeeCountMap.computeIfAbsent(notice.getMeetingId(), meetingId -> {
                List<MeetingAttendeeDO> attendees = meetingAttendeeService.getAttendeeListByMeetingId(meetingId);
                return attendees.size();
            });
        }
        Map<Long, Long> readCountMap = new HashMap<>();
        for (MeetingNoticeReadDO read : meetingNoticeReadMapper.selectListByNoticeIds(convertList(notices, MeetingNotificationDO::getId))) {
            Long current = readCountMap.getOrDefault(read.getNoticeId(), 0L);
            readCountMap.put(read.getNoticeId(), current + 1L);
        }
        return new PageResult<>(convertList(notices, notice -> {
            MeetingNotificationStatsRespVO vo = BeanUtils.toBean(notice, MeetingNotificationStatsRespVO.class);
            int attendeeCount = attendeeCountMap.getOrDefault(notice.getMeetingId(), 0);
            int readCount = readCountMap.getOrDefault(notice.getId(), 0L).intValue();
            vo.setAttendeeCount(attendeeCount);
            vo.setReadCount(readCount);
            vo.setUnreadCount(Math.max(attendeeCount - readCount, 0));
            return vo;
        }), page.getTotal());
    }

    @Override
    public MeetingNotificationReadDetailRespVO getReadDetail(Long noticeId) {
        MeetingNotificationDO notice = meetingNotificationMapper.selectById(noticeId);
        if (notice == null) {
            return null;
        }
        List<MeetingAttendeeDO> attendees = meetingAttendeeService.getAttendeeListByMeetingId(notice.getMeetingId());
        List<MeetingNoticeReadDO> readList = meetingNoticeReadMapper.selectListByNoticeIds(List.of(noticeId));
        Map<Long, MeetingNoticeReadDO> readMap = new HashMap<>();
        for (MeetingNoticeReadDO read : readList) {
            readMap.put(read.getUserId(), read);
        }
        Set<Long> userIds = convertSet(attendees, MeetingAttendeeDO::getUserId);
        Map<Long, AdminUserRespDTO> userMap = adminUserApi.getUserMap(userIds);
        List<MeetingNotificationReadDetailRespVO.UserReadItem> readUsers = attendees.stream()
                .filter(item -> readMap.containsKey(item.getUserId()))
                .map(item -> buildReadItem(item, userMap.get(item.getUserId()), readMap.get(item.getUserId())))
                .toList();
        List<MeetingNotificationReadDetailRespVO.UserReadItem> unreadUsers = attendees.stream()
                .filter(item -> !readMap.containsKey(item.getUserId()))
                .map(item -> buildReadItem(item, userMap.get(item.getUserId()), null))
                .toList();
        Map<Long, MeetingTerminalStatusDO> terminalMap = buildTerminalMap(notice.getMeetingId());
        List<MeetingNotificationReadDetailRespVO.TerminalReceiptItem> terminalReceipts = attendees.stream()
            .map(item -> buildTerminalReceipt(item, userMap.get(item.getUserId()), readMap.get(item.getUserId()), terminalMap.get(item.getUserId())))
            .toList();
        MeetingNotificationReadDetailRespVO respVO = new MeetingNotificationReadDetailRespVO();
        respVO.setAttendeeCount(attendees.size());
        respVO.setReadCount(readUsers.size());
        respVO.setUnreadCount(unreadUsers.size());
        respVO.setReadUsers(readUsers);
        respVO.setUnreadUsers(unreadUsers);
        respVO.setTerminalReceipts(terminalReceipts);
        respVO.setDeliveredCount((int) terminalReceipts.stream().filter(item -> "delivered".equals(item.getDeliveryStatus())).count());
        respVO.setFailedCount((int) terminalReceipts.stream().filter(item -> "failed".equals(item.getDeliveryStatus())).count());
        respVO.setPendingCount((int) terminalReceipts.stream().filter(item -> "pending".equals(item.getDeliveryStatus())).count());
        return respVO;
    }

    @Override
    public void publish(Long id) {
        meetingNotificationMapper.updateById(new MeetingNotificationDO()
                .setId(id)
                .setPublishStatus(1)
                .setPublishedTime(LocalDateTime.now()));
    }

    private MeetingNotificationReadDetailRespVO.UserReadItem buildReadItem(MeetingAttendeeDO attendee,
                                                                           AdminUserRespDTO user,
                                                                           MeetingNoticeReadDO read) {
        MeetingNotificationReadDetailRespVO.UserReadItem item = new MeetingNotificationReadDetailRespVO.UserReadItem();
        item.setUserId(attendee.getUserId());
        item.setNickname(user != null ? user.getNickname() : "用户#" + attendee.getUserId());
        item.setRole(attendee.getRole());
        item.setSeatId(attendee.getSeatId());
        item.setReadTime(read != null ? read.getReadTime() : null);
        return item;
    }

    private Map<Long, MeetingTerminalStatusDO> buildTerminalMap(Long meetingId) {
        List<MeetingTerminalStatusDO> terminalStatusList = meetingTerminalStatusMapper.selectListByMeetingId(meetingId, 1);
        Map<Long, MeetingTerminalStatusDO> terminalMap = new HashMap<>();
        for (MeetingTerminalStatusDO terminalStatus : terminalStatusList) {
            if (terminalStatus.getUserId() == null) {
                continue;
            }
            MeetingTerminalStatusDO existed = terminalMap.get(terminalStatus.getUserId());
            if (existed == null || compareHeartbeat(terminalStatus, existed) > 0) {
                terminalMap.put(terminalStatus.getUserId(), terminalStatus);
            }
        }
        return terminalMap;
    }

    private MeetingNotificationReadDetailRespVO.TerminalReceiptItem buildTerminalReceipt(MeetingAttendeeDO attendee,
                                                                                          AdminUserRespDTO user,
                                                                                          MeetingNoticeReadDO read,
                                                                                          MeetingTerminalStatusDO terminalStatus) {
        MeetingNotificationReadDetailRespVO.TerminalReceiptItem item = new MeetingNotificationReadDetailRespVO.TerminalReceiptItem();
        item.setUserId(attendee.getUserId());
        item.setNickname(user != null ? user.getNickname() : "用户#" + attendee.getUserId());
        item.setRole(attendee.getRole());
        item.setSeatId(attendee.getSeatId());
        item.setRead(read != null);
        item.setReadTime(read != null ? read.getReadTime() : null);
        if (terminalStatus == null) {
            item.setOnline(false);
            item.setDeliveryStatus("pending");
            item.setDeliveryStatusText("待送达");
            item.setFailureReason("未发现终端心跳上报");
            return item;
        }
        item.setRoomName(terminalStatus.getRoomName());
        item.setSeatName(terminalStatus.getSeatName());
        item.setDeviceName(terminalStatus.getDeviceName());
        item.setLastHeartbeatTime(terminalStatus.getLastHeartbeatTime());
        boolean online = isOnline(terminalStatus);
        item.setOnline(online);
        String failureReason = buildFailureReason(terminalStatus, online);
        if (failureReason != null) {
            item.setDeliveryStatus("failed");
            item.setDeliveryStatusText("送达失败");
            item.setFailureReason(failureReason);
            return item;
        }
        item.setDeliveryStatus("delivered");
        item.setDeliveryStatusText("已送达");
        item.setFailureReason("-");
        return item;
    }

    private int compareHeartbeat(MeetingTerminalStatusDO left, MeetingTerminalStatusDO right) {
        LocalDateTime leftTime = left.getLastHeartbeatTime();
        LocalDateTime rightTime = right.getLastHeartbeatTime();
        if (Objects.equals(leftTime, rightTime)) {
            return Long.compare(left.getId(), right.getId());
        }
        if (leftTime == null) {
            return -1;
        }
        if (rightTime == null) {
            return 1;
        }
        return leftTime.compareTo(rightTime);
    }

    private boolean isOnline(MeetingTerminalStatusDO terminalStatus) {
        return terminalStatus.getLastHeartbeatTime() != null
                && terminalStatus.getLastHeartbeatTime().isAfter(LocalDateTime.now().minusMinutes(ONLINE_MINUTES));
    }

    private String buildFailureReason(MeetingTerminalStatusDO terminalStatus, boolean online) {
        String connectionStatus = terminalStatus.getConnectionStatus();
        if (connectionStatus != null) {
            String normalized = connectionStatus.toLowerCase();
            if (normalized.contains("fail") || normalized.contains("error") || normalized.contains("disconnect")
                    || normalized.contains("offline") || normalized.contains("abnormal")) {
                return "终端连接状态异常: " + connectionStatus;
            }
        }
        if (!online && terminalStatus.getLastHeartbeatTime() != null
                && terminalStatus.getLastHeartbeatTime().isBefore(LocalDateTime.now().minusMinutes(FAILED_MINUTES))) {
            return "终端超过 " + ONLINE_MINUTES + " 分钟未上报心跳";
        }
        return null;
    }
}

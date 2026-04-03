package cn.iocoder.yudao.module.meeting.websocket;

import cn.iocoder.yudao.framework.common.enums.UserTypeEnum;
import cn.iocoder.yudao.module.infra.api.websocket.WebSocketSenderApi;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAttendeeDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.notification.MeetingNotificationDO;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingAttendeeService;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsControlPayload;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsNoticePayload;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsServicePayload;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsSyncPayload;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsTimerPayload;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsVideoPayload;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsVotePayload;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class MeetingWebSocketSender {

    @Resource
    private WebSocketSenderApi webSocketSenderApi;
    @Resource
    private MeetingAttendeeService meetingAttendeeService;

    public void sendNoticePublished(MeetingNotificationDO notice) {
        MeetingWsNoticePayload payload = new MeetingWsNoticePayload();
        payload.setMeetingId(notice.getMeetingId());
        payload.setNoticeId(notice.getId());
        payload.setTitle("会议通知");
        payload.setContent(notice.getContent());
        payload.setPublishedTime(notice.getPublishedTime());
        sendNoticePublished(payload);
    }

    public void sendNoticePublished(MeetingWsNoticePayload payload) {
        sendToMeetingAttendees(payload.getMeetingId(), MeetingWebSocketMessageType.NOTICE_PUBLISHED, payload);
    }

    public void sendVoteStatus(MeetingVoteDO vote, String messageType) {
        MeetingWsVotePayload payload = new MeetingWsVotePayload();
        payload.setMeetingId(vote.getMeetingId());
        payload.setVoteId(vote.getId());
        payload.setTitle(vote.getTitle());
        payload.setStatus(vote.getStatus());
        sendToMeetingAttendees(vote.getMeetingId(), messageType, payload);
    }

    public void sendForceReturn(Long meetingId) {
        MeetingWsControlPayload payload = new MeetingWsControlPayload();
        payload.setMeetingId(meetingId);
        sendForceReturn(payload);
    }

    public void sendForceReturn(MeetingWsControlPayload payload) {
        sendToMeetingAttendees(payload.getMeetingId(), MeetingWebSocketMessageType.FORCE_RETURN, payload);
    }

    public void sendForceLogout(MeetingWsControlPayload payload) {
        sendToMeetingModerators(payload.getMeetingId(), MeetingWebSocketMessageType.FORCE_LOGOUT, payload);
        sendToMember(payload.getTargetUserId(), MeetingWebSocketMessageType.FORCE_LOGOUT, payload);
    }

    public void sendSyncRequest(MeetingWsSyncPayload payload) {
        sendToMeetingModerators(payload.getMeetingId(), MeetingWebSocketMessageType.SYNC_REQUEST, payload);
        sendToMember(payload.getRequesterUserId(), MeetingWebSocketMessageType.SYNC_REQUEST, payload);
    }

    public void sendSyncStatus(MeetingWsSyncPayload payload, String messageType) {
        sendToMeetingModerators(payload.getMeetingId(), messageType, payload);
        sendToMember(payload.getRequesterUserId(), messageType, payload);
    }

    public void sendSyncStopped(Long meetingId, MeetingWsSyncPayload payload) {
        sendToMeetingAttendees(meetingId, MeetingWebSocketMessageType.SYNC_STOPPED, payload);
    }

    public void sendServiceRequest(MeetingWsServicePayload payload) {
        sendToMeetingModerators(payload.getMeetingId(), MeetingWebSocketMessageType.SERVICE_REQUESTED, payload);
        sendToMember(payload.getRequesterUserId(), MeetingWebSocketMessageType.SERVICE_REQUESTED, payload);
    }

    public void sendServiceStatus(MeetingWsServicePayload payload) {
        sendToMeetingModerators(payload.getMeetingId(), MeetingWebSocketMessageType.SERVICE_UPDATED, payload);
        sendToMember(payload.getRequesterUserId(), MeetingWebSocketMessageType.SERVICE_UPDATED, payload);
    }

    public void sendVideoState(MeetingWsVideoPayload payload, String messageType) {
        sendToMeetingAttendees(payload.getMeetingId(), messageType, payload);
    }

    public void sendTimerState(MeetingWsTimerPayload payload, String messageType) {
        sendToMeetingAttendees(payload.getMeetingId(), messageType, payload);
    }

    private void sendToMeetingAttendees(Long meetingId, String messageType, Object payload) {
        List<MeetingAttendeeDO> attendees = meetingAttendeeService.getAttendeeListByMeetingId(meetingId);
        for (MeetingAttendeeDO attendee : attendees) {
            sendToMember(attendee.getUserId(), messageType, payload);
        }
    }

    private void sendToMeetingModerators(Long meetingId, String messageType, Object payload) {
        webSocketSenderApi.sendObject(UserTypeEnum.ADMIN.getValue(), messageType, payload);
        List<MeetingAttendeeDO> attendees = meetingAttendeeService.getAttendeeListByMeetingId(meetingId);
        attendees.stream()
                .filter(attendee -> attendee.getRole() != null && (attendee.getRole() == 1 || attendee.getRole() == 2))
                .forEach(attendee -> sendToMember(attendee.getUserId(), messageType, payload));
    }

    private void sendToMember(Long userId, String messageType, Object payload) {
        if (userId == null) {
            return;
        }
        webSocketSenderApi.sendObject(UserTypeEnum.MEMBER.getValue(), userId, messageType, payload);
    }
}

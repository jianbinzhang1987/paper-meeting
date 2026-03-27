package cn.iocoder.yudao.module.meeting.websocket.listener;

import cn.iocoder.yudao.framework.websocket.core.listener.WebSocketMessageListener;
import cn.iocoder.yudao.framework.websocket.core.util.WebSocketFrameworkUtils;
import cn.iocoder.yudao.framework.security.core.LoginUser;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAttendeeDO;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingAttendeeService;
import cn.iocoder.yudao.module.meeting.service.realtime.MeetingRealtimeStateService;
import cn.iocoder.yudao.module.meeting.websocket.MeetingWebSocketMessageType;
import cn.iocoder.yudao.module.meeting.websocket.MeetingWebSocketSender;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsSyncPayload;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

import static cn.iocoder.yudao.framework.common.exception.util.ServiceExceptionUtil.exception;
import static cn.iocoder.yudao.module.meeting.enums.ErrorCodeConstants.MEETING_ATTENDEE_NOT_EXISTS;
import static cn.iocoder.yudao.module.meeting.enums.ErrorCodeConstants.MEETING_CONTROL_PERMISSION_DENIED;

@Component
public class MeetingSyncStatusMessageListener implements WebSocketMessageListener<MeetingWsSyncPayload> {

    @Resource
    private MeetingAttendeeService meetingAttendeeService;
    @Resource
    private MeetingRealtimeStateService meetingRealtimeStateService;
    @Resource
    private MeetingWebSocketSender meetingWebSocketSender;

    @Override
    public void onMessage(WebSocketSession session, MeetingWsSyncPayload message) {
        Long userId = WebSocketFrameworkUtils.getLoginUserId(session);
        validateModerator(message.getMeetingId(), userId);
        message.setApproverUserId(userId);
        LoginUser loginUser = WebSocketFrameworkUtils.getLoginUser(session);
        if (loginUser != null && loginUser.getInfo() != null) {
            message.setApproverName(loginUser.getInfo().get(LoginUser.INFO_KEY_NICKNAME));
        }
        MeetingWsSyncPayload payload = meetingRealtimeStateService.updateSyncRequestStatus(message);
        String messageType = resolveType(payload.getStatus());
        if (MeetingWebSocketMessageType.SYNC_STOPPED.equals(messageType)) {
            meetingWebSocketSender.sendSyncStopped(payload.getMeetingId(), payload);
            return;
        }
        meetingWebSocketSender.sendSyncStatus(payload, messageType);
    }

    @Override
    public String getType() {
        return MeetingWebSocketMessageType.CLIENT_SYNC_STATUS_SEND;
    }

    private String resolveType(String status) {
        if ("approved".equalsIgnoreCase(status)) {
            return MeetingWebSocketMessageType.SYNC_APPROVED;
        }
        if ("rejected".equalsIgnoreCase(status)) {
            return MeetingWebSocketMessageType.SYNC_REJECTED;
        }
        return MeetingWebSocketMessageType.SYNC_STOPPED;
    }

    private void validateModerator(Long meetingId, Long userId) {
        MeetingAttendeeDO attendee = meetingAttendeeService.getAttendee(meetingId, userId);
        if (attendee == null) {
            throw exception(MEETING_ATTENDEE_NOT_EXISTS);
        }
        if (attendee.getRole() == null || (attendee.getRole() != 1 && attendee.getRole() != 2)) {
            throw exception(MEETING_CONTROL_PERMISSION_DENIED);
        }
    }
}

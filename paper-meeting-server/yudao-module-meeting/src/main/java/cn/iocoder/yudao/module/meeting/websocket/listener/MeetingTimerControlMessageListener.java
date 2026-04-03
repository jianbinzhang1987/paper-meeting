package cn.iocoder.yudao.module.meeting.websocket.listener;

import cn.iocoder.yudao.framework.security.core.LoginUser;
import cn.iocoder.yudao.framework.websocket.core.listener.WebSocketMessageListener;
import cn.iocoder.yudao.framework.websocket.core.util.WebSocketFrameworkUtils;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAttendeeDO;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingAttendeeService;
import cn.iocoder.yudao.module.meeting.service.realtime.MeetingRealtimeStateService;
import cn.iocoder.yudao.module.meeting.websocket.MeetingWebSocketMessageType;
import cn.iocoder.yudao.module.meeting.websocket.MeetingWebSocketSender;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsTimerPayload;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

import java.time.LocalDateTime;

import static cn.iocoder.yudao.framework.common.exception.util.ServiceExceptionUtil.exception;
import static cn.iocoder.yudao.module.meeting.enums.ErrorCodeConstants.MEETING_ATTENDEE_NOT_EXISTS;
import static cn.iocoder.yudao.module.meeting.enums.ErrorCodeConstants.MEETING_CONTROL_PERMISSION_DENIED;

@Component
public class MeetingTimerControlMessageListener implements WebSocketMessageListener<MeetingWsTimerPayload> {

    @Resource
    private MeetingAttendeeService meetingAttendeeService;
    @Resource
    private MeetingRealtimeStateService meetingRealtimeStateService;
    @Resource
    private MeetingWebSocketSender meetingWebSocketSender;

    @Override
    public void onMessage(WebSocketSession session, MeetingWsTimerPayload message) {
        Long userId = WebSocketFrameworkUtils.getLoginUserId(session);
        validateModerator(message.getMeetingId(), userId);
        message.setOperatorUserId(userId);
        LoginUser loginUser = WebSocketFrameworkUtils.getLoginUser(session);
        if (loginUser != null && loginUser.getInfo() != null) {
            message.setOperatorName(loginUser.getInfo().get(LoginUser.INFO_KEY_NICKNAME));
        }
        message.setSentTime(LocalDateTime.now());
        MeetingWsTimerPayload payload = meetingRealtimeStateService.updateTimerState(message);
        String messageType;
        if (Boolean.TRUE.equals(message.getRunning()) && (message.getRemainingSeconds() != null && message.getRemainingSeconds() > 0)) {
            messageType = MeetingWebSocketMessageType.TIMER_STARTED;
        } else if (Boolean.TRUE.equals(message.getRunning())) {
            messageType = MeetingWebSocketMessageType.TIMER_UPDATED;
        } else {
            messageType = MeetingWebSocketMessageType.TIMER_STOPPED;
        }
        meetingWebSocketSender.sendTimerState(payload, messageType);
    }

    @Override
    public String getType() {
        return MeetingWebSocketMessageType.CLIENT_TIMER_CONTROL_SEND;
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

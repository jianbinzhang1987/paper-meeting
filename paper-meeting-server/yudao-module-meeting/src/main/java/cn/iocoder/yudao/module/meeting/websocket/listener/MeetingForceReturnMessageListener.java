package cn.iocoder.yudao.module.meeting.websocket.listener;

import cn.iocoder.yudao.framework.security.core.LoginUser;
import cn.iocoder.yudao.framework.websocket.core.listener.WebSocketMessageListener;
import cn.iocoder.yudao.framework.websocket.core.util.WebSocketFrameworkUtils;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAttendeeDO;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingAttendeeService;
import cn.iocoder.yudao.module.meeting.websocket.MeetingWebSocketMessageType;
import cn.iocoder.yudao.module.meeting.websocket.MeetingWebSocketSender;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsControlPayload;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

import java.time.LocalDateTime;

import static cn.iocoder.yudao.framework.common.exception.util.ServiceExceptionUtil.exception;
import static cn.iocoder.yudao.module.meeting.enums.ErrorCodeConstants.MEETING_ATTENDEE_NOT_EXISTS;
import static cn.iocoder.yudao.module.meeting.enums.ErrorCodeConstants.MEETING_CONTROL_PERMISSION_DENIED;

@Component
public class MeetingForceReturnMessageListener implements WebSocketMessageListener<MeetingWsControlPayload> {

    @Resource
    private MeetingAttendeeService meetingAttendeeService;
    @Resource
    private MeetingWebSocketSender meetingWebSocketSender;

    @Override
    public void onMessage(WebSocketSession session, MeetingWsControlPayload message) {
        Long userId = WebSocketFrameworkUtils.getLoginUserId(session);
        LoginUser loginUser = WebSocketFrameworkUtils.getLoginUser(session);
        validateModerator(message.getMeetingId(), userId);
        message.setOperatorUserId(userId);
        if (loginUser != null && loginUser.getInfo() != null) {
            message.setOperatorName(loginUser.getInfo().get(LoginUser.INFO_KEY_NICKNAME));
        }
        message.setSentTime(LocalDateTime.now());
        meetingWebSocketSender.sendForceReturn(message);
    }

    @Override
    public String getType() {
        return MeetingWebSocketMessageType.CLIENT_FORCE_RETURN_SEND;
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

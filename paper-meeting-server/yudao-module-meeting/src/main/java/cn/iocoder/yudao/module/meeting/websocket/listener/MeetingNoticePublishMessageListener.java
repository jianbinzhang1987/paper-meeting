package cn.iocoder.yudao.module.meeting.websocket.listener;

import cn.iocoder.yudao.framework.security.core.LoginUser;
import cn.iocoder.yudao.framework.websocket.core.listener.WebSocketMessageListener;
import cn.iocoder.yudao.framework.websocket.core.util.WebSocketFrameworkUtils;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAttendeeDO;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingAttendeeService;
import cn.iocoder.yudao.module.meeting.websocket.MeetingWebSocketMessageType;
import cn.iocoder.yudao.module.meeting.websocket.MeetingWebSocketSender;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsNoticePayload;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

import java.time.LocalDateTime;

import static cn.iocoder.yudao.framework.common.exception.util.ServiceExceptionUtil.exception;
import static cn.iocoder.yudao.module.meeting.enums.ErrorCodeConstants.MEETING_ATTENDEE_NOT_EXISTS;
import static cn.iocoder.yudao.module.meeting.enums.ErrorCodeConstants.MEETING_CONTROL_PERMISSION_DENIED;

@Component
public class MeetingNoticePublishMessageListener implements WebSocketMessageListener<MeetingWsNoticePayload> {

    @Resource
    private MeetingAttendeeService meetingAttendeeService;
    @Resource
    private MeetingWebSocketSender meetingWebSocketSender;

    @Override
    public void onMessage(WebSocketSession session, MeetingWsNoticePayload message) {
        Long userId = WebSocketFrameworkUtils.getLoginUserId(session);
        validateModerator(message.getMeetingId(), userId);
        LoginUser loginUser = WebSocketFrameworkUtils.getLoginUser(session);
        if ((message.getContent() == null || message.getContent().isBlank()) && loginUser != null) {
            String nickname = loginUser.getInfo() != null ? loginUser.getInfo().get(LoginUser.INFO_KEY_NICKNAME) : null;
            message.setContent((nickname != null && !nickname.isBlank() ? nickname : "会议秘书") + " 发起了一条会议广播");
        }
        if (message.getTitle() == null || message.getTitle().isBlank()) {
            message.setTitle("会议广播");
        }
        message.setPublishedTime(LocalDateTime.now());
        meetingWebSocketSender.sendNoticePublished(message);
    }

    @Override
    public String getType() {
        return MeetingWebSocketMessageType.CLIENT_NOTICE_PUBLISH_SEND;
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

package cn.iocoder.yudao.module.meeting.websocket.listener;

import cn.iocoder.yudao.framework.websocket.core.listener.WebSocketMessageListener;
import cn.iocoder.yudao.framework.websocket.core.util.WebSocketFrameworkUtils;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAttendeeDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteDO;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingAttendeeService;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingVoteService;
import cn.iocoder.yudao.module.meeting.websocket.MeetingWebSocketMessageType;
import cn.iocoder.yudao.module.meeting.websocket.MeetingWebSocketSender;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsVotePayload;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

import static cn.iocoder.yudao.framework.common.exception.util.ServiceExceptionUtil.exception;
import static cn.iocoder.yudao.module.meeting.enums.ErrorCodeConstants.MEETING_ATTENDEE_NOT_EXISTS;
import static cn.iocoder.yudao.module.meeting.enums.ErrorCodeConstants.MEETING_CONTROL_PERMISSION_DENIED;

public final class MeetingVoteControlMessageListener {

    private MeetingVoteControlMessageListener() {
    }

    @Component
    public static class StartListener extends AbstractVoteControlListener {
        @Override
        protected Integer targetStatus() {
            return 1;
        }

        @Override
        protected String requestType() {
            return MeetingWebSocketMessageType.CLIENT_VOTE_START_SEND;
        }

        @Override
        protected String broadcastType() {
            return MeetingWebSocketMessageType.VOTE_STARTED;
        }
    }

    @Component
    public static class FinishListener extends AbstractVoteControlListener {
        @Override
        protected Integer targetStatus() {
            return 2;
        }

        @Override
        protected String requestType() {
            return MeetingWebSocketMessageType.CLIENT_VOTE_FINISH_SEND;
        }

        @Override
        protected String broadcastType() {
            return MeetingWebSocketMessageType.VOTE_FINISHED;
        }
    }

    @Component
    public static class PublishListener extends AbstractVoteControlListener {
        @Override
        protected Integer targetStatus() {
            return 2;
        }

        @Override
        protected String requestType() {
            return MeetingWebSocketMessageType.CLIENT_VOTE_PUBLISH_SEND;
        }

        @Override
        protected String broadcastType() {
            return MeetingWebSocketMessageType.VOTE_PUBLISHED;
        }
    }

    public abstract static class AbstractVoteControlListener implements WebSocketMessageListener<MeetingWsVotePayload> {

        @Resource
        private MeetingAttendeeService meetingAttendeeService;
        @Resource
        private MeetingVoteService meetingVoteService;
        @Resource
        private MeetingWebSocketSender meetingWebSocketSender;

        @Override
        public void onMessage(WebSocketSession session, MeetingWsVotePayload message) {
            Long userId = WebSocketFrameworkUtils.getLoginUserId(session);
            validateModerator(message.getMeetingId(), userId);
            meetingVoteService.updateVoteStatus(message.getVoteId(), targetStatus());
            MeetingVoteDO vote = meetingVoteService.getVote(message.getVoteId());
            if (vote != null) {
                meetingWebSocketSender.sendVoteStatus(vote, broadcastType());
            }
        }

        @Override
        public String getType() {
            return requestType();
        }

        protected abstract Integer targetStatus();

        protected abstract String requestType();

        protected abstract String broadcastType();

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
}

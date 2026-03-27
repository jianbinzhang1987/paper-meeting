package cn.iocoder.yudao.module.meeting.websocket.listener;

import cn.iocoder.yudao.framework.websocket.core.listener.WebSocketMessageListener;
import cn.iocoder.yudao.framework.websocket.core.util.WebSocketFrameworkUtils;
import cn.iocoder.yudao.module.meeting.service.realtime.MeetingRealtimeStateService;
import cn.iocoder.yudao.module.meeting.websocket.MeetingWebSocketMessageType;
import cn.iocoder.yudao.module.meeting.websocket.MeetingWebSocketSender;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsServicePayload;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

@Component
public class MeetingServiceRequestMessageListener implements WebSocketMessageListener<MeetingWsServicePayload> {

    @Resource
    private MeetingRealtimeStateService meetingRealtimeStateService;
    @Resource
    private MeetingWebSocketSender meetingWebSocketSender;

    @Override
    public void onMessage(WebSocketSession session, MeetingWsServicePayload message) {
        message.setRequesterUserId(WebSocketFrameworkUtils.getLoginUserId(session));
        MeetingWsServicePayload payload = meetingRealtimeStateService.createServiceRequest(message);
        meetingWebSocketSender.sendServiceRequest(payload);
    }

    @Override
    public String getType() {
        return MeetingWebSocketMessageType.CLIENT_SERVICE_REQUEST_SEND;
    }
}

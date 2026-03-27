package cn.iocoder.yudao.module.meeting.websocket.listener;

import cn.iocoder.yudao.framework.websocket.core.listener.WebSocketMessageListener;
import cn.iocoder.yudao.framework.websocket.core.util.WebSocketFrameworkUtils;
import cn.iocoder.yudao.module.meeting.service.realtime.MeetingRealtimeStateService;
import cn.iocoder.yudao.module.meeting.websocket.MeetingWebSocketMessageType;
import cn.iocoder.yudao.module.meeting.websocket.MeetingWebSocketSender;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsSyncPayload;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

@Component
public class MeetingSyncRequestMessageListener implements WebSocketMessageListener<MeetingWsSyncPayload> {

    @Resource
    private MeetingRealtimeStateService meetingRealtimeStateService;
    @Resource
    private MeetingWebSocketSender meetingWebSocketSender;

    @Override
    public void onMessage(WebSocketSession session, MeetingWsSyncPayload message) {
        message.setRequesterUserId(WebSocketFrameworkUtils.getLoginUserId(session));
        MeetingWsSyncPayload payload = meetingRealtimeStateService.createSyncRequest(message);
        meetingWebSocketSender.sendSyncRequest(payload);
    }

    @Override
    public String getType() {
        return MeetingWebSocketMessageType.CLIENT_SYNC_REQUEST_SEND;
    }
}

package cn.iocoder.yudao.module.meeting.websocket.listener;

import cn.iocoder.yudao.framework.websocket.core.listener.WebSocketMessageListener;
import cn.iocoder.yudao.framework.security.core.LoginUser;
import cn.iocoder.yudao.framework.websocket.core.util.WebSocketFrameworkUtils;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingServiceRequestService;
import cn.iocoder.yudao.module.meeting.websocket.MeetingWebSocketMessageType;
import cn.iocoder.yudao.module.meeting.websocket.MeetingWebSocketSender;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsServicePayload;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

@Component
public class MeetingServiceRequestMessageListener implements WebSocketMessageListener<MeetingWsServicePayload> {

    @Resource
    private MeetingServiceRequestService meetingServiceRequestService;
    @Resource
    private MeetingWebSocketSender meetingWebSocketSender;

    @Override
    public void onMessage(WebSocketSession session, MeetingWsServicePayload message) {
        message.setRequesterUserId(WebSocketFrameworkUtils.getLoginUserId(session));
        LoginUser loginUser = WebSocketFrameworkUtils.getLoginUser(session);
        if (loginUser != null && loginUser.getInfo() != null) {
            message.setRequesterName(loginUser.getInfo().get(LoginUser.INFO_KEY_NICKNAME));
        }
        MeetingWsServicePayload payload = meetingServiceRequestService.saveRequest(message);
        meetingWebSocketSender.sendServiceRequest(payload);
    }

    @Override
    public String getType() {
        return MeetingWebSocketMessageType.CLIENT_SERVICE_REQUEST_SEND;
    }
}

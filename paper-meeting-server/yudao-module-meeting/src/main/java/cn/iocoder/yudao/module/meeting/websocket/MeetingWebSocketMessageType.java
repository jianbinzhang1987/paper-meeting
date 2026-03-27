package cn.iocoder.yudao.module.meeting.websocket;

public interface MeetingWebSocketMessageType {

    String NOTICE_PUBLISHED = "meeting-notice-published";
    String VOTE_STARTED = "meeting-vote-started";
    String VOTE_FINISHED = "meeting-vote-finished";
    String VOTE_PUBLISHED = "meeting-vote-published";
    String FORCE_RETURN = "meeting-force-return";
    String FORCE_LOGOUT = "meeting-force-logout";
    String SYNC_REQUEST = "meeting-sync-request";
    String SYNC_APPROVED = "meeting-sync-approved";
    String SYNC_REJECTED = "meeting-sync-rejected";
    String SYNC_STOPPED = "meeting-sync-stopped";
    String SERVICE_REQUESTED = "meeting-service-requested";
    String SERVICE_UPDATED = "meeting-service-updated";

    String CLIENT_NOTICE_PUBLISH_SEND = "meeting-notice-publish-send";
    String CLIENT_FORCE_RETURN_SEND = "meeting-force-return-send";
    String CLIENT_FORCE_LOGOUT_SEND = "meeting-force-logout-send";
    String CLIENT_VOTE_START_SEND = "meeting-vote-start-send";
    String CLIENT_VOTE_FINISH_SEND = "meeting-vote-finish-send";
    String CLIENT_VOTE_PUBLISH_SEND = "meeting-vote-publish-send";
    String CLIENT_SYNC_REQUEST_SEND = "meeting-sync-request-send";
    String CLIENT_SYNC_STATUS_SEND = "meeting-sync-status-send";
    String CLIENT_SERVICE_REQUEST_SEND = "meeting-service-request-send";
    String CLIENT_SERVICE_STATUS_SEND = "meeting-service-status-send";
}

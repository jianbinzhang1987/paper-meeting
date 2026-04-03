package cn.iocoder.yudao.module.meeting.websocket.vo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class MeetingWsVideoPayload {

    private Long meetingId;
    private String documentId;
    private String documentTitle;
    private String action;
    private Long positionMs;
    private Boolean playing;
    private Long operatorUserId;
    private String operatorName;
    private LocalDateTime sentTime;
}

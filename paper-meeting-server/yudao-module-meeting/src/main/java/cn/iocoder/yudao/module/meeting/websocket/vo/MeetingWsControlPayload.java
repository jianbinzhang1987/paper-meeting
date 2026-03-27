package cn.iocoder.yudao.module.meeting.websocket.vo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class MeetingWsControlPayload {

    private Long meetingId;
    private Long operatorUserId;
    private String operatorName;
    private Long targetUserId;
    private String targetUserName;
    private String title;
    private String content;
    private LocalDateTime sentTime;
}

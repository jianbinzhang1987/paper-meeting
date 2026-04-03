package cn.iocoder.yudao.module.meeting.websocket.vo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class MeetingWsTimerPayload {

    private Long meetingId;
    private Integer totalSeconds;
    private Integer remainingSeconds;
    private Boolean countDown;
    private Boolean running;
    private String speaker;
    private Long operatorUserId;
    private String operatorName;
    private LocalDateTime sentTime;
}

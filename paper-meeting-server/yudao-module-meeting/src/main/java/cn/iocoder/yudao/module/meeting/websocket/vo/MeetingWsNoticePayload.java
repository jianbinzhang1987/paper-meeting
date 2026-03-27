package cn.iocoder.yudao.module.meeting.websocket.vo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class MeetingWsNoticePayload {

    private Long meetingId;
    private Long noticeId;
    private String title;
    private String content;
    private LocalDateTime publishedTime;
}

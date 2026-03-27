package cn.iocoder.yudao.module.meeting.websocket.vo;

import lombok.Data;

@Data
public class MeetingWsVotePayload {

    private Long meetingId;
    private Long voteId;
    private String title;
    private Integer status;
}

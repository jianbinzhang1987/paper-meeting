package cn.iocoder.yudao.module.meeting.websocket.vo;

import lombok.Data;

@Data
public class MeetingWsSyncPayload {

    private Long meetingId;
    private String requestId;
    private Long requesterUserId;
    private String requesterName;
    private String requesterSeatName;
    private String documentId;
    private String documentTitle;
    private Integer page;
    private String status;
    private Long approverUserId;
    private String approverName;
}

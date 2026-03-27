package cn.iocoder.yudao.module.meeting.websocket.vo;

import lombok.Data;

@Data
public class MeetingWsServicePayload {

    private Long meetingId;
    private String requestId;
    private Long requesterUserId;
    private String requesterName;
    private String requesterSeatName;
    private String category;
    private String detail;
    private String status;
    private Long handlerUserId;
    private String handlerName;
}

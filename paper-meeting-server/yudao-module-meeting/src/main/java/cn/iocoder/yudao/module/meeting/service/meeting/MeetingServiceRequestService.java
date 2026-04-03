package cn.iocoder.yudao.module.meeting.service.meeting;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingServiceRequestPageReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingServiceRequestDO;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsServicePayload;

public interface MeetingServiceRequestService {

    MeetingWsServicePayload saveRequest(MeetingWsServicePayload payload);

    MeetingWsServicePayload updateStatus(MeetingWsServicePayload payload);

    PageResult<MeetingServiceRequestDO> getRequestPage(AppMeetingServiceRequestPageReqVO reqVO);

    java.util.List<MeetingServiceRequestDO> getRecentList(Long meetingId, Integer limit);
}

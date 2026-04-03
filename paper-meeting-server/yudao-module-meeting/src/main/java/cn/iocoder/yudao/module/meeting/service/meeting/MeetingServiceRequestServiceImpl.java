package cn.iocoder.yudao.module.meeting.service.meeting;

import cn.hutool.core.util.IdUtil;
import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingServiceRequestPageReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingServiceRequestDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingServiceRequestMapper;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsServicePayload;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

import java.time.LocalDateTime;

@Service
@Validated
public class MeetingServiceRequestServiceImpl implements MeetingServiceRequestService {

    @Resource
    private MeetingServiceRequestMapper meetingServiceRequestMapper;

    @Override
    public MeetingWsServicePayload saveRequest(MeetingWsServicePayload payload) {
        if (payload.getRequestId() == null || payload.getRequestId().isBlank()) {
            payload.setRequestId(IdUtil.fastSimpleUUID());
        }
        if (payload.getStatus() == null || payload.getStatus().isBlank()) {
            payload.setStatus("pending");
        }
        MeetingServiceRequestDO request = meetingServiceRequestMapper.selectByRequestId(payload.getRequestId());
        if (request == null) {
            request = new MeetingServiceRequestDO();
            request.setRequestId(payload.getRequestId());
        }
        applyPayload(request, payload);
        if (request.getId() == null) {
            meetingServiceRequestMapper.insert(request);
        } else {
            meetingServiceRequestMapper.updateById(request);
        }
        return toPayload(request);
    }

    @Override
    public MeetingWsServicePayload updateStatus(MeetingWsServicePayload payload) {
        if (payload.getRequestId() == null || payload.getRequestId().isBlank()) {
            payload.setRequestId(IdUtil.fastSimpleUUID());
        }
        MeetingServiceRequestDO request = meetingServiceRequestMapper.selectByRequestId(payload.getRequestId());
        if (request == null) {
            request = new MeetingServiceRequestDO();
            request.setRequestId(payload.getRequestId());
        }
        applyPayload(request, payload);
        if ("accepted".equalsIgnoreCase(request.getStatus()) || "processing".equalsIgnoreCase(request.getStatus())) {
            request.setAcceptedAt(request.getAcceptedAt() != null ? request.getAcceptedAt() : LocalDateTime.now());
        }
        if ("completed".equalsIgnoreCase(request.getStatus())) {
            request.setCompletedAt(LocalDateTime.now());
        }
        if ("canceled".equalsIgnoreCase(request.getStatus())) {
            request.setCanceledAt(LocalDateTime.now());
        }
        if (request.getId() == null) {
            meetingServiceRequestMapper.insert(request);
        } else {
            meetingServiceRequestMapper.updateById(request);
        }
        return toPayload(request);
    }

    @Override
    public PageResult<MeetingServiceRequestDO> getRequestPage(AppMeetingServiceRequestPageReqVO reqVO) {
        return meetingServiceRequestMapper.selectPage(reqVO);
    }

    @Override
    public java.util.List<MeetingServiceRequestDO> getRecentList(Long meetingId, Integer limit) {
        return meetingServiceRequestMapper.selectRecentList(meetingId, limit);
    }

    private void applyPayload(MeetingServiceRequestDO request, MeetingWsServicePayload payload) {
        request.setMeetingId(payload.getMeetingId());
        request.setRequesterUserId(payload.getRequesterUserId());
        request.setRequesterName(payload.getRequesterName());
        request.setRequesterSeatName(payload.getRequesterSeatName());
        request.setCategory(payload.getCategory());
        request.setDetail(payload.getDetail());
        request.setStatus(payload.getStatus());
        request.setHandlerUserId(payload.getHandlerUserId());
        request.setHandlerName(payload.getHandlerName());
        request.setResultRemark(payload.getResultRemark());
    }

    private MeetingWsServicePayload toPayload(MeetingServiceRequestDO request) {
        MeetingWsServicePayload payload = new MeetingWsServicePayload();
        payload.setMeetingId(request.getMeetingId());
        payload.setRequestId(request.getRequestId());
        payload.setRequesterUserId(request.getRequesterUserId());
        payload.setRequesterName(request.getRequesterName());
        payload.setRequesterSeatName(request.getRequesterSeatName());
        payload.setCategory(request.getCategory());
        payload.setDetail(request.getDetail());
        payload.setStatus(request.getStatus());
        payload.setHandlerUserId(request.getHandlerUserId());
        payload.setHandlerName(request.getHandlerName());
        payload.setAcceptedAt(request.getAcceptedAt());
        payload.setCompletedAt(request.getCompletedAt());
        payload.setCanceledAt(request.getCanceledAt());
        payload.setResultRemark(request.getResultRemark());
        return payload;
    }
}

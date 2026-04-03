package cn.iocoder.yudao.module.meeting.service.realtime;

import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsServicePayload;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsSyncPayload;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsTimerPayload;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsVideoPayload;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

@Service
public class MeetingRealtimeStateService {

    private final ConcurrentMap<Long, Map<String, MeetingWsSyncPayload>> syncRequests = new ConcurrentHashMap<>();
    private final ConcurrentMap<Long, Map<String, MeetingWsServicePayload>> serviceRequests = new ConcurrentHashMap<>();
    private final ConcurrentMap<Long, MeetingWsVideoPayload> videoStates = new ConcurrentHashMap<>();
    private final ConcurrentMap<Long, MeetingWsTimerPayload> timerStates = new ConcurrentHashMap<>();

    public MeetingWsSyncPayload createSyncRequest(MeetingWsSyncPayload payload) {
        payload.setRequestId(defaultRequestId(payload.getRequestId()));
        payload.setStatus(defaultStatus(payload.getStatus(), "pending"));
        syncRequests.computeIfAbsent(payload.getMeetingId(), key -> new ConcurrentHashMap<>())
                .put(payload.getRequestId(), payload);
        return payload;
    }

    public MeetingWsSyncPayload updateSyncRequestStatus(MeetingWsSyncPayload payload) {
        payload.setRequestId(defaultRequestId(payload.getRequestId()));
        syncRequests.computeIfAbsent(payload.getMeetingId(), key -> new ConcurrentHashMap<>())
                .put(payload.getRequestId(), payload);
        return payload;
    }

    public List<MeetingWsSyncPayload> getSyncRequests(Long meetingId) {
        return sortByRequestId(syncRequests.getOrDefault(meetingId, Collections.emptyMap()));
    }

    public MeetingWsServicePayload createServiceRequest(MeetingWsServicePayload payload) {
        payload.setRequestId(defaultRequestId(payload.getRequestId()));
        payload.setStatus(defaultStatus(payload.getStatus(), "pending"));
        serviceRequests.computeIfAbsent(payload.getMeetingId(), key -> new ConcurrentHashMap<>())
                .put(payload.getRequestId(), payload);
        return payload;
    }

    public MeetingWsServicePayload updateServiceStatus(MeetingWsServicePayload payload) {
        payload.setRequestId(defaultRequestId(payload.getRequestId()));
        serviceRequests.computeIfAbsent(payload.getMeetingId(), key -> new ConcurrentHashMap<>())
                .put(payload.getRequestId(), payload);
        return payload;
    }

    public List<MeetingWsServicePayload> getServiceRequests(Long meetingId) {
        return sortByRequestId(serviceRequests.getOrDefault(meetingId, Collections.emptyMap()));
    }

    public MeetingWsVideoPayload updateVideoState(MeetingWsVideoPayload payload) {
        videoStates.put(payload.getMeetingId(), payload);
        return payload;
    }

    public MeetingWsVideoPayload getVideoState(Long meetingId) {
        return videoStates.get(meetingId);
    }

    public MeetingWsTimerPayload updateTimerState(MeetingWsTimerPayload payload) {
        timerStates.put(payload.getMeetingId(), payload);
        return payload;
    }

    public MeetingWsTimerPayload getTimerState(Long meetingId) {
        return timerStates.get(meetingId);
    }

    private String defaultRequestId(String requestId) {
        return requestId != null && !requestId.isBlank() ? requestId : UUID.randomUUID().toString();
    }

    private String defaultStatus(String currentStatus, String fallbackStatus) {
        return currentStatus != null && !currentStatus.isBlank() ? currentStatus : fallbackStatus;
    }

    private <T> List<T> sortByRequestId(Map<String, T> source) {
        List<Map.Entry<String, T>> entries = new ArrayList<>(source.entrySet());
        entries.sort(Comparator.comparing(Map.Entry<String, T>::getKey).reversed());
        return entries.stream().map(Map.Entry::getValue).toList();
    }
}

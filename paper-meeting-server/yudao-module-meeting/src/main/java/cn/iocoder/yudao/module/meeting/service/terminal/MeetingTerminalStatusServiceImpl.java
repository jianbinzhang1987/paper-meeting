package cn.iocoder.yudao.module.meeting.service.terminal;

import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.terminal.vo.MeetingTerminalDispatchRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.terminal.vo.MeetingTerminalStatusQueryReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.terminal.vo.MeetingTerminalStatusRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.terminal.vo.MeetingTerminalStatusSummaryRespVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingTerminalHeartbeatReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.terminal.MeetingTerminalStatusDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.terminal.MeetingTerminalStatusMapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;

@Service
@Validated
public class MeetingTerminalStatusServiceImpl implements MeetingTerminalStatusService {

    private static final long ONLINE_MINUTES = 10;

    @Resource
    private MeetingTerminalStatusMapper meetingTerminalStatusMapper;

    @Override
    public void report(AppMeetingTerminalHeartbeatReqVO reqVO) {
        LocalDateTime now = LocalDateTime.now();
        MeetingTerminalStatusDO data = meetingTerminalStatusMapper.selectByTerminal(
                reqVO.getRoomName(), reqVO.getSeatName(), reqVO.getDeviceName());
        if (data == null) {
            data = new MeetingTerminalStatusDO();
            data.setRoomName(reqVO.getRoomName());
            data.setSeatName(reqVO.getSeatName());
            data.setDeviceName(reqVO.getDeviceName());
            data.setLastBootstrapTime(now);
        }
        data.setClientType(reqVO.getClientType());
        data.setMeetingId(reqVO.getMeetingId());
        data.setMeetingName(reqVO.getMeetingName());
        data.setUserId(reqVO.getUserId());
        data.setUserName(reqVO.getUserName());
        data.setThemeMode(reqVO.getThemeMode());
        data.setConnectionStatus(reqVO.getConnectionStatus());
        data.setAppVersionId(reqVO.getAppVersionId());
        data.setAppVersionName(reqVO.getAppVersionName());
        data.setAppVersionCode(reqVO.getAppVersionCode());
        data.setUiConfigId(reqVO.getUiConfigId());
        data.setUiConfigName(reqVO.getUiConfigName());
        data.setBrandingId(reqVO.getBrandingId());
        data.setBrandingName(reqVO.getBrandingName());
        data.setLastHeartbeatTime(now);
        if (data.getId() == null) {
            meetingTerminalStatusMapper.insert(data);
            return;
        }
        meetingTerminalStatusMapper.updateById(data);
    }

    @Override
    public List<MeetingTerminalStatusRespVO> getTerminalStatusList(MeetingTerminalStatusQueryReqVO reqVO) {
        return meetingTerminalStatusMapper.selectList(reqVO.getClientType()).stream()
                .map(item -> {
                    MeetingTerminalStatusRespVO respVO = BeanUtils.toBean(item, MeetingTerminalStatusRespVO.class);
                    respVO.setOnline(isOnline(item));
                    respVO.setMatchSelected(matchSelected(item, reqVO));
                    return respVO;
                })
                .toList();
    }

    @Override
    public MeetingTerminalStatusSummaryRespVO getTerminalStatusSummary(MeetingTerminalStatusQueryReqVO reqVO) {
        List<MeetingTerminalStatusDO> list = meetingTerminalStatusMapper.selectList(reqVO.getClientType());
        MeetingTerminalStatusSummaryRespVO respVO = new MeetingTerminalStatusSummaryRespVO();
        respVO.setTotalCount(list.size());
        respVO.setOnlineCount((int) list.stream().filter(this::isOnline).count());
        respVO.setMatchedCount((int) list.stream().filter(item -> matchSelected(item, reqVO)).count());
        respVO.setPendingCount(Math.max(respVO.getTotalCount() - respVO.getMatchedCount(), 0));
        respVO.setLatestHeartbeatTime(list.stream()
                .map(MeetingTerminalStatusDO::getLastHeartbeatTime)
                .filter(value -> value != null)
                .max(Comparator.naturalOrder())
                .orElse(null));
        return respVO;
    }

    @Override
    public MeetingTerminalDispatchRespVO dispatchAppVersion(Long appVersionId, Integer clientType, boolean onlyPending) {
        List<MeetingTerminalStatusDO> terminalList = meetingTerminalStatusMapper.selectList(clientType);
        return buildDispatchResult("app-version", appVersionId, onlyPending, terminalList, item -> appVersionId != null && appVersionId.equals(item.getAppVersionId()));
    }

    @Override
    public MeetingTerminalDispatchRespVO dispatchUiConfig(Long uiConfigId, Integer clientType, boolean onlyPending) {
        List<MeetingTerminalStatusDO> terminalList = meetingTerminalStatusMapper.selectList(clientType);
        return buildDispatchResult("ui-config", uiConfigId, onlyPending, terminalList, item -> uiConfigId != null && uiConfigId.equals(item.getUiConfigId()));
    }

    private boolean isOnline(MeetingTerminalStatusDO item) {
        return item.getLastHeartbeatTime() != null
                && item.getLastHeartbeatTime().isAfter(LocalDateTime.now().minusMinutes(ONLINE_MINUTES));
    }

    private boolean matchSelected(MeetingTerminalStatusDO item, MeetingTerminalStatusQueryReqVO reqVO) {
        if (reqVO.getAppVersionId() != null) {
            return reqVO.getAppVersionId().equals(item.getAppVersionId());
        }
        if (reqVO.getUiConfigId() != null) {
            return reqVO.getUiConfigId().equals(item.getUiConfigId());
        }
        return true;
    }

    private MeetingTerminalDispatchRespVO buildDispatchResult(String targetType, Long targetId,
                                                              boolean onlyPending,
                                                              List<MeetingTerminalStatusDO> terminalList,
                                                              java.util.function.Predicate<MeetingTerminalStatusDO> matcher) {
        MeetingTerminalDispatchRespVO respVO = new MeetingTerminalDispatchRespVO();
        respVO.setTargetType(targetType);
        respVO.setTargetId(targetId);

        List<MeetingTerminalDispatchRespVO.Item> items = terminalList.stream()
                .filter(item -> !onlyPending || !matcher.test(item))
                .map(item -> toDispatchItem(item, matcher.test(item), targetType))
                .toList();
        respVO.setItems(items);
        respVO.setTotalCount(items.size());
        respVO.setDispatchedCount((int) items.stream().filter(item -> "dispatched".equals(item.getDeliveryStatus())).count());
        respVO.setFailedCount((int) items.stream().filter(item -> "failed".equals(item.getDeliveryStatus())).count());
        respVO.setMatchedCount((int) items.stream().filter(MeetingTerminalDispatchRespVO.Item::getMatched).count());
        return respVO;
    }

    private MeetingTerminalDispatchRespVO.Item toDispatchItem(MeetingTerminalStatusDO terminal,
                                                              boolean matched,
                                                              String targetType) {
        MeetingTerminalDispatchRespVO.Item item = new MeetingTerminalDispatchRespVO.Item();
        item.setTerminalId(terminal.getId());
        item.setClientType(terminal.getClientType());
        item.setRoomName(terminal.getRoomName());
        item.setSeatName(terminal.getSeatName());
        item.setDeviceName(terminal.getDeviceName());
        item.setMatched(matched);
        boolean online = isOnline(terminal);
        item.setOnline(online);
        item.setLastHeartbeatTime(terminal.getLastHeartbeatTime());
        item.setCurrentValue("app-version".equals(targetType)
                ? String.format("%s / %s",
                terminal.getAppVersionName() == null ? "-" : terminal.getAppVersionName(),
                terminal.getAppVersionCode() == null ? "-" : String.valueOf(terminal.getAppVersionCode()))
                : (terminal.getUiConfigName() == null ? "-" : terminal.getUiConfigName()));

        if (matched) {
            item.setDeliveryStatus("matched");
            item.setDeliveryStatusText("已命中");
            item.setFailureReason(null);
            return item;
        }
        String connectionStatus = terminal.getConnectionStatus() == null ? "" : terminal.getConnectionStatus().toLowerCase(Locale.ROOT);
        boolean abnormal = connectionStatus.contains("fail") || connectionStatus.contains("error")
                || connectionStatus.contains("offline") || connectionStatus.contains("disconnect")
                || connectionStatus.contains("abnormal");
        if (!online) {
            item.setDeliveryStatus("failed");
            item.setDeliveryStatusText("下发失败");
            item.setFailureReason("终端离线，未能下发指令");
            return item;
        }
        if (abnormal) {
            item.setDeliveryStatus("failed");
            item.setDeliveryStatusText("下发失败");
            item.setFailureReason("终端连接异常(" + terminal.getConnectionStatus() + ")");
            return item;
        }
        item.setDeliveryStatus("dispatched");
        item.setDeliveryStatusText("已下发");
        item.setFailureReason("已下发检查指令，待终端心跳回执");
        return item;
    }
}

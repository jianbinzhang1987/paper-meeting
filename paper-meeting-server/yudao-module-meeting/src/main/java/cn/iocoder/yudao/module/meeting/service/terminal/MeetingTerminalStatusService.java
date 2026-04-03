package cn.iocoder.yudao.module.meeting.service.terminal;

import cn.iocoder.yudao.module.meeting.controller.admin.terminal.vo.MeetingTerminalStatusQueryReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.terminal.vo.MeetingTerminalDispatchRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.terminal.vo.MeetingTerminalStatusRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.terminal.vo.MeetingTerminalStatusSummaryRespVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingTerminalHeartbeatReqVO;

import java.util.List;

public interface MeetingTerminalStatusService {

    void report(AppMeetingTerminalHeartbeatReqVO reqVO);

    List<MeetingTerminalStatusRespVO> getTerminalStatusList(MeetingTerminalStatusQueryReqVO reqVO);

    MeetingTerminalStatusSummaryRespVO getTerminalStatusSummary(MeetingTerminalStatusQueryReqVO reqVO);

    MeetingTerminalDispatchRespVO dispatchAppVersion(Long appVersionId, Integer clientType, boolean onlyPending);

    MeetingTerminalDispatchRespVO dispatchUiConfig(Long uiConfigId, Integer clientType, boolean onlyPending);
}

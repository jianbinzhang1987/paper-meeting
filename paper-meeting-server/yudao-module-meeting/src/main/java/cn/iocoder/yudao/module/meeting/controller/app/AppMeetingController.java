package cn.iocoder.yudao.module.meeting.controller.app;

import cn.iocoder.yudao.framework.common.biz.system.oauth2.OAuth2TokenCommonApi;
import cn.iocoder.yudao.framework.common.biz.system.oauth2.dto.OAuth2AccessTokenCreateReqDTO;
import cn.iocoder.yudao.framework.common.biz.system.oauth2.dto.OAuth2AccessTokenRespDTO;
import cn.iocoder.yudao.framework.common.enums.UserTypeEnum;
import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.notification.vo.MeetingNotificationPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingBootstrapReqVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingBootstrapRespVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingDocumentMarkDeleteReqVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingDocumentMarkRespVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingDocumentMarkSaveReqVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingNoticePageReqVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingNoticeReadReqVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingNoticeRespVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingRealtimeStateRespVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingServiceRequestPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingServiceRequestRespVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingSignatureRespVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingSignatureSubmitReqVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingSignInReqVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingSignInRespVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingTerminalHeartbeatReqVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingVoteSubmitReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.appversion.MeetingAppVersionDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.branding.MeetingBrandingDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAgendaDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAttendeeDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingDocumentMarkDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingFileDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingServiceRequestDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingSignatureDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteRecordDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.notification.MeetingNotificationDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.notification.MeetingNoticeReadDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.room.MeetingRoomDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.uiconfig.MeetingUiConfigDO;
import cn.iocoder.yudao.module.meeting.service.appversion.MeetingAppVersionService;
import cn.iocoder.yudao.module.meeting.service.branding.MeetingBrandingService;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingAgendaService;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingAttendeeService;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingDocumentMarkService;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingFileService;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingService;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingServiceRequestService;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingSignatureService;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingVoteService;
import cn.iocoder.yudao.module.meeting.service.notification.MeetingNoticeReadService;
import cn.iocoder.yudao.module.meeting.service.notification.MeetingNotificationService;
import cn.iocoder.yudao.module.meeting.service.realtime.MeetingRealtimeStateService;
import cn.iocoder.yudao.module.meeting.service.room.MeetingRoomService;
import cn.iocoder.yudao.module.meeting.service.terminal.MeetingTerminalStatusService;
import cn.iocoder.yudao.module.meeting.service.uiconfig.MeetingUiConfigService;
import cn.iocoder.yudao.module.system.api.user.AdminUserApi;
import cn.iocoder.yudao.module.system.api.user.dto.AdminUserRespDTO;
import cn.iocoder.yudao.module.system.dal.dataobject.user.AdminUserDO;
import cn.iocoder.yudao.module.system.enums.oauth2.OAuth2ClientConstants;
import cn.iocoder.yudao.module.system.service.user.AdminUserService;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsTimerPayload;
import cn.iocoder.yudao.module.meeting.websocket.vo.MeetingWsVideoPayload;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.Base64;

import static cn.iocoder.yudao.framework.common.exception.util.ServiceExceptionUtil.exception;
import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;
import static cn.iocoder.yudao.framework.common.util.collection.CollectionUtils.convertList;
import static cn.iocoder.yudao.framework.common.util.collection.CollectionUtils.convertSet;
import static cn.iocoder.yudao.module.meeting.enums.ErrorCodeConstants.MEETING_ATTENDEE_NOT_EXISTS;
import static cn.iocoder.yudao.module.meeting.enums.ErrorCodeConstants.MEETING_NOT_EXISTS;
import static cn.iocoder.yudao.module.meeting.enums.ErrorCodeConstants.MEETING_PASSWORD_INVALID;
import static cn.iocoder.yudao.module.meeting.enums.ErrorCodeConstants.MEETING_ROOM_NOT_EXISTS;

@Tag(name = "客户端 - 会议")
@RestController
@RequestMapping("/meeting/app")
@Validated
public class AppMeetingController {

    @Resource
    private MeetingRoomService meetingRoomService;
    @Resource
    private MeetingService meetingService;
    @Resource
    private MeetingAttendeeService meetingAttendeeService;
    @Resource
    private MeetingAgendaService meetingAgendaService;
    @Resource
    private MeetingFileService meetingFileService;
    @Resource
    private MeetingDocumentMarkService meetingDocumentMarkService;
    @Resource
    private MeetingServiceRequestService meetingServiceRequestService;
    @Resource
    private MeetingVoteService meetingVoteService;
    @Resource
    private MeetingSignatureService meetingSignatureService;
    @Resource
    private MeetingNotificationService meetingNotificationService;
    @Resource
    private MeetingNoticeReadService meetingNoticeReadService;
    @Resource
    private MeetingAppVersionService meetingAppVersionService;
    @Resource
    private MeetingUiConfigService meetingUiConfigService;
    @Resource
    private MeetingBrandingService meetingBrandingService;
    @Resource
    private MeetingTerminalStatusService meetingTerminalStatusService;
    @Resource
    private AdminUserApi adminUserApi;
    @Resource
    private AdminUserService adminUserService;
    @Resource
    private OAuth2TokenCommonApi oauth2TokenApi;
    @Resource
    private MeetingRealtimeStateService meetingRealtimeStateService;

    @GetMapping("/bootstrap")
    @Operation(summary = "客户端启动初始化")
    public CommonResult<AppMeetingBootstrapRespVO> bootstrap(@Valid AppMeetingBootstrapReqVO reqVO) {
        MeetingRoomDO room = meetingRoomService.getRoomList().stream()
                .filter(item -> Objects.equals(item.getName(), reqVO.getRoomName()))
                .findFirst()
                .orElseThrow(() -> exception(MEETING_ROOM_NOT_EXISTS));
        MeetingDO meeting = meetingService.getCurrentMeetingByRoomId(room.getId());
        if (meeting == null) {
            return success(null);
        }

        List<MeetingAttendeeDO> attendeeList = meetingAttendeeService.getAttendeeListByMeetingId(meeting.getId());
        Map<Long, AdminUserRespDTO> userMap = adminUserApi.getUserMap(convertList(attendeeList, MeetingAttendeeDO::getUserId));
        List<MeetingAgendaDO> agendaList = meetingAgendaService.getAgendaListByMeetingId(meeting.getId());
        List<MeetingFileDO> fileList = meetingFileService.getFileListByMeetingId(meeting.getId());
        List<MeetingVoteRespVO> voteList = meetingVoteService.getVoteListByMeetingId(meeting.getId());
        List<MeetingNotificationDO> notificationList = getPublishedNotifications(meeting.getId());
        MeetingAppVersionDO activeAppVersion = meetingAppVersionService.getActive(1);
        MeetingUiConfigDO activeUiConfig = meetingUiConfigService.getActive();
        MeetingBrandingDO activeBranding = meetingBrandingService.getActive();

        AppMeetingBootstrapRespVO respVO = new AppMeetingBootstrapRespVO();
        respVO.setMeetingId(meeting.getId());
        respVO.setMeetingName(meeting.getName());
        respVO.setDescription(meeting.getDescription());
        respVO.setRoomName(room.getName());
        respVO.setDeviceName(reqVO.getDeviceName());
        respVO.setSeatName(reqVO.getSeatName());
        respVO.setControlType(meeting.getControlType());
        respVO.setWatermark(meeting.getWatermark());
        respVO.setMeetingPasswordRequired(meeting.getPassword() != null && !meeting.getPassword().isBlank());
        respVO.setStartTime(meeting.getStartTime());
        respVO.setEndTime(meeting.getEndTime());
        respVO.setAttendees(convertList(attendeeList, attendee -> {
            AppMeetingBootstrapRespVO.Attendee vo = new AppMeetingBootstrapRespVO.Attendee();
            AdminUserRespDTO user = userMap.get(attendee.getUserId());
            vo.setAttendeeId(attendee.getId());
            vo.setUserId(attendee.getUserId());
            vo.setName(user != null ? user.getNickname() : "用户#" + attendee.getUserId());
            vo.setRole(attendee.getRole());
            vo.setRoleName(resolveRoleName(attendee.getRole()));
            vo.setSignStatus(attendee.getStatus());
            vo.setSeatId(attendee.getSeatId());
            vo.setPersonalPasswordRequired(isUserPasswordRequired(attendee.getUserId()));
            return vo;
        }));
        respVO.setAgendas(convertList(agendaList, agenda -> {
            AppMeetingBootstrapRespVO.Agenda vo = BeanUtils.toBean(agenda, AppMeetingBootstrapRespVO.Agenda.class);
            vo.setVote(agenda.getIsVote());
            return vo;
        }));
        respVO.setDocuments(convertList(fileList, file -> BeanUtils.toBean(file, AppMeetingBootstrapRespVO.Document.class)));
        respVO.setVotes(convertList(voteList, vote -> {
            return buildAppVote(vote, null);
        }));
        respVO.setNotices(convertList(notificationList, notice -> BeanUtils.toBean(notice, AppMeetingBootstrapRespVO.Notice.class)));
        respVO.setSyncRequests(convertList(meetingRealtimeStateService.getSyncRequests(meeting.getId()),
                item -> BeanUtils.toBean(item, AppMeetingBootstrapRespVO.SyncRequest.class)));
        respVO.setServiceRequests(convertList(meetingServiceRequestService.getRecentList(meeting.getId(), 50),
                this::buildAppServiceRequest));
        if (activeAppVersion != null) {
            respVO.setActiveAppVersion(BeanUtils.toBean(activeAppVersion, AppMeetingBootstrapRespVO.ActiveAppVersion.class));
        }
        if (activeUiConfig != null) {
            respVO.setActiveUiConfig(BeanUtils.toBean(activeUiConfig, AppMeetingBootstrapRespVO.ActiveUiConfig.class));
        }
        if (activeBranding != null) {
            respVO.setActiveBranding(BeanUtils.toBean(activeBranding, AppMeetingBootstrapRespVO.ActiveBranding.class));
        }
        return success(respVO);
    }

    @PostMapping("/terminal-heartbeat")
    @Operation(summary = "客户端终端状态心跳")
    public CommonResult<Boolean> reportTerminalHeartbeat(@Valid @RequestBody AppMeetingTerminalHeartbeatReqVO reqVO) {
        meetingTerminalStatusService.report(reqVO);
        return success(true);
    }

    @PostMapping("/sign-in")
    @Operation(summary = "客户端签到")
    public CommonResult<AppMeetingSignInRespVO> signIn(@Valid @RequestBody AppMeetingSignInReqVO reqVO) {
        MeetingDO meeting = meetingService.getMeeting(reqVO.getMeetingId());
        if (meeting == null) {
            throw exception(MEETING_NOT_EXISTS);
        }
        if (meeting.getPassword() != null && !meeting.getPassword().isBlank()
                && !Objects.equals(meeting.getPassword(), resolveMeetingPassword(reqVO))) {
            throw exception(MEETING_PASSWORD_INVALID);
        }
        List<MeetingAttendeeDO> attendeeList = meetingAttendeeService.getAttendeeListByMeetingId(reqVO.getMeetingId());
        MeetingAttendeeDO attendee = attendeeList.stream()
                .filter(item -> Objects.equals(item.getUserId(), reqVO.getUserId()))
                .findFirst()
                .orElseThrow(() -> exception(MEETING_ATTENDEE_NOT_EXISTS));
        validateUserPassword(reqVO.getUserId(), reqVO.getUserPassword(), isUserPasswordRequired(reqVO.getUserId()));
        meetingAttendeeService.signIn(reqVO.getMeetingId(), reqVO.getUserId());
        List<MeetingAttendeeDO> refreshedList = meetingAttendeeService.getAttendeeListByMeetingId(reqVO.getMeetingId());
        MeetingAttendeeDO refreshed = refreshedList.stream()
                .filter(item -> Objects.equals(item.getUserId(), reqVO.getUserId()))
                .findFirst()
                .orElse(attendee);
        AdminUserRespDTO user = adminUserApi.getUser(reqVO.getUserId());

        AppMeetingSignInRespVO respVO = new AppMeetingSignInRespVO();
        respVO.setMeetingId(reqVO.getMeetingId());
        respVO.setUserId(reqVO.getUserId());
        respVO.setNickname(user != null ? user.getNickname() : "用户#" + reqVO.getUserId());
        respVO.setRole(refreshed.getRole());
        respVO.setRoleName(resolveRoleName(refreshed.getRole()));
        respVO.setSeatId(refreshed.getSeatId());
        respVO.setSignStatus(refreshed.getStatus());
        respVO.setSignInTime(refreshed.getSignInTime());
        OAuth2AccessTokenRespDTO accessToken = createRealtimeAccessToken(reqVO.getUserId());
        respVO.setAccessToken(accessToken.getAccessToken());
        respVO.setAccessTokenExpiresTime(accessToken.getExpiresTime());
        respVO.setWebsocketPath("/infra/ws");
        return success(respVO);
    }

    @GetMapping("/documents")
    @Operation(summary = "客户端获取会议资料")
    public CommonResult<List<AppMeetingBootstrapRespVO.Document>> getDocuments(@RequestParam("meetingId") Long meetingId) {
        return success(convertList(meetingFileService.getFileListByMeetingId(meetingId),
                file -> BeanUtils.toBean(file, AppMeetingBootstrapRespVO.Document.class)));
    }

    @GetMapping("/notices")
    @Operation(summary = "客户端获取通知列表")
    public CommonResult<List<AppMeetingBootstrapRespVO.Notice>> getNotices(@RequestParam("meetingId") Long meetingId) {
        return success(convertList(getPublishedNotifications(meetingId),
                notice -> BeanUtils.toBean(notice, AppMeetingBootstrapRespVO.Notice.class)));
    }

    @GetMapping("/notices/page")
    @Operation(summary = "客户端分页获取通知列表")
    public CommonResult<PageResult<AppMeetingNoticeRespVO>> getNoticePage(@Valid AppMeetingNoticePageReqVO reqVO) {
        MeetingNotificationPageReqVO pageReqVO = new MeetingNotificationPageReqVO();
        pageReqVO.setMeetingId(reqVO.getMeetingId());
        pageReqVO.setPublishStatus(1);
        pageReqVO.setPageNo(reqVO.getPageNo());
        pageReqVO.setPageSize(reqVO.getPageSize());
        PageResult<MeetingNotificationDO> pageResult = meetingNotificationService.getPage(pageReqVO);
        Set<Long> noticeIds = convertSet(pageResult.getList(), MeetingNotificationDO::getId);
        Set<Long> readIds = reqVO.getUserId() == null ? Set.of() : convertSet(
                meetingNoticeReadService.getReadList(reqVO.getMeetingId(), reqVO.getUserId(), noticeIds),
                MeetingNoticeReadDO::getNoticeId);
        return success(new PageResult<>(
                convertList(pageResult.getList(), notice -> buildAppNotice(notice, readIds.contains(notice.getId()))),
                pageResult.getTotal()));
    }

    @PostMapping("/notices/read")
    @Operation(summary = "客户端标记通知已读")
    public CommonResult<Boolean> markNoticeRead(@Valid @RequestBody AppMeetingNoticeReadReqVO reqVO) {
        meetingNoticeReadService.markRead(reqVO.getMeetingId(), reqVO.getUserId(), reqVO.getNoticeId());
        return success(true);
    }

    @GetMapping("/votes")
    @Operation(summary = "客户端获取表决列表")
    public CommonResult<List<AppMeetingBootstrapRespVO.Vote>> getVotes(@RequestParam("meetingId") Long meetingId,
                                                                       @RequestParam(value = "userId", required = false) Long userId) {
        return success(convertList(meetingVoteService.getVoteListByMeetingId(meetingId), vote -> {
            return buildAppVote(vote, userId);
        }));
    }

    @GetMapping("/realtime-state")
    @Operation(summary = "客户端获取会议实时状态")
    public CommonResult<AppMeetingRealtimeStateRespVO> getRealtimeState(@RequestParam("meetingId") Long meetingId) {
        AppMeetingRealtimeStateRespVO respVO = new AppMeetingRealtimeStateRespVO();
        respVO.setSyncRequests(convertList(
                meetingRealtimeStateService.getSyncRequests(meetingId),
                item -> BeanUtils.toBean(item, AppMeetingBootstrapRespVO.SyncRequest.class)));
        respVO.setServiceRequests(convertList(
                meetingServiceRequestService.getRecentList(meetingId, 50),
                this::buildAppServiceRequest));
        MeetingWsVideoPayload videoState = meetingRealtimeStateService.getVideoState(meetingId);
        if (videoState != null) {
            respVO.setVideoState(BeanUtils.toBean(videoState, AppMeetingRealtimeStateRespVO.VideoState.class));
        }
        MeetingWsTimerPayload timerState = meetingRealtimeStateService.getTimerState(meetingId);
        if (timerState != null) {
            respVO.setTimerState(BeanUtils.toBean(timerState, AppMeetingRealtimeStateRespVO.TimerState.class));
        }
        return success(respVO);
    }

    @GetMapping("/document-marks")
    @Operation(summary = "客户端获取文稿标记")
    public CommonResult<List<AppMeetingDocumentMarkRespVO>> getDocumentMarks(@RequestParam("meetingId") Long meetingId,
                                                                             @RequestParam("userId") Long userId,
                                                                             @RequestParam(value = "documentId", required = false) Long documentId) {
        List<MeetingDocumentMarkDO> marks = meetingDocumentMarkService.getMarkList(meetingId, userId, documentId);
        return success(convertList(marks, item -> BeanUtils.toBean(item, AppMeetingDocumentMarkRespVO.class)));
    }

    @PostMapping("/document-marks/save")
    @Operation(summary = "客户端保存文稿标记")
    public CommonResult<AppMeetingDocumentMarkRespVO> saveDocumentMark(@Valid @RequestBody AppMeetingDocumentMarkSaveReqVO reqVO) {
        MeetingDocumentMarkDO mark = meetingDocumentMarkService.saveMark(
                reqVO.getMeetingId(), reqVO.getUserId(), reqVO.getDocumentId(), reqVO.getPage(), reqVO.getType(), reqVO.getContent());
        return success(BeanUtils.toBean(mark, AppMeetingDocumentMarkRespVO.class));
    }

    @PostMapping("/document-marks/delete")
    @Operation(summary = "客户端删除文稿标记")
    public CommonResult<Boolean> deleteDocumentMark(@Valid @RequestBody AppMeetingDocumentMarkDeleteReqVO reqVO) {
        meetingDocumentMarkService.deleteMark(reqVO.getId(), reqVO.getUserId());
        return success(true);
    }

    @GetMapping("/service-requests")
    @Operation(summary = "客户端分页获取服务请求历史")
    public CommonResult<PageResult<AppMeetingServiceRequestRespVO>> getServiceRequests(@Valid AppMeetingServiceRequestPageReqVO reqVO) {
        PageResult<MeetingServiceRequestDO> pageResult = meetingServiceRequestService.getRequestPage(reqVO);
        return success(new PageResult<>(
                convertList(pageResult.getList(), item -> BeanUtils.toBean(item, AppMeetingServiceRequestRespVO.class)),
                pageResult.getTotal()));
    }

    private AppMeetingBootstrapRespVO.Vote buildAppVote(MeetingVoteRespVO vote, Long userId) {
        boolean hideAnonymousCounts = Boolean.TRUE.equals(vote.getIsSecret())
                && vote.getPublishedTime() == null
                && !isPrivilegedVoteViewer(vote.getMeetingId(), userId);
        Map<Long, Long> countMap = hideAnonymousCounts
                ? Map.of()
                : meetingVoteService.getVoteOptionCountMap(vote.getId());
        AppMeetingBootstrapRespVO.Vote vo = new AppMeetingBootstrapRespVO.Vote();
        vo.setId(vote.getId());
        vo.setAgendaId(vote.getAgendaId());
        vo.setTitle(vote.getTitle());
        vo.setType(vote.getType());
        vo.setSecret(vote.getIsSecret());
        vo.setStatus(vote.getStatus());
        vo.setPublishedTime(vote.getPublishedTime());
        vo.setCreateTime(vote.getCreateTime());
        vo.setCurrentUserVoted(meetingVoteService.hasUserVoted(vote.getId(), userId));
        vo.setTotalVotedCount(countMap.values().stream().mapToInt(Long::intValue).sum());
        vo.setOptions(convertList(vote.getOptions(), option -> {
            AppMeetingBootstrapRespVO.VoteOption optionVO = new AppMeetingBootstrapRespVO.VoteOption();
            optionVO.setId(option.getId());
            optionVO.setContent(option.getContent());
            optionVO.setSort(option.getSort());
            optionVO.setVoteCount(countMap.getOrDefault(option.getId(), 0L).intValue());
            return optionVO;
        }));
        return vo;
    }

    @PostMapping("/vote/submit")
    @Operation(summary = "客户端提交表决")
    public CommonResult<Boolean> submitVote(@Valid @RequestBody AppMeetingVoteSubmitReqVO reqVO) {
        meetingVoteService.submitVote(BeanUtils.toBean(reqVO, MeetingVoteRecordDO.class));
        return success(true);
    }

    @PostMapping("/signature/submit")
    @Operation(summary = "客户端提交签名")
    public CommonResult<AppMeetingSignatureRespVO> submitSignature(@Valid @RequestBody AppMeetingSignatureSubmitReqVO reqVO) {
        MeetingDO meeting = meetingService.getMeeting(reqVO.getMeetingId());
        if (meeting == null) {
            throw exception(MEETING_NOT_EXISTS);
        }
        MeetingAttendeeDO attendee = meetingAttendeeService.getAttendee(reqVO.getMeetingId(), reqVO.getUserId());
        if (attendee == null) {
            throw exception(MEETING_ATTENDEE_NOT_EXISTS);
        }
        byte[] imageContent = Base64.getDecoder().decode(reqVO.getImageBase64());
        MeetingSignatureDO signature = meetingSignatureService.submitSignature(
                reqVO.getMeetingId(),
                reqVO.getUserId(),
                attendee.getSeatId(),
                imageContent,
                reqVO.getStrokeCount()
        );
        return success(BeanUtils.toBean(signature, AppMeetingSignatureRespVO.class));
    }

    @GetMapping("/signature/latest")
    @Operation(summary = "客户端获取最近一次签名")
    public CommonResult<AppMeetingSignatureRespVO> getLatestSignature(@RequestParam("meetingId") Long meetingId,
                                                                      @RequestParam("userId") Long userId) {
        MeetingSignatureDO signature = meetingSignatureService.getLatestSignature(meetingId, userId);
        return success(signature == null ? null : BeanUtils.toBean(signature, AppMeetingSignatureRespVO.class));
    }

    private List<MeetingNotificationDO> getPublishedNotifications(Long meetingId) {
        MeetingNotificationPageReqVO pageReqVO = new MeetingNotificationPageReqVO();
        pageReqVO.setPageNo(1);
        pageReqVO.setPageSize(100);
        pageReqVO.setMeetingId(meetingId);
        pageReqVO.setPublishStatus(1);
        return meetingNotificationService.getPage(pageReqVO).getList().stream()
                .sorted(Comparator.comparing(MeetingNotificationDO::getPublishedTime,
                        Comparator.nullsLast(Comparator.naturalOrder())).reversed())
                .toList();
    }

    private AppMeetingNoticeRespVO buildAppNotice(MeetingNotificationDO notice, boolean read) {
        AppMeetingNoticeRespVO vo = new AppMeetingNoticeRespVO();
        vo.setId(notice.getId());
        vo.setTitle("会议通知");
        vo.setContent(notice.getContent());
        vo.setRead(read);
        vo.setPublishedTime(notice.getPublishedTime());
        vo.setCreateTime(notice.getCreateTime());
        return vo;
    }

    private AppMeetingBootstrapRespVO.ServiceRequest buildAppServiceRequest(MeetingServiceRequestDO item) {
        AppMeetingBootstrapRespVO.ServiceRequest vo = new AppMeetingBootstrapRespVO.ServiceRequest();
        vo.setRequestId(item.getRequestId());
        vo.setRequesterUserId(item.getRequesterUserId());
        vo.setRequesterName(item.getRequesterName());
        vo.setRequesterSeatName(item.getRequesterSeatName());
        vo.setCategory(item.getCategory());
        vo.setDetail(item.getDetail());
        vo.setStatus(item.getStatus());
        vo.setHandlerUserId(item.getHandlerUserId());
        vo.setHandlerName(item.getHandlerName());
        vo.setAcceptedAt(item.getAcceptedAt());
        vo.setCompletedAt(item.getCompletedAt());
        vo.setCanceledAt(item.getCanceledAt());
        vo.setResultRemark(item.getResultRemark());
        return vo;
    }

    private String resolveMeetingPassword(AppMeetingSignInReqVO reqVO) {
        if (reqVO.getMeetingPassword() != null) {
            return reqVO.getMeetingPassword();
        }
        return reqVO.getPassword();
    }

    private void validateUserPassword(Long userId, String userPassword, boolean required) {
        if (userPassword == null || userPassword.isBlank()) {
            if (required) {
                throw exception(MEETING_PASSWORD_INVALID);
            }
            return;
        }
        AdminUserDO user = adminUserService.getUser(userId);
        if (user == null || user.getPassword() == null
                || !adminUserService.isPasswordMatch(userPassword, user.getPassword())) {
            throw exception(MEETING_PASSWORD_INVALID);
        }
    }

    private boolean isUserPasswordRequired(Long userId) {
        AdminUserDO user = adminUserService.getUser(userId);
        return user != null && user.getPassword() != null && !user.getPassword().isBlank();
    }

    private boolean isPrivilegedVoteViewer(Long meetingId, Long userId) {
        if (userId == null) {
            return false;
        }
        MeetingAttendeeDO attendee = meetingAttendeeService.getAttendee(meetingId, userId);
        return attendee != null && (Objects.equals(attendee.getRole(), 1) || Objects.equals(attendee.getRole(), 2));
    }

    private String resolveRoleName(Integer role) {
        if (role == null) {
            return "与会人员";
        }
        return switch (role) {
            case 1 -> "主持人";
            case 2 -> "会议秘书";
            default -> "与会人员";
        };
    }

    private OAuth2AccessTokenRespDTO createRealtimeAccessToken(Long userId) {
        OAuth2AccessTokenCreateReqDTO reqDTO = new OAuth2AccessTokenCreateReqDTO();
        reqDTO.setUserId(userId);
        reqDTO.setUserType(UserTypeEnum.MEMBER.getValue());
        reqDTO.setClientId(OAuth2ClientConstants.CLIENT_ID_DEFAULT);
        return oauth2TokenApi.createAccessToken(reqDTO);
    }
}

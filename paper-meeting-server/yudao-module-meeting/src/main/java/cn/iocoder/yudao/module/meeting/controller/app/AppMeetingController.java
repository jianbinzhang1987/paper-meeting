package cn.iocoder.yudao.module.meeting.controller.app;

import cn.iocoder.yudao.framework.common.biz.system.oauth2.OAuth2TokenCommonApi;
import cn.iocoder.yudao.framework.common.biz.system.oauth2.dto.OAuth2AccessTokenCreateReqDTO;
import cn.iocoder.yudao.framework.common.biz.system.oauth2.dto.OAuth2AccessTokenRespDTO;
import cn.iocoder.yudao.framework.common.enums.UserTypeEnum;
import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.notification.vo.MeetingNotificationPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingBootstrapReqVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingBootstrapRespVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingRealtimeStateRespVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingSignatureRespVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingSignatureSubmitReqVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingSignInReqVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingSignInRespVO;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingVoteSubmitReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAgendaDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAttendeeDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingFileDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingSignatureDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteRecordDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.notification.MeetingNotificationDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.room.MeetingRoomDO;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingAgendaService;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingAttendeeService;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingFileService;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingService;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingSignatureService;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingVoteService;
import cn.iocoder.yudao.module.meeting.service.notification.MeetingNotificationService;
import cn.iocoder.yudao.module.meeting.service.realtime.MeetingRealtimeStateService;
import cn.iocoder.yudao.module.meeting.service.room.MeetingRoomService;
import cn.iocoder.yudao.module.system.api.user.AdminUserApi;
import cn.iocoder.yudao.module.system.api.user.dto.AdminUserRespDTO;
import cn.iocoder.yudao.module.system.enums.oauth2.OAuth2ClientConstants;
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
import java.util.Base64;

import static cn.iocoder.yudao.framework.common.exception.util.ServiceExceptionUtil.exception;
import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;
import static cn.iocoder.yudao.framework.common.util.collection.CollectionUtils.convertList;
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
    private MeetingVoteService meetingVoteService;
    @Resource
    private MeetingSignatureService meetingSignatureService;
    @Resource
    private MeetingNotificationService meetingNotificationService;
    @Resource
    private AdminUserApi adminUserApi;
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

        AppMeetingBootstrapRespVO respVO = new AppMeetingBootstrapRespVO();
        respVO.setMeetingId(meeting.getId());
        respVO.setMeetingName(meeting.getName());
        respVO.setDescription(meeting.getDescription());
        respVO.setRoomName(room.getName());
        respVO.setDeviceName(reqVO.getDeviceName());
        respVO.setSeatName(reqVO.getSeatName());
        respVO.setControlType(meeting.getControlType());
        respVO.setWatermark(meeting.getWatermark());
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
        respVO.setServiceRequests(convertList(meetingRealtimeStateService.getServiceRequests(meeting.getId()),
                item -> BeanUtils.toBean(item, AppMeetingBootstrapRespVO.ServiceRequest.class)));
        return success(respVO);
    }

    @PostMapping("/sign-in")
    @Operation(summary = "客户端签到")
    public CommonResult<AppMeetingSignInRespVO> signIn(@Valid @RequestBody AppMeetingSignInReqVO reqVO) {
        MeetingDO meeting = meetingService.getMeeting(reqVO.getMeetingId());
        if (meeting == null) {
            throw exception(MEETING_NOT_EXISTS);
        }
        if (meeting != null && meeting.getPassword() != null && !meeting.getPassword().isBlank()
                && !Objects.equals(meeting.getPassword(), reqVO.getPassword())) {
            throw exception(MEETING_PASSWORD_INVALID);
        }
        List<MeetingAttendeeDO> attendeeList = meetingAttendeeService.getAttendeeListByMeetingId(reqVO.getMeetingId());
        MeetingAttendeeDO attendee = attendeeList.stream()
                .filter(item -> Objects.equals(item.getUserId(), reqVO.getUserId()))
                .findFirst()
                .orElseThrow(() -> exception(MEETING_ATTENDEE_NOT_EXISTS));
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
                meetingRealtimeStateService.getServiceRequests(meetingId),
                item -> BeanUtils.toBean(item, AppMeetingBootstrapRespVO.ServiceRequest.class)));
        return success(respVO);
    }

    private AppMeetingBootstrapRespVO.Vote buildAppVote(MeetingVoteRespVO vote, Long userId) {
        Map<Long, Long> countMap = meetingVoteService.getVoteOptionCountMap(vote.getId());
        AppMeetingBootstrapRespVO.Vote vo = new AppMeetingBootstrapRespVO.Vote();
        vo.setId(vote.getId());
        vo.setAgendaId(vote.getAgendaId());
        vo.setTitle(vote.getTitle());
        vo.setType(vote.getType());
        vo.setSecret(vote.getIsSecret());
        vo.setStatus(vote.getStatus());
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

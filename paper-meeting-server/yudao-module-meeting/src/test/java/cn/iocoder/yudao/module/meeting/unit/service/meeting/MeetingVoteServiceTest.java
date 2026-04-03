package cn.iocoder.yudao.module.meeting.unit.service.meeting;

import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteOptionReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAgendaDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAttendeeDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteOptionDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteRecordDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingVoteMapper;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingVoteOptionMapper;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingVoteRecordMapper;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingAgendaService;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingAttendeeService;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingVoteServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * {@link MeetingVoteServiceImpl} 单元测试
 *
 * P0 测试覆盖: 投票创建、提交、状态变更
 * 优先级: P0 — 数据完整性关键路径
 */
class MeetingVoteServiceImplTest {

    @InjectMocks
    private MeetingVoteServiceImpl meetingVoteService;

    @Mock
    private MeetingVoteMapper meetingVoteMapper;

    @Mock
    private MeetingVoteOptionMapper meetingVoteOptionMapper;

    @Mock
    private MeetingVoteRecordMapper meetingVoteRecordMapper;

    @Mock
    private MeetingAttendeeService meetingAttendeeService;

    @Mock
    private MeetingAgendaService meetingAgendaService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    @DisplayName("P0 - 创建投票: 应该创建投票及其选项,使用默认状态值")
    void createVote_shouldCreateVoteWithOptions_whenValidRequest() {
        MeetingVoteCreateReqVO createReqVO = buildCreateVoteReq("测试投票", 1L);
        when(meetingVoteMapper.insert(any(MeetingVoteDO.class))).thenReturn(1);

        Long voteId = meetingVoteService.createVote(createReqVO);

        ArgumentCaptor<MeetingVoteDO> voteCaptor = ArgumentCaptor.forClass(MeetingVoteDO.class);
        verify(meetingVoteMapper).insert(voteCaptor.capture());
        MeetingVoteDO capturedVote = voteCaptor.getValue();
        assertThat(capturedVote.getTitle()).isEqualTo("测试投票");
        assertThat(capturedVote.getMeetingId()).isEqualTo(1L);
        assertThat(voteId).isEqualTo(1L);

        ArgumentCaptor<cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteOptionDO> optionCaptor =
                ArgumentCaptor.forClass(cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteOptionDO.class);
        verify(meetingVoteOptionMapper, times(3)).insert(optionCaptor.capture());
        List<cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteOptionDO> options = optionCaptor.getAllValues();
        assertThat(options).hasSize(3);
        assertThat(options.get(0).getContent()).isEqualTo("选项A");
    }

    @Test
    @DisplayName("P0 - 提交投票: 应该记录投票记录")
    void submitVote_shouldRecordVoteWhenValid() {
        MeetingVoteRecordDO record = new MeetingVoteRecordDO();
        record.setVoteId(1L);
        record.setUserId(100L);
        record.setOptionId(200L);

        meetingVoteService.submitVote(record);

        ArgumentCaptor<MeetingVoteRecordDO> captor = ArgumentCaptor.forClass(MeetingVoteRecordDO.class);
        verify(meetingVoteRecordMapper).insert(captor.capture());
        assertThat(captor.getValue().getVoteId()).isEqualTo(1L);
        assertThat(captor.getValue().getUserId()).isEqualTo(100L);
    }

    @Test
    @DisplayName("P0 - 用户是否投票: 应该正确判断用户是否已投票")
    void hasUserVoted_shouldReturnTrueWhenUserHasVoted() {
        List<MeetingVoteRecordDO> records = List.of(
                buildRecord(1L, 100L, 200L),
                buildRecord(1L, 101L, 201L)
        );
        when(meetingVoteRecordMapper.selectListByVoteId(1L)).thenReturn(records);

        boolean voted = meetingVoteService.hasUserVoted(1L, 100L);
        assertThat(voted).isTrue();

        boolean notVoted = meetingVoteService.hasUserVoted(1L, 999L);
        assertThat(notVoted).isFalse();
    }

    @Test
    @DisplayName("P0 - 用户是否投票: userId 为 null 时应返回 false")
    void hasUserVoted_shouldReturnFalseWhenUserIdIsNull() {
        boolean result = meetingVoteService.hasUserVoted(1L, null);
        assertThat(result).isFalse();
        verifyNoInteractions(meetingVoteRecordMapper);
    }

    @Test
    @DisplayName("P1 - 更新投票状态: 应该更新状态")
    void updateVoteStatus_shouldUpdateStatus() {
        when(meetingVoteMapper.updateById(any(MeetingVoteDO.class))).thenReturn(1);

        meetingVoteService.updateVoteStatus(1L, 2);

        ArgumentCaptor<MeetingVoteDO> captor = ArgumentCaptor.forClass(MeetingVoteDO.class);
        verify(meetingVoteMapper).updateById(captor.capture());
        MeetingVoteDO updated = captor.getValue();
        assertThat(updated.getId()).isEqualTo(1L);
        assertThat(updated.getStatus()).isEqualTo(2);
    }

    @Test
    @DisplayName("P1 - 标记投票已发布: 应该设置状态为2并设置发布时间")
    void markVotePublished_shouldUpdateStatusAndTime() {
        LocalDateTime pubTime = LocalDateTime.of(2026, 4, 3, 10, 0);
        when(meetingVoteMapper.updateById(any(MeetingVoteDO.class))).thenReturn(1);

        meetingVoteService.markVotePublished(1L, pubTime);

        ArgumentCaptor<MeetingVoteDO> captor = ArgumentCaptor.forClass(MeetingVoteDO.class);
        verify(meetingVoteMapper).updateById(captor.capture());
        MeetingVoteDO vote = captor.getValue();
        assertThat(vote.getStatus()).isEqualTo(2);
        assertThat(vote.getPublishedTime()).isEqualTo(pubTime);
    }

    @Test
    @DisplayName("P1 - 删除投票: 应该级联删除选项和记录")
    void deleteVote_shouldCascadeDeleteOptionsAndRecords() {
        meetingVoteService.deleteVote(1L);

        verify(meetingVoteOptionMapper).deleteByVoteId(1L);
        verify(meetingVoteRecordMapper).deleteByVoteId(1L);
        verify(meetingVoteMapper).deleteById(1L);
    }

    @Test
    @DisplayName("P1 - 获取投票选项统计: 应该返回正确的计数Map")
    void getVoteOptionCountMap_shouldReturnCorrectCounts() {
        List<MeetingVoteRecordDO> records = List.of(
                buildRecord(1L, 100L, 200L),
                buildRecord(1L, 101L, 200L),
                buildRecord(1L, 102L, 201L)
        );
        when(meetingVoteRecordMapper.selectListByVoteId(1L)).thenReturn(records);

        Map<Long, Long> countMap = meetingVoteService.getVoteOptionCountMap(1L);

        assertThat(countMap).hasSize(2);
        assertThat(countMap.get(200L)).isEqualTo(2L);
        assertThat(countMap.get(201L)).isEqualTo(1L);
    }

    @Test
    @DisplayName("P1 - 获取仪表盘: 出席率为0时不应抛异常")
    void getVoteDashboardByMeetingId_shouldHandleZeroAttendees() {
        MeetingVoteDO vote = new MeetingVoteDO();
        vote.setId(1L);
        vote.setMeetingId(1L);
        vote.setTitle("测试投票");
        vote.setType(0);
        vote.setIsSecret(true);
        vote.setStatus(1);
        vote.setAgendaId(50L);

        when(meetingVoteMapper.selectListByMeetingId(1L)).thenReturn(List.of(vote));
        when(meetingAttendeeService.getAttendeeListByMeetingId(1L)).thenReturn(List.of());
        when(meetingAgendaService.getAgendaListByMeetingId(1L)).thenReturn(List.of(buildAgenda(50L, "议题1")));
        when(meetingVoteOptionMapper.selectListByVoteId(1L)).thenReturn(List.of(
                buildOption(1L, 100L, "赞成", 1),
                buildOption(1L, 101L, "反对", 2)
        ));
        when(meetingVoteRecordMapper.selectListByVoteId(1L)).thenReturn(List.of());

        assertThatCode(() -> meetingVoteService.getVoteDashboardByMeetingId(1L))
                .doesNotThrowAnyException();
    }

    // ===== Test Data Builders =====

    private MeetingVoteCreateReqVO buildCreateVoteReq(String title, Long meetingId) {
        MeetingVoteCreateReqVO vo = new MeetingVoteCreateReqVO();
        vo.setTitle(title);
        vo.setMeetingId(meetingId);
        vo.setType(0);
        vo.setStatus(0);
        vo.setIsSecret(true);

        MeetingVoteOptionReqVO opt1 = new MeetingVoteOptionReqVO();
        opt1.setContent("选项A");
        opt1.setSort(1);

        MeetingVoteOptionReqVO opt2 = new MeetingVoteOptionReqVO();
        opt2.setContent("选项B");
        opt2.setSort(2);

        MeetingVoteOptionReqVO opt3 = new MeetingVoteOptionReqVO();
        opt3.setContent("选项C");
        opt3.setSort(3);

        vo.setOptions(List.of(opt1, opt2, opt3));
        return vo;
    }

    private MeetingVoteRecordDO buildRecord(Long voteId, Long userId, Long optionId) {
        MeetingVoteRecordDO record = new MeetingVoteRecordDO();
        record.setVoteId(voteId);
        record.setUserId(userId);
        record.setOptionId(optionId);
        return record;
    }

    private MeetingVoteOptionDO buildOption(Long voteId, Long id, String content, Integer sort) {
        MeetingVoteOptionDO option = new MeetingVoteOptionDO();
        option.setVoteId(voteId);
        option.setId(id);
        option.setContent(content);
        option.setSort(sort);
        return option;
    }

    private MeetingAgendaDO buildAgenda(Long id, String title) {
        MeetingAgendaDO agenda = new MeetingAgendaDO();
        agenda.setId(id);
        agenda.setTitle(title);
        return agenda;
    }
}

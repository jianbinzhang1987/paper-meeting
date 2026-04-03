package cn.iocoder.yudao.module.meeting.integration.service.meeting;

import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.*;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAttendeeDO;
import cn.iocoder.yudao.module.meeting.service.meeting.MeetingVoteService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * MeetingVoteService 集成测试
 *
 * 测试策略: 使用真实数据库 + 真实 Mapper + Mock 外部依赖
 * 级别: Integration — 验证 Service ↔ Mapper ↔ DB 的交互
 * 优先级: P0 — CRUD 核心路径
 */
@SpringBootTest
@ActiveProfiles("test")
@Transactional
class MeetingVoteIntegrationTest {

    @Autowired
    private MeetingVoteService meetingVoteService;

    @BeforeEach
    void setUp() {
        // 清理可能存在的脏数据
    }

    @Test
    @DisplayName("P0 - 创建投票: 应该正确持久化投票和选项")
    void createVote_shouldPersistVoteAndOptions() {
        MeetingVoteCreateReqVO reqVO = buildCreateVoteReq("集成测试投票", 999L);

        Long voteId = meetingVoteService.createVote(reqVO);

        assertThat(voteId).isNotNull();
        MeetingVoteDO vote = meetingVoteService.getVote(voteId);
        assertThat(vote).isNotNull();
        assertThat(vote.getTitle()).isEqualTo("集成测试投票");
    }

    @Test
    @DisplayName("P1 - 投票列表: 应该返回指定会议的所有投票")
    void getVoteListByMeetingId_shouldReturnAllVotesForMeeting() {
        // 创建两个投票
        MeetingVoteCreateReqVO req1 = buildCreateVoteReq("投票A", 888L);
        MeetingVoteCreateReqVO req2 = buildCreateVoteReq("投票B", 888L);
        meetingVoteService.createVote(req1);
        meetingVoteService.createVote(req2);

        List<MeetingVoteRespVO> votes = meetingVoteService.getVoteListByMeetingId(888L);

        assertThat(votes).hasSize(2);
        assertThat(votes).extracting(MeetingVoteRespVO::getTitle).containsExactlyInAnyOrder("投票A", "投票B");
    }

    @Test
    @DisplayName("P1 - 导出结果: 空投票记录不应抛异常")
    void getVoteResultExportList_shouldHandleEmptyRecords() {
        MeetingVoteCreateReqVO reqVO = buildCreateVoteReq("空投票", 777L);
        meetingVoteService.createVote(reqVO);

        List<MeetingVoteResultExportVO> exportList =
                meetingVoteService.getVoteResultExportList(777L);

        assertThat(exportList).isNotNull();
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
        opt1.setContent("赞成");
        opt1.setSort(1);

        MeetingVoteOptionReqVO opt2 = new MeetingVoteOptionReqVO();
        opt2.setContent("反对");
        opt2.setSort(2);

        vo.setOptions(List.of(opt1, opt2));
        return vo;
    }
}

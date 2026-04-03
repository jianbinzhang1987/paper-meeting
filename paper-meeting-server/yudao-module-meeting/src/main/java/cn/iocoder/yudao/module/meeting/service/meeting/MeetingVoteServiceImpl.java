package cn.iocoder.yudao.module.meeting.service.meeting;

import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteDashboardRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteOptionReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteResultExportVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAgendaDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingAttendeeDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteOptionDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteRecordDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingVoteMapper;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingVoteOptionMapper;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingVoteRecordMapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@Validated
public class MeetingVoteServiceImpl implements MeetingVoteService {

    @Resource
    private MeetingVoteMapper meetingVoteMapper;
    @Resource
    private MeetingVoteOptionMapper meetingVoteOptionMapper;
    @Resource
    private MeetingVoteRecordMapper meetingVoteRecordMapper;
    @Resource
    private MeetingAttendeeService meetingAttendeeService;
    @Resource
    private MeetingAgendaService meetingAgendaService;

    @Override
    public Long createVote(MeetingVoteCreateReqVO createReqVO) {
        MeetingVoteDO voteDO = BeanUtils.toBean(createReqVO, MeetingVoteDO.class);
        voteDO.setStatus(createReqVO.getStatus() == null ? 0 : createReqVO.getStatus());
        voteDO.setIsSecret(createReqVO.getIsSecret() != null ? createReqVO.getIsSecret() : Boolean.TRUE);
        meetingVoteMapper.insert(voteDO);

        for (int i = 0; i < createReqVO.getOptions().size(); i++) {
            MeetingVoteOptionReqVO optionReqVO = createReqVO.getOptions().get(i);
            MeetingVoteOptionDO option = BeanUtils.toBean(optionReqVO, MeetingVoteOptionDO.class);
            option.setVoteId(voteDO.getId());
            option.setSort(option.getSort() == null ? i + 1 : option.getSort());
            meetingVoteOptionMapper.insert(option);
        }
        return voteDO.getId();
    }

    @Override
    public void deleteVote(Long id) {
        meetingVoteOptionMapper.deleteByVoteId(id);
        meetingVoteRecordMapper.deleteByVoteId(id);
        meetingVoteMapper.deleteById(id);
    }

    @Override
    public MeetingVoteDO getVote(Long id) {
        return meetingVoteMapper.selectById(id);
    }

    @Override
    public List<MeetingVoteRespVO> getVoteListByMeetingId(Long meetingId) {
        List<MeetingVoteDO> voteList = meetingVoteMapper.selectListByMeetingId(meetingId);
        List<MeetingVoteRespVO> respList = new ArrayList<>(voteList.size());
        for (MeetingVoteDO vote : voteList) {
            MeetingVoteRespVO respVO = BeanUtils.toBean(vote, MeetingVoteRespVO.class);
            respVO.setOptions(BeanUtils.toBean(
                    meetingVoteOptionMapper.selectListByVoteId(vote.getId()),
                    MeetingVoteRespVO.Option.class));
            respList.add(respVO);
        }
        return respList;
    }

    @Override
    public MeetingVoteDashboardRespVO getVoteDashboardByMeetingId(Long meetingId) {
        List<MeetingVoteDO> voteList = meetingVoteMapper.selectListByMeetingId(meetingId);
        List<MeetingAttendeeDO> attendeeList = meetingAttendeeService.getAttendeeListByMeetingId(meetingId);
        Map<Long, String> agendaMap = meetingAgendaService.getAgendaListByMeetingId(meetingId).stream()
                .collect(Collectors.toMap(MeetingAgendaDO::getId, MeetingAgendaDO::getTitle, (left, right) -> left));
        int attendeeCount = attendeeList.size();

        MeetingVoteDashboardRespVO respVO = new MeetingVoteDashboardRespVO();
        respVO.setMeetingId(meetingId);
        respVO.setAttendeeCount(attendeeCount);
        respVO.setVotes(voteList.stream().map(vote -> buildDashboardVote(vote, attendeeCount, agendaMap)).toList());
        return respVO;
    }

    @Override
    public List<MeetingVoteResultExportVO> getVoteResultExportList(Long meetingId) {
        List<MeetingVoteDO> voteList = meetingVoteMapper.selectListByMeetingId(meetingId);
        List<MeetingVoteResultExportVO> exportList = new ArrayList<>();
        for (MeetingVoteDO vote : voteList) {
            List<MeetingVoteOptionDO> options = meetingVoteOptionMapper.selectListByVoteId(vote.getId());
            List<MeetingVoteRecordDO> records = meetingVoteRecordMapper.selectListByVoteId(vote.getId());
            Map<Long, Long> voteCountMap = new HashMap<>();
            for (MeetingVoteRecordDO record : records) {
                voteCountMap.merge(record.getOptionId(), 1L, Long::sum);
            }
            options.stream()
                    .sorted(Comparator.comparing(option -> option.getSort() == null ? Integer.MAX_VALUE : option.getSort()))
                    .forEach(option -> {
                        MeetingVoteResultExportVO vo = new MeetingVoteResultExportVO();
                        vo.setVoteTitle(vote.getTitle());
                        vo.setVoteType(resolveVoteType(vote.getType()));
                        vo.setSecretType(Boolean.TRUE.equals(vote.getIsSecret()) ? "匿名" : "实名");
                        vo.setVoteStatus(resolveVoteStatus(vote));
                        vo.setOptionContent(option.getContent());
                        vo.setVoteCount(voteCountMap.getOrDefault(option.getId(), 0L));
                        vo.setCreateTime(vote.getCreateTime());
                        exportList.add(vo);
                    });
        }
        return exportList;
    }

    @Override
    public void submitVote(MeetingVoteRecordDO recordDO) {
        meetingVoteRecordMapper.insert(recordDO);
    }

    @Override
    public void updateVoteStatus(Long id, Integer status) {
        meetingVoteMapper.updateById(new MeetingVoteDO()
                .setId(id)
                .setStatus(status)
                .setPublishedTime(null));
    }

    @Override
    public void markVotePublished(Long id, LocalDateTime publishedTime) {
        meetingVoteMapper.updateById(new MeetingVoteDO()
                .setId(id)
                .setStatus(2)
                .setPublishedTime(publishedTime));
    }

    @Override
    public Map<Long, Long> getVoteOptionCountMap(Long voteId) {
        List<MeetingVoteRecordDO> records = meetingVoteRecordMapper.selectListByVoteId(voteId);
        Map<Long, Long> countMap = new HashMap<>();
        for (MeetingVoteRecordDO record : records) {
            countMap.merge(record.getOptionId(), 1L, Long::sum);
        }
        return countMap;
    }

    @Override
    public boolean hasUserVoted(Long voteId, Long userId) {
        if (userId == null) {
            return false;
        }
        return meetingVoteRecordMapper.selectListByVoteId(voteId).stream()
                .anyMatch(record -> userId.equals(record.getUserId()));
    }

    private MeetingVoteDashboardRespVO.VoteItem buildDashboardVote(MeetingVoteDO vote, int attendeeCount,
                                                                   Map<Long, String> agendaMap) {
        List<MeetingVoteOptionDO> options = meetingVoteOptionMapper.selectListByVoteId(vote.getId()).stream()
                .sorted(Comparator.comparing(option -> option.getSort() == null ? Integer.MAX_VALUE : option.getSort()))
                .toList();
        Map<Long, Long> countMap = getVoteOptionCountMap(vote.getId());
        int votedCount = countMap.values().stream().mapToInt(Long::intValue).sum();

        MeetingVoteDashboardRespVO.VoteItem item = new MeetingVoteDashboardRespVO.VoteItem();
        item.setId(vote.getId());
        item.setAgendaId(vote.getAgendaId());
        item.setAgendaTitle(vote.getAgendaId() == null ? "未关联议题" : agendaMap.getOrDefault(vote.getAgendaId(), "议题#" + vote.getAgendaId()));
        item.setTitle(vote.getTitle());
        item.setType(vote.getType());
        item.setSecret(vote.getIsSecret());
        item.setStatus(vote.getStatus());
        item.setAttendeeCount(attendeeCount);
        item.setVotedCount(votedCount);
        item.setPendingCount(Math.max(attendeeCount - votedCount, 0));
        item.setTurnoutRate(buildRate(votedCount, attendeeCount));
        item.setCreateTime(vote.getCreateTime());
        item.setOptions(options.stream().map(option -> {
            MeetingVoteDashboardRespVO.OptionItem optionItem = new MeetingVoteDashboardRespVO.OptionItem();
            int optionCount = countMap.getOrDefault(option.getId(), 0L).intValue();
            optionItem.setId(option.getId());
            optionItem.setContent(option.getContent());
            optionItem.setSort(option.getSort());
            optionItem.setVoteCount(optionCount);
            optionItem.setVoteRate(buildRate(optionCount, votedCount));
            return optionItem;
        }).toList());
        return item;
    }

    private BigDecimal buildRate(int numerator, int denominator) {
        if (denominator <= 0) {
            return BigDecimal.ZERO;
        }
        return BigDecimal.valueOf(numerator)
                .multiply(BigDecimal.valueOf(100))
                .divide(BigDecimal.valueOf(denominator), 2, RoundingMode.HALF_UP);
    }

    private String resolveVoteType(Integer type) {
        return type != null && type == 1 ? "多选" : "单选";
    }

    private String resolveVoteStatus(MeetingVoteDO vote) {
        if (vote == null || vote.getStatus() == null) {
            return "未开始";
        }
        if (vote.getPublishedTime() != null) {
            return "已发布";
        }
        return switch (vote.getStatus()) {
            case 1 -> "进行中";
            case 2 -> "已结束";
            default -> "未开始";
        };
    }
}

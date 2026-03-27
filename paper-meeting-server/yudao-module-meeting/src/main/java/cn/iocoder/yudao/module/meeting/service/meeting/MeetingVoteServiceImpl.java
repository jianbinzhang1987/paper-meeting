package cn.iocoder.yudao.module.meeting.service.meeting;

import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteOptionReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingVoteResultExportVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteOptionDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingVoteRecordDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingVoteMapper;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingVoteOptionMapper;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingVoteRecordMapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@Validated
public class MeetingVoteServiceImpl implements MeetingVoteService {

    @Resource
    private MeetingVoteMapper meetingVoteMapper;
    @Resource
    private MeetingVoteOptionMapper meetingVoteOptionMapper;
    @Resource
    private MeetingVoteRecordMapper meetingVoteRecordMapper;

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
                        vo.setVoteStatus(resolveVoteStatus(vote.getStatus()));
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
        meetingVoteMapper.updateById(new MeetingVoteDO().setId(id).setStatus(status));
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

    private String resolveVoteType(Integer type) {
        return type != null && type == 1 ? "多选" : "单选";
    }

    private String resolveVoteStatus(Integer status) {
        if (status == null) {
            return "未开始";
        }
        return switch (status) {
            case 1 -> "进行中";
            case 2 -> "已结束";
            default -> "未开始";
        };
    }
}

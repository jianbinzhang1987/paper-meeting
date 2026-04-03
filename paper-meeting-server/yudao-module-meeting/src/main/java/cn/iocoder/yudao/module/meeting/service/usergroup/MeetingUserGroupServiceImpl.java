package cn.iocoder.yudao.module.meeting.service.usergroup;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.usergroup.vo.MeetingUserGroupCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.usergroup.vo.MeetingUserGroupPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.usergroup.vo.MeetingUserGroupRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.usergroup.vo.MeetingUserGroupSimpleRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.usergroup.vo.MeetingUserGroupUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.usergroup.MeetingUserGroupDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.usergroup.MeetingUserGroupMapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.validation.annotation.Validated;

import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

@Service
@Validated
public class MeetingUserGroupServiceImpl implements MeetingUserGroupService {

    @Resource
    private MeetingUserGroupMapper meetingUserGroupMapper;

    @Override
    public Long create(MeetingUserGroupCreateReqVO createReqVO) {
        MeetingUserGroupDO data = BeanUtils.toBean(createReqVO, MeetingUserGroupDO.class);
        data.setUserIds(joinUserIds(createReqVO.getUserIds()));
        if (data.getActive() == null) {
            data.setActive(true);
        }
        meetingUserGroupMapper.insert(data);
        return data.getId();
    }

    @Override
    public void update(MeetingUserGroupUpdateReqVO updateReqVO) {
        MeetingUserGroupDO data = BeanUtils.toBean(updateReqVO, MeetingUserGroupDO.class);
        data.setUserIds(joinUserIds(updateReqVO.getUserIds()));
        meetingUserGroupMapper.updateById(data);
    }

    @Override
    public void delete(Long id) {
        meetingUserGroupMapper.deleteById(id);
    }

    @Override
    public MeetingUserGroupRespVO get(Long id) {
        return buildRespVO(meetingUserGroupMapper.selectById(id));
    }

    @Override
    public PageResult<MeetingUserGroupRespVO> getPage(MeetingUserGroupPageReqVO pageReqVO) {
        PageResult<MeetingUserGroupDO> page = meetingUserGroupMapper.selectPage(pageReqVO);
        return new PageResult<>(page.getList().stream().map(this::buildRespVO).toList(), page.getTotal());
    }

    @Override
    public List<MeetingUserGroupSimpleRespVO> getSimpleList() {
        return meetingUserGroupMapper.selectActiveList().stream().map(item -> {
            MeetingUserGroupSimpleRespVO vo = new MeetingUserGroupSimpleRespVO();
            vo.setId(item.getId());
            vo.setName(item.getName());
            vo.setUserIds(parseUserIds(item.getUserIds()));
            return vo;
        }).toList();
    }

    @Override
    public List<MeetingUserGroupDO> getListByIds(Collection<Long> ids) {
        return meetingUserGroupMapper.selectListByIds(ids);
    }

    private MeetingUserGroupRespVO buildRespVO(MeetingUserGroupDO data) {
        if (data == null) {
            return null;
        }
        MeetingUserGroupRespVO vo = BeanUtils.toBean(data, MeetingUserGroupRespVO.class);
        vo.setUserIds(parseUserIds(data.getUserIds()));
        return vo;
    }

    private String joinUserIds(List<Long> userIds) {
        return userIds == null ? "" : StringUtils.collectionToCommaDelimitedString(userIds);
    }

    private List<Long> parseUserIds(String userIds) {
        if (!StringUtils.hasText(userIds)) {
            return Collections.emptyList();
        }
        return Arrays.stream(userIds.split(","))
                .filter(StringUtils::hasText)
                .map(Long::valueOf)
                .toList();
    }
}

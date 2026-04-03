package cn.iocoder.yudao.module.meeting.service.usergroup;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.meeting.controller.admin.usergroup.vo.MeetingUserGroupCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.usergroup.vo.MeetingUserGroupPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.usergroup.vo.MeetingUserGroupRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.usergroup.vo.MeetingUserGroupSimpleRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.usergroup.vo.MeetingUserGroupUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.usergroup.MeetingUserGroupDO;

import java.util.Collection;
import java.util.List;

public interface MeetingUserGroupService {

    Long create(MeetingUserGroupCreateReqVO createReqVO);

    void update(MeetingUserGroupUpdateReqVO updateReqVO);

    void delete(Long id);

    MeetingUserGroupRespVO get(Long id);

    PageResult<MeetingUserGroupRespVO> getPage(MeetingUserGroupPageReqVO pageReqVO);

    List<MeetingUserGroupSimpleRespVO> getSimpleList();

    List<MeetingUserGroupDO> getListByIds(Collection<Long> ids);
}

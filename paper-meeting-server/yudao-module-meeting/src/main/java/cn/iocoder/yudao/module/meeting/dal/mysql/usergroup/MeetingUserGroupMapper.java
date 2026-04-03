package cn.iocoder.yudao.module.meeting.dal.mysql.usergroup;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.module.meeting.controller.admin.usergroup.vo.MeetingUserGroupPageReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.usergroup.MeetingUserGroupDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.Collection;
import java.util.List;

@Mapper
public interface MeetingUserGroupMapper extends BaseMapperX<MeetingUserGroupDO> {

    default PageResult<MeetingUserGroupDO> selectPage(MeetingUserGroupPageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<MeetingUserGroupDO>()
                .likeIfPresent(MeetingUserGroupDO::getName, reqVO.getName())
                .eqIfPresent(MeetingUserGroupDO::getActive, reqVO.getActive())
                .orderByDesc(MeetingUserGroupDO::getActive)
                .orderByDesc(MeetingUserGroupDO::getId));
    }

    default List<MeetingUserGroupDO> selectListByIds(Collection<Long> ids) {
        return selectList(new LambdaQueryWrapperX<MeetingUserGroupDO>()
                .inIfPresent(MeetingUserGroupDO::getId, ids));
    }

    default List<MeetingUserGroupDO> selectActiveList() {
        return selectList(new LambdaQueryWrapperX<MeetingUserGroupDO>()
                .eq(MeetingUserGroupDO::getActive, true)
                .orderByDesc(MeetingUserGroupDO::getId));
    }
}

package cn.iocoder.yudao.module.meeting.dal.mysql.appversion;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.module.meeting.controller.admin.appversion.vo.MeetingAppVersionPageReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.appversion.MeetingAppVersionDO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MeetingAppVersionMapper extends BaseMapperX<MeetingAppVersionDO> {

    default PageResult<MeetingAppVersionDO> selectPage(MeetingAppVersionPageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<MeetingAppVersionDO>()
                .eqIfPresent(MeetingAppVersionDO::getClientType, reqVO.getClientType())
                .eqIfPresent(MeetingAppVersionDO::getActive, reqVO.getActive())
                .likeIfPresent(MeetingAppVersionDO::getName, reqVO.getName())
                .orderByDesc(MeetingAppVersionDO::getActive)
                .orderByDesc(MeetingAppVersionDO::getVersionCode)
                .orderByDesc(MeetingAppVersionDO::getId));
    }
}

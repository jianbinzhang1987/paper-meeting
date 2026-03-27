package cn.iocoder.yudao.module.meeting.dal.mysql.uiconfig;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.module.meeting.controller.admin.uiconfig.vo.MeetingUiConfigPageReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.uiconfig.MeetingUiConfigDO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MeetingUiConfigMapper extends BaseMapperX<MeetingUiConfigDO> {

    default PageResult<MeetingUiConfigDO> selectPage(MeetingUiConfigPageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<MeetingUiConfigDO>()
                .likeIfPresent(MeetingUiConfigDO::getName, reqVO.getName())
                .eqIfPresent(MeetingUiConfigDO::getActive, reqVO.getActive())
                .orderByDesc(MeetingUiConfigDO::getActive)
                .orderByDesc(MeetingUiConfigDO::getId));
    }
}

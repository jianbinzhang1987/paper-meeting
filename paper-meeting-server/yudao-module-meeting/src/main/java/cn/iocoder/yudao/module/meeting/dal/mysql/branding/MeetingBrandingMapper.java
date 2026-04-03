package cn.iocoder.yudao.module.meeting.dal.mysql.branding;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.module.meeting.controller.admin.branding.vo.MeetingBrandingPageReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.branding.MeetingBrandingDO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MeetingBrandingMapper extends BaseMapperX<MeetingBrandingDO> {

    default PageResult<MeetingBrandingDO> selectPage(MeetingBrandingPageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<MeetingBrandingDO>()
                .likeIfPresent(MeetingBrandingDO::getSiteName, reqVO.getSiteName())
                .eqIfPresent(MeetingBrandingDO::getActive, reqVO.getActive())
                .orderByDesc(MeetingBrandingDO::getActive)
                .orderByDesc(MeetingBrandingDO::getId));
    }

    default MeetingBrandingDO selectActive() {
        return selectOne(new LambdaQueryWrapperX<MeetingBrandingDO>()
                .eq(MeetingBrandingDO::getActive, true)
                .orderByDesc(MeetingBrandingDO::getId)
                .last("LIMIT 1"));
    }
}

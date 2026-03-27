package cn.iocoder.yudao.module.meeting.dal.mysql.publicfile;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFilePageReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.publicfile.MeetingPublicFileDO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MeetingPublicFileMapper extends BaseMapperX<MeetingPublicFileDO> {

    default PageResult<MeetingPublicFileDO> selectPage(MeetingPublicFilePageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<MeetingPublicFileDO>()
                .likeIfPresent(MeetingPublicFileDO::getName, reqVO.getName())
                .eqIfPresent(MeetingPublicFileDO::getCategory, reqVO.getCategory())
                .eqIfPresent(MeetingPublicFileDO::getEnabled, reqVO.getEnabled())
                .orderByAsc(MeetingPublicFileDO::getSort)
                .orderByDesc(MeetingPublicFileDO::getId));
    }
}

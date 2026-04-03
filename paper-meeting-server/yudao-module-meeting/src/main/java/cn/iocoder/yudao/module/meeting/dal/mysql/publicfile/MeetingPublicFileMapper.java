package cn.iocoder.yudao.module.meeting.dal.mysql.publicfile;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFilePageReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.publicfile.MeetingPublicFileDO;
import org.apache.ibatis.annotations.Mapper;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;

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

    default List<MeetingPublicFileDO> selectListForCategoryTree() {
        return selectList(new LambdaQueryWrapperX<MeetingPublicFileDO>()
                .orderByAsc(MeetingPublicFileDO::getCategory)
                .orderByAsc(MeetingPublicFileDO::getSort)
                .orderByDesc(MeetingPublicFileDO::getId));
    }

    default List<MeetingPublicFileDO> selectListForArchive(LocalDateTime beforeTime, String sourceCategoryPrefix) {
        return selectList(new LambdaQueryWrapperX<MeetingPublicFileDO>()
                .ltIfPresent(MeetingPublicFileDO::getCreateTime, beforeTime)
                .likeIfPresent(MeetingPublicFileDO::getCategory, sourceCategoryPrefix)
                .orderByAsc(MeetingPublicFileDO::getCategory)
                .orderByDesc(MeetingPublicFileDO::getId));
    }

    default List<MeetingPublicFileDO> selectListByIds(Collection<Long> ids) {
        return selectList(new LambdaQueryWrapperX<MeetingPublicFileDO>()
                .inIfPresent(MeetingPublicFileDO::getId, ids));
    }
}

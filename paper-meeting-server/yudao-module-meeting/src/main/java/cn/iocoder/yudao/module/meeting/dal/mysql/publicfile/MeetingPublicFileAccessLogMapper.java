package cn.iocoder.yudao.module.meeting.dal.mysql.publicfile;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileAccessLogPageReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.publicfile.MeetingPublicFileAccessLogDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.Collection;
import java.util.List;

@Mapper
public interface MeetingPublicFileAccessLogMapper extends BaseMapperX<MeetingPublicFileAccessLogDO> {

    default PageResult<MeetingPublicFileAccessLogDO> selectPage(MeetingPublicFileAccessLogPageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<MeetingPublicFileAccessLogDO>()
                .eqIfPresent(MeetingPublicFileAccessLogDO::getFileId, reqVO.getFileId())
                .orderByDesc(MeetingPublicFileAccessLogDO::getId));
    }

    default List<MeetingPublicFileAccessLogDO> selectListByFileIds(Collection<Long> fileIds) {
        return selectList(new LambdaQueryWrapperX<MeetingPublicFileAccessLogDO>()
                .inIfPresent(MeetingPublicFileAccessLogDO::getFileId, fileIds)
                .orderByDesc(MeetingPublicFileAccessLogDO::getId));
    }
}

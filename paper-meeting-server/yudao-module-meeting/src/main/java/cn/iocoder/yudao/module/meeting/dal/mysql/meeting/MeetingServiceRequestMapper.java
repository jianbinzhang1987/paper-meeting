package cn.iocoder.yudao.module.meeting.dal.mysql.meeting;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.module.meeting.controller.app.vo.AppMeetingServiceRequestPageReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingServiceRequestDO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MeetingServiceRequestMapper extends BaseMapperX<MeetingServiceRequestDO> {

    default MeetingServiceRequestDO selectByRequestId(String requestId) {
        return selectOne(new LambdaQueryWrapperX<MeetingServiceRequestDO>()
                .eq(MeetingServiceRequestDO::getRequestId, requestId)
                .last("LIMIT 1"));
    }

    default PageResult<MeetingServiceRequestDO> selectPage(AppMeetingServiceRequestPageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<MeetingServiceRequestDO>()
                .eq(MeetingServiceRequestDO::getMeetingId, reqVO.getMeetingId())
                .eqIfPresent(MeetingServiceRequestDO::getRequesterUserId, reqVO.getUserId())
                .orderByDesc(MeetingServiceRequestDO::getUpdateTime, MeetingServiceRequestDO::getId));
    }

    default java.util.List<MeetingServiceRequestDO> selectRecentList(Long meetingId, Integer limit) {
        return selectList(new LambdaQueryWrapperX<MeetingServiceRequestDO>()
                .eq(MeetingServiceRequestDO::getMeetingId, meetingId)
                .orderByDesc(MeetingServiceRequestDO::getUpdateTime, MeetingServiceRequestDO::getId)
                .last("LIMIT " + (limit == null || limit <= 0 ? 50 : limit)));
    }
}

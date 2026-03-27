package cn.iocoder.yudao.module.meeting.dal.mysql.notification;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.module.meeting.controller.admin.notification.vo.MeetingNotificationPageReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.notification.MeetingNotificationDO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MeetingNotificationMapper extends BaseMapperX<MeetingNotificationDO> {

    default PageResult<MeetingNotificationDO> selectPage(MeetingNotificationPageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<MeetingNotificationDO>()
                .eqIfPresent(MeetingNotificationDO::getMeetingId, reqVO.getMeetingId())
                .eqIfPresent(MeetingNotificationDO::getPublishStatus, reqVO.getPublishStatus())
                .likeIfPresent(MeetingNotificationDO::getContent, reqVO.getContent())
                .orderByDesc(MeetingNotificationDO::getId));
    }
}

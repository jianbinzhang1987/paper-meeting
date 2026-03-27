package cn.iocoder.yudao.module.meeting.service.notification;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.meeting.controller.admin.notification.vo.MeetingNotificationCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.notification.vo.MeetingNotificationPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.notification.vo.MeetingNotificationUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.notification.MeetingNotificationDO;

public interface MeetingNotificationService {

    Long create(MeetingNotificationCreateReqVO createReqVO);

    void update(MeetingNotificationUpdateReqVO updateReqVO);

    void delete(Long id);

    MeetingNotificationDO get(Long id);

    PageResult<MeetingNotificationDO> getPage(MeetingNotificationPageReqVO pageReqVO);

    void publish(Long id);
}

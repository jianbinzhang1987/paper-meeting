package cn.iocoder.yudao.module.meeting.service.notification;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.notification.vo.MeetingNotificationCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.notification.vo.MeetingNotificationPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.notification.vo.MeetingNotificationUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.notification.MeetingNotificationDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.notification.MeetingNotificationMapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

import java.time.LocalDateTime;

@Service
@Validated
public class MeetingNotificationServiceImpl implements MeetingNotificationService {

    @Resource
    private MeetingNotificationMapper meetingNotificationMapper;

    @Override
    public Long create(MeetingNotificationCreateReqVO createReqVO) {
        MeetingNotificationDO notification = BeanUtils.toBean(createReqVO, MeetingNotificationDO.class);
        if (notification.getPublishStatus() == null) {
            notification.setPublishStatus(0);
        }
        meetingNotificationMapper.insert(notification);
        return notification.getId();
    }

    @Override
    public void update(MeetingNotificationUpdateReqVO updateReqVO) {
        meetingNotificationMapper.updateById(BeanUtils.toBean(updateReqVO, MeetingNotificationDO.class));
    }

    @Override
    public void delete(Long id) {
        meetingNotificationMapper.deleteById(id);
    }

    @Override
    public MeetingNotificationDO get(Long id) {
        return meetingNotificationMapper.selectById(id);
    }

    @Override
    public PageResult<MeetingNotificationDO> getPage(MeetingNotificationPageReqVO pageReqVO) {
        return meetingNotificationMapper.selectPage(pageReqVO);
    }

    @Override
    public void publish(Long id) {
        meetingNotificationMapper.updateById(new MeetingNotificationDO()
                .setId(id)
                .setPublishStatus(1)
                .setPublishedTime(LocalDateTime.now()));
    }
}

package cn.iocoder.yudao.module.meeting.service.branding;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.branding.vo.MeetingBrandingCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.branding.vo.MeetingBrandingPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.branding.vo.MeetingBrandingUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.branding.MeetingBrandingDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.branding.MeetingBrandingMapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

@Service
@Validated
public class MeetingBrandingServiceImpl implements MeetingBrandingService {

    @Resource
    private MeetingBrandingMapper meetingBrandingMapper;

    @Override
    public Long create(MeetingBrandingCreateReqVO createReqVO) {
        MeetingBrandingDO data = BeanUtils.toBean(createReqVO, MeetingBrandingDO.class);
        if (data.getActive() == null) {
            data.setActive(false);
        }
        if (Boolean.TRUE.equals(data.getActive())) {
            resetActive();
        }
        meetingBrandingMapper.insert(data);
        return data.getId();
    }

    @Override
    public void update(MeetingBrandingUpdateReqVO updateReqVO) {
        if (Boolean.TRUE.equals(updateReqVO.getActive())) {
            resetActive();
        }
        meetingBrandingMapper.updateById(BeanUtils.toBean(updateReqVO, MeetingBrandingDO.class));
    }

    @Override
    public void delete(Long id) {
        meetingBrandingMapper.deleteById(id);
    }

    @Override
    public MeetingBrandingDO get(Long id) {
        return meetingBrandingMapper.selectById(id);
    }

    @Override
    public PageResult<MeetingBrandingDO> getPage(MeetingBrandingPageReqVO pageReqVO) {
        return meetingBrandingMapper.selectPage(pageReqVO);
    }

    @Override
    public MeetingBrandingDO getActive() {
        return meetingBrandingMapper.selectActive();
    }

    @Override
    public void activate(Long id) {
        resetActive();
        MeetingBrandingDO data = meetingBrandingMapper.selectById(id);
        if (data == null) {
            return;
        }
        data.setActive(true);
        meetingBrandingMapper.updateById(data);
    }

    private void resetActive() {
        MeetingBrandingDO active = meetingBrandingMapper.selectActive();
        if (active == null) {
            return;
        }
        active.setActive(false);
        meetingBrandingMapper.updateById(active);
    }
}

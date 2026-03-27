package cn.iocoder.yudao.module.meeting.service.uiconfig;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.uiconfig.vo.MeetingUiConfigCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.uiconfig.vo.MeetingUiConfigPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.uiconfig.vo.MeetingUiConfigUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.uiconfig.MeetingUiConfigDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.uiconfig.MeetingUiConfigMapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.annotation.Validated;

@Service
@Validated
public class MeetingUiConfigServiceImpl implements MeetingUiConfigService {

    @Resource
    private MeetingUiConfigMapper meetingUiConfigMapper;

    @Override
    public Long create(MeetingUiConfigCreateReqVO createReqVO) {
        MeetingUiConfigDO data = BeanUtils.toBean(createReqVO, MeetingUiConfigDO.class);
        if (data.getFontSize() == null) {
            data.setFontSize(16);
        }
        if (data.getActive() == null) {
            data.setActive(false);
        }
        meetingUiConfigMapper.insert(data);
        if (Boolean.TRUE.equals(data.getActive())) {
            activate(data.getId());
        }
        return data.getId();
    }

    @Override
    public void update(MeetingUiConfigUpdateReqVO updateReqVO) {
        meetingUiConfigMapper.updateById(BeanUtils.toBean(updateReqVO, MeetingUiConfigDO.class));
        if (Boolean.TRUE.equals(updateReqVO.getActive())) {
            activate(updateReqVO.getId());
        }
    }

    @Override
    public void delete(Long id) {
        meetingUiConfigMapper.deleteById(id);
    }

    @Override
    public MeetingUiConfigDO get(Long id) {
        return meetingUiConfigMapper.selectById(id);
    }

    @Override
    public PageResult<MeetingUiConfigDO> getPage(MeetingUiConfigPageReqVO pageReqVO) {
        return meetingUiConfigMapper.selectPage(pageReqVO);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void activate(Long id) {
        meetingUiConfigMapper.update(null, new LambdaUpdateWrapper<MeetingUiConfigDO>().set(MeetingUiConfigDO::getActive, false));
        meetingUiConfigMapper.updateById(new MeetingUiConfigDO().setId(id).setActive(true));
    }
}

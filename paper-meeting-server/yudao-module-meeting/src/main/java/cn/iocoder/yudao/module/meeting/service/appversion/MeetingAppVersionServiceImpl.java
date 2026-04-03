package cn.iocoder.yudao.module.meeting.service.appversion;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.appversion.vo.MeetingAppVersionCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.appversion.vo.MeetingAppVersionPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.appversion.vo.MeetingAppVersionUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.appversion.MeetingAppVersionDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.appversion.MeetingAppVersionMapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.annotation.Validated;

@Service
@Validated
public class MeetingAppVersionServiceImpl implements MeetingAppVersionService {

    @Resource
    private MeetingAppVersionMapper meetingAppVersionMapper;

    @Override
    public Long create(MeetingAppVersionCreateReqVO createReqVO) {
        MeetingAppVersionDO data = BeanUtils.toBean(createReqVO, MeetingAppVersionDO.class);
        if (data.getActive() == null) {
            data.setActive(false);
        }
        if (data.getForceUpdate() == null) {
            data.setForceUpdate(false);
        }
        meetingAppVersionMapper.insert(data);
        if (Boolean.TRUE.equals(data.getActive())) {
            activate(data.getId());
        }
        return data.getId();
    }

    @Override
    public void update(MeetingAppVersionUpdateReqVO updateReqVO) {
        meetingAppVersionMapper.updateById(BeanUtils.toBean(updateReqVO, MeetingAppVersionDO.class));
        if (Boolean.TRUE.equals(updateReqVO.getActive())) {
            activate(updateReqVO.getId());
        }
    }

    @Override
    public void delete(Long id) {
        meetingAppVersionMapper.deleteById(id);
    }

    @Override
    public MeetingAppVersionDO get(Long id) {
        return meetingAppVersionMapper.selectById(id);
    }

    @Override
    public PageResult<MeetingAppVersionDO> getPage(MeetingAppVersionPageReqVO pageReqVO) {
        return meetingAppVersionMapper.selectPage(pageReqVO);
    }

    @Override
    public MeetingAppVersionDO getActive(Integer clientType) {
        return meetingAppVersionMapper.selectOne(new LambdaQueryWrapperX<MeetingAppVersionDO>()
                .eq(MeetingAppVersionDO::getClientType, clientType)
                .eq(MeetingAppVersionDO::getActive, true)
                .orderByDesc(MeetingAppVersionDO::getVersionCode)
                .orderByDesc(MeetingAppVersionDO::getId)
                .last("limit 1"));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void activate(Long id) {
        MeetingAppVersionDO target = meetingAppVersionMapper.selectById(id);
        if (target == null) {
            return;
        }
        meetingAppVersionMapper.update(null, new LambdaUpdateWrapper<MeetingAppVersionDO>()
                .eq(MeetingAppVersionDO::getClientType, target.getClientType())
                .set(MeetingAppVersionDO::getActive, false));
        meetingAppVersionMapper.updateById(new MeetingAppVersionDO().setId(id).setActive(true));
    }
}

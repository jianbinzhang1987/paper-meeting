package cn.iocoder.yudao.module.meeting.service.publicfile;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFilePageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.publicfile.MeetingPublicFileDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.publicfile.MeetingPublicFileMapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

@Service
@Validated
public class MeetingPublicFileServiceImpl implements MeetingPublicFileService {

    @Resource
    private MeetingPublicFileMapper meetingPublicFileMapper;

    @Override
    public Long create(MeetingPublicFileCreateReqVO createReqVO) {
        MeetingPublicFileDO data = BeanUtils.toBean(createReqVO, MeetingPublicFileDO.class);
        if (data.getEnabled() == null) {
            data.setEnabled(true);
        }
        if (data.getSort() == null) {
            data.setSort(0);
        }
        meetingPublicFileMapper.insert(data);
        return data.getId();
    }

    @Override
    public void update(MeetingPublicFileUpdateReqVO updateReqVO) {
        meetingPublicFileMapper.updateById(BeanUtils.toBean(updateReqVO, MeetingPublicFileDO.class));
    }

    @Override
    public void delete(Long id) {
        meetingPublicFileMapper.deleteById(id);
    }

    @Override
    public MeetingPublicFileDO get(Long id) {
        return meetingPublicFileMapper.selectById(id);
    }

    @Override
    public PageResult<MeetingPublicFileDO> getPage(MeetingPublicFilePageReqVO pageReqVO) {
        return meetingPublicFileMapper.selectPage(pageReqVO);
    }
}

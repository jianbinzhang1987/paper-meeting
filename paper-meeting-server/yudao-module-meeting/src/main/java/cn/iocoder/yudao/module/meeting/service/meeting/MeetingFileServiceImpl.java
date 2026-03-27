package cn.iocoder.yudao.module.meeting.service.meeting;

import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingFileCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingFileExportVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingFileDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingFileMapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

import java.util.List;

@Service
@Validated
public class MeetingFileServiceImpl implements MeetingFileService {

    @Resource
    private MeetingFileMapper meetingFileMapper;

    @Override
    public Long createFile(MeetingFileCreateReqVO createReqVO) {
        MeetingFileDO fileDO = BeanUtils.toBean(createReqVO, MeetingFileDO.class);
        meetingFileMapper.insert(fileDO);
        return fileDO.getId();
    }

    @Override
    public void deleteFile(Long id) {
        meetingFileMapper.deleteById(id);
    }

    @Override
    public List<MeetingFileDO> getFileListByMeetingId(Long meetingId) {
        return meetingFileMapper.selectListByMeetingId(meetingId);
    }

    @Override
    public List<MeetingFileExportVO> getFileExportList(Long meetingId) {
        return BeanUtils.toBean(getFileListByMeetingId(meetingId), MeetingFileExportVO.class);
    }
}

package cn.iocoder.yudao.module.meeting.service.meeting;

import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingFileCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingFileExportVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingFileDO;
import java.util.List;

public interface MeetingFileService {
    Long createFile(MeetingFileCreateReqVO createReqVO);
    void deleteFile(Long id);
    List<MeetingFileDO> getFileListByMeetingId(Long meetingId);
    List<MeetingFileExportVO> getFileExportList(Long meetingId);
}

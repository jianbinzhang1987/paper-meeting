package cn.iocoder.yudao.module.meeting.service.meeting;

import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingDocumentMarkDO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingDocumentMarkExportVO;

import java.util.List;

public interface MeetingDocumentMarkService {

    List<MeetingDocumentMarkDO> getMarkList(Long meetingId, Long userId, Long documentId);

    MeetingDocumentMarkDO saveMark(Long meetingId, Long userId, Long documentId, Integer page, String type, String content);

    void deleteMark(Long id, Long userId);

    List<MeetingDocumentMarkExportVO> getMarkExportList(Long meetingId);
}

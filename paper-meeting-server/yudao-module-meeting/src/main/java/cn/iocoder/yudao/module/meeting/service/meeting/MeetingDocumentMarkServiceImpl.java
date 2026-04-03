package cn.iocoder.yudao.module.meeting.service.meeting;

import cn.iocoder.yudao.framework.common.util.collection.CollectionUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingDocumentMarkExportVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingDocumentMarkDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingFileDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingDocumentMarkMapper;
import cn.iocoder.yudao.module.meeting.dal.mysql.meeting.MeetingFileMapper;
import cn.iocoder.yudao.module.system.api.user.AdminUserApi;
import cn.iocoder.yudao.module.system.api.user.dto.AdminUserRespDTO;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
@Validated
public class MeetingDocumentMarkServiceImpl implements MeetingDocumentMarkService {

    @Resource
    private MeetingDocumentMarkMapper meetingDocumentMarkMapper;
    @Resource
    private MeetingFileMapper meetingFileMapper;
    @Resource
    private AdminUserApi adminUserApi;

    @Override
    public List<MeetingDocumentMarkDO> getMarkList(Long meetingId, Long userId, Long documentId) {
        return meetingDocumentMarkMapper.selectList(meetingId, userId, documentId);
    }

    @Override
    public MeetingDocumentMarkDO saveMark(Long meetingId, Long userId, Long documentId, Integer page, String type, String content) {
        MeetingDocumentMarkDO mark = new MeetingDocumentMarkDO();
        mark.setMeetingId(meetingId);
        mark.setUserId(userId);
        mark.setDocumentId(documentId);
        mark.setPage(page);
        mark.setType(type);
        mark.setContent(content);
        mark.setUpdatedAt(LocalDateTime.now());
        meetingDocumentMarkMapper.insert(mark);
        return mark;
    }

    @Override
    public void deleteMark(Long id, Long userId) {
        MeetingDocumentMarkDO mark = meetingDocumentMarkMapper.selectById(id);
        if (mark == null || !userId.equals(mark.getUserId())) {
            return;
        }
        meetingDocumentMarkMapper.deleteById(id);
    }

    @Override
    public List<MeetingDocumentMarkExportVO> getMarkExportList(Long meetingId) {
        List<MeetingDocumentMarkDO> marks = meetingDocumentMarkMapper.selectList(meetingId, null, null);
        Map<Long, MeetingFileDO> fileMap = CollectionUtils.convertMap(
                meetingFileMapper.selectListByMeetingId(meetingId), MeetingFileDO::getId);
        Map<Long, AdminUserRespDTO> userMap = adminUserApi.getUserMap(
                CollectionUtils.convertList(marks, MeetingDocumentMarkDO::getUserId));
        return CollectionUtils.convertList(marks, mark -> {
            MeetingDocumentMarkExportVO vo = new MeetingDocumentMarkExportVO();
            MeetingFileDO file = fileMap.get(mark.getDocumentId());
            AdminUserRespDTO user = userMap.get(mark.getUserId());
            vo.setDocumentName(file != null ? file.getName() : "资料#" + mark.getDocumentId());
            vo.setDocumentType(file != null ? file.getType() : "-");
            vo.setMarkType(resolveMarkType(mark.getType()));
            vo.setPage(mark.getPage());
            vo.setContent(mark.getContent());
            vo.setUserName(user != null ? user.getNickname() : "用户#" + mark.getUserId());
            vo.setUpdatedAt(mark.getUpdatedAt());
            return vo;
        });
    }

    private String resolveMarkType(String type) {
        if ("bookmark".equalsIgnoreCase(type)) {
            return "书签";
        }
        if ("note".equalsIgnoreCase(type)) {
            return "批注";
        }
        return type == null ? "-" : type;
    }
}

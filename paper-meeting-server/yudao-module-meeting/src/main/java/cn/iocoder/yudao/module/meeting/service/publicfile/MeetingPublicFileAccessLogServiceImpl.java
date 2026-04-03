package cn.iocoder.yudao.module.meeting.service.publicfile;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.common.util.object.BeanUtils;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileAccessLogPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileAccessLogReportReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileAccessLogRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileAccessSummaryRespVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.publicfile.MeetingPublicFileAccessLogDO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.publicfile.MeetingPublicFileDO;
import cn.iocoder.yudao.module.meeting.dal.mysql.publicfile.MeetingPublicFileAccessLogMapper;
import cn.iocoder.yudao.module.meeting.dal.mysql.publicfile.MeetingPublicFileMapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@Validated
public class MeetingPublicFileAccessLogServiceImpl implements MeetingPublicFileAccessLogService {

    @Resource
    private MeetingPublicFileAccessLogMapper accessLogMapper;
    @Resource
    private MeetingPublicFileMapper meetingPublicFileMapper;

    @Override
    public void reportAccess(MeetingPublicFileAccessLogReportReqVO reqVO) {
        MeetingPublicFileAccessLogDO data = BeanUtils.toBean(reqVO, MeetingPublicFileAccessLogDO.class);
        MeetingPublicFileDO file = meetingPublicFileMapper.selectById(reqVO.getFileId());
        data.setFileName(file != null ? file.getName() : "资料#" + reqVO.getFileId());
        accessLogMapper.insert(data);
    }

    @Override
    public PageResult<MeetingPublicFileAccessLogRespVO> getPage(MeetingPublicFileAccessLogPageReqVO reqVO) {
        PageResult<MeetingPublicFileAccessLogDO> page = accessLogMapper.selectPage(reqVO);
        return new PageResult<>(BeanUtils.toBean(page.getList(), MeetingPublicFileAccessLogRespVO.class), page.getTotal());
    }

    @Override
    public List<MeetingPublicFileAccessSummaryRespVO> getSummaryList(Collection<Long> fileIds) {
        Map<Long, MeetingPublicFileAccessSummaryRespVO> summaryMap = new HashMap<>();
        for (Long fileId : fileIds) {
            MeetingPublicFileAccessSummaryRespVO vo = new MeetingPublicFileAccessSummaryRespVO();
            vo.setFileId(fileId);
            vo.setViewCount(0L);
            vo.setOpenCount(0L);
            vo.setDownloadCount(0L);
            summaryMap.put(fileId, vo);
        }
        for (MeetingPublicFileAccessLogDO log : accessLogMapper.selectListByFileIds(fileIds)) {
            MeetingPublicFileAccessSummaryRespVO vo = summaryMap.get(log.getFileId());
            if (vo == null) {
                continue;
            }
            if ("view".equalsIgnoreCase(log.getAccessType())) {
                vo.setViewCount(vo.getViewCount() + 1);
            } else if ("download".equalsIgnoreCase(log.getAccessType())) {
                vo.setDownloadCount(vo.getDownloadCount() + 1);
            } else {
                vo.setOpenCount(vo.getOpenCount() + 1);
            }
            if (vo.getLastAccessTime() == null || (log.getCreateTime() != null && log.getCreateTime().isAfter(vo.getLastAccessTime()))) {
                vo.setLastAccessTime(log.getCreateTime());
            }
        }
        return summaryMap.values().stream().toList();
    }
}

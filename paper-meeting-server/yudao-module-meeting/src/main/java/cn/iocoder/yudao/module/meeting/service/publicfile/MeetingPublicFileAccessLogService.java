package cn.iocoder.yudao.module.meeting.service.publicfile;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileAccessLogPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileAccessLogReportReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileAccessLogRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileAccessSummaryRespVO;

import java.util.Collection;
import java.util.List;

public interface MeetingPublicFileAccessLogService {

    void reportAccess(MeetingPublicFileAccessLogReportReqVO reqVO);

    PageResult<MeetingPublicFileAccessLogRespVO> getPage(MeetingPublicFileAccessLogPageReqVO reqVO);

    List<MeetingPublicFileAccessSummaryRespVO> getSummaryList(Collection<Long> fileIds);
}

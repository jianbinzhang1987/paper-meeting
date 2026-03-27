package cn.iocoder.yudao.module.meeting.service.publicfile;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFilePageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo.MeetingPublicFileUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.publicfile.MeetingPublicFileDO;

public interface MeetingPublicFileService {

    Long create(MeetingPublicFileCreateReqVO createReqVO);

    void update(MeetingPublicFileUpdateReqVO updateReqVO);

    void delete(Long id);

    MeetingPublicFileDO get(Long id);

    PageResult<MeetingPublicFileDO> getPage(MeetingPublicFilePageReqVO pageReqVO);
}

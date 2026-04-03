package cn.iocoder.yudao.module.meeting.service.branding;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.meeting.controller.admin.branding.vo.MeetingBrandingCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.branding.vo.MeetingBrandingPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.branding.vo.MeetingBrandingUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.branding.MeetingBrandingDO;

public interface MeetingBrandingService {

    Long create(MeetingBrandingCreateReqVO createReqVO);

    void update(MeetingBrandingUpdateReqVO updateReqVO);

    void delete(Long id);

    MeetingBrandingDO get(Long id);

    PageResult<MeetingBrandingDO> getPage(MeetingBrandingPageReqVO pageReqVO);

    MeetingBrandingDO getActive();

    void activate(Long id);
}

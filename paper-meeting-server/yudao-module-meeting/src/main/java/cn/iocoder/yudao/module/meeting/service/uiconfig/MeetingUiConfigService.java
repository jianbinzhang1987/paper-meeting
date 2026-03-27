package cn.iocoder.yudao.module.meeting.service.uiconfig;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.meeting.controller.admin.uiconfig.vo.MeetingUiConfigCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.uiconfig.vo.MeetingUiConfigPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.uiconfig.vo.MeetingUiConfigUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.uiconfig.MeetingUiConfigDO;

public interface MeetingUiConfigService {

    Long create(MeetingUiConfigCreateReqVO createReqVO);

    void update(MeetingUiConfigUpdateReqVO updateReqVO);

    void delete(Long id);

    MeetingUiConfigDO get(Long id);

    PageResult<MeetingUiConfigDO> getPage(MeetingUiConfigPageReqVO pageReqVO);

    void activate(Long id);
}

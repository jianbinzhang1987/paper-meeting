package cn.iocoder.yudao.module.meeting.service.appversion;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.meeting.controller.admin.appversion.vo.MeetingAppVersionCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.appversion.vo.MeetingAppVersionPageReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.appversion.vo.MeetingAppVersionUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.appversion.MeetingAppVersionDO;

public interface MeetingAppVersionService {

    Long create(MeetingAppVersionCreateReqVO createReqVO);

    void update(MeetingAppVersionUpdateReqVO updateReqVO);

    void delete(Long id);

    MeetingAppVersionDO get(Long id);

    PageResult<MeetingAppVersionDO> getPage(MeetingAppVersionPageReqVO pageReqVO);

    MeetingAppVersionDO getActive(Integer clientType);

    void activate(Long id);
}

package cn.iocoder.yudao.module.meeting.convert.meeting;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.meeting.vo.MeetingUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingDO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

import java.util.List;

/**
 * 会议 Convert
 *
 * @author 芋道源码
 */
@Mapper
public interface MeetingConvert {

    MeetingConvert INSTANCE = Mappers.getMapper(MeetingConvert.class);

    MeetingDO convert(MeetingCreateReqVO bean);

    MeetingDO convert(MeetingUpdateReqVO bean);

    MeetingRespVO convert(MeetingDO bean);

    List<MeetingRespVO> convertList(List<MeetingDO> list);

    PageResult<MeetingRespVO> convertPage(PageResult<MeetingDO> page);

}

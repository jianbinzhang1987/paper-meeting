package cn.iocoder.yudao.module.meeting.convert.room;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.meeting.controller.admin.room.vo.MeetingRoomCreateReqVO;
import cn.iocoder.yudao.module.meeting.controller.admin.room.vo.MeetingRoomRespVO;
import cn.iocoder.yudao.module.meeting.controller.admin.room.vo.MeetingRoomUpdateReqVO;
import cn.iocoder.yudao.module.meeting.dal.dataobject.room.MeetingRoomDO;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

import java.util.List;

/**
 * 会议室 Convert
 *
 * @author 芋道源码
 */
@Mapper
public interface MeetingRoomConvert {

    MeetingRoomConvert INSTANCE = Mappers.getMapper(MeetingRoomConvert.class);

    MeetingRoomDO convert(MeetingRoomCreateReqVO bean);

    MeetingRoomDO convert(MeetingRoomUpdateReqVO bean);

    MeetingRoomRespVO convert(MeetingRoomDO bean);

    List<MeetingRoomRespVO> convertList(List<MeetingRoomDO> list);

    PageResult<MeetingRoomRespVO> convertPage(PageResult<MeetingRoomDO> page);

}

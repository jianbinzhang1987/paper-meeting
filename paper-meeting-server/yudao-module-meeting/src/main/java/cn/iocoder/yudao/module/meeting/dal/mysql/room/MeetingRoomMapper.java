package cn.iocoder.yudao.module.meeting.dal.mysql.room;

import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.module.meeting.dal.dataobject.room.MeetingRoomDO;
import org.apache.ibatis.annotations.Mapper;

/**
 * 会议室 Mapper
 *
 * @author 芋道源码
 */
@Mapper
public interface MeetingRoomMapper extends BaseMapperX<MeetingRoomDO> {

    default MeetingRoomDO selectByName(String name) {
        return selectOne(new LambdaQueryWrapperX<MeetingRoomDO>()
                .eq(MeetingRoomDO::getName, name));
    }

}

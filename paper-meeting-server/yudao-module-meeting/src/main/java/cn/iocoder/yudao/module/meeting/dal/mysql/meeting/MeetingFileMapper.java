package cn.iocoder.yudao.module.meeting.dal.mysql.meeting;

import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.module.meeting.dal.dataobject.meeting.MeetingFileDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

/**
 * 会议资料 Mapper
 *
 * @author 芋道源码
 */
@Mapper
public interface MeetingFileMapper extends BaseMapperX<MeetingFileDO> {

    default List<MeetingFileDO> selectListByMeetingId(Long meetingId) {
        return selectList(MeetingFileDO::getMeetingId, meetingId);
    }

}

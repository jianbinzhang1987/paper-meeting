package cn.iocoder.yudao.module.meeting.dal.mysql.terminal;

import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.module.meeting.dal.dataobject.terminal.MeetingTerminalStatusDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface MeetingTerminalStatusMapper extends BaseMapperX<MeetingTerminalStatusDO> {

    default MeetingTerminalStatusDO selectByTerminal(String roomName, String seatName, String deviceName) {
        return selectOne(new LambdaQueryWrapperX<MeetingTerminalStatusDO>()
                .eq(MeetingTerminalStatusDO::getRoomName, roomName)
                .eq(MeetingTerminalStatusDO::getSeatName, seatName)
                .eq(MeetingTerminalStatusDO::getDeviceName, deviceName)
                .orderByDesc(MeetingTerminalStatusDO::getId)
                .last("limit 1"));
    }

    default List<MeetingTerminalStatusDO> selectList(Integer clientType) {
        return selectList(new LambdaQueryWrapperX<MeetingTerminalStatusDO>()
                .eqIfPresent(MeetingTerminalStatusDO::getClientType, clientType)
                .orderByDesc(MeetingTerminalStatusDO::getLastHeartbeatTime)
                .orderByDesc(MeetingTerminalStatusDO::getId));
    }

    default List<MeetingTerminalStatusDO> selectListByMeetingId(Long meetingId, Integer clientType) {
        return selectList(new LambdaQueryWrapperX<MeetingTerminalStatusDO>()
                .eq(MeetingTerminalStatusDO::getMeetingId, meetingId)
                .eqIfPresent(MeetingTerminalStatusDO::getClientType, clientType)
                .orderByDesc(MeetingTerminalStatusDO::getLastHeartbeatTime)
                .orderByDesc(MeetingTerminalStatusDO::getId));
    }
}

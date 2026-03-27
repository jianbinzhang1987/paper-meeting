package cn.iocoder.yudao.module.meeting.enums;

import cn.iocoder.yudao.framework.common.exception.ErrorCode;

/**
 * Meeting 错误码枚举
 *
 * 会议模块，使用 1-002-000-000 段
 */
public interface ErrorCodeConstants {

    ErrorCode MEETING_ROOM_NOT_EXISTS = new ErrorCode(1002001000, "会议室不存在");
    ErrorCode MEETING_NOT_EXISTS = new ErrorCode(1002002000, "会议不存在");
    ErrorCode MEETING_TIME_CONFLICT = new ErrorCode(1002002001, "会议室在当前时间段已有预约或进行中的会议");
    ErrorCode MEETING_ATTENDEE_NOT_EXISTS = new ErrorCode(1002002002, "当前用户不在会议参会名单中");
    ErrorCode MEETING_PASSWORD_INVALID = new ErrorCode(1002002003, "会议密码不正确");
    ErrorCode MEETING_CONTROL_PERMISSION_DENIED = new ErrorCode(1002002004, "当前用户无权执行会议控制");

}

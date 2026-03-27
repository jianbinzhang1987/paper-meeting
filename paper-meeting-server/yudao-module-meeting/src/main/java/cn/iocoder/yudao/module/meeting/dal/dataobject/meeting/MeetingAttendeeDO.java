package cn.iocoder.yudao.module.meeting.dal.dataobject.meeting;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.*;

import java.time.LocalDateTime;

/**
 * 参会人员 DO
 *
 * @author 芋道源码
 */
@TableName("meeting_attendee")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MeetingAttendeeDO extends TenantBaseDO {

    /**
     * 编号
     */
    @TableId
    private Long id;
    /**
     * 会议编号
     */
    private Long meetingId;
    /**
     * 用户编号
     */
    private Long userId;
    /**
     * 角色
     *
     * 0与会人员 1主持人 2会议秘书
     */
    private Integer role;
    /**
     * 签到状态
     *
     * 0未签到 1已签到
     */
    private Integer status;
    /**
     * 签到时间
     */
    private LocalDateTime signInTime;
    /**
     * 座次编号
     */
    private String seatId;

}

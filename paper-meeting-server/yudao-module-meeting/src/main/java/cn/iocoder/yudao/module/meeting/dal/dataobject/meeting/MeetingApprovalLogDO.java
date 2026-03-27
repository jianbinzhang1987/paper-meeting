package cn.iocoder.yudao.module.meeting.dal.dataobject.meeting;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.*;

/**
 * 会议审批记录 DO
 */
@TableName("meeting_approval_log")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MeetingApprovalLogDO extends TenantBaseDO {

    @TableId
    private Long id;

    /**
     * 会议编号
     */
    private Long meetingId;

    /**
     * 操作类型
     *
     * 1 提交预约
     * 2 审批通过
     * 3 审批驳回
     * 4 撤销审核
     */
    private Integer action;

    /**
     * 操作人编号
     */
    private Long operatorId;

    /**
     * 操作人姓名
     */
    private String operatorName;

    /**
     * 审批意见
     */
    private String remark;
}

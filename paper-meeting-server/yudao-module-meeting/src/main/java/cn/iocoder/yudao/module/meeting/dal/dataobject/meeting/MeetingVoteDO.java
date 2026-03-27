package cn.iocoder.yudao.module.meeting.dal.dataobject.meeting;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.*;

/**
 * 会议表决 DO
 *
 * @author 芋道源码
 */
@TableName("meeting_vote")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MeetingVoteDO extends TenantBaseDO {

    /**
     * 表决编号
     */
    @TableId
    private Long id;
    /**
     * 会议编号
     */
    private Long meetingId;
    /**
     * 关联议题
     */
    private Long agendaId;
    /**
     * 表决标题
     */
    private String title;
    /**
     * 类型
     *
     * 0单选 1多选
     */
    private Integer type;
    /**
     * 是否匿名
     */
    private Boolean isSecret;
    /**
     * 状态
     *
     * 0未开始 1进行中 2已结束
     */
    private Integer status;

}

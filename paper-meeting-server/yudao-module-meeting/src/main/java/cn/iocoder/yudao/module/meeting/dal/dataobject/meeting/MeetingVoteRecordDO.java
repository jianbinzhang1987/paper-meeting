package cn.iocoder.yudao.module.meeting.dal.dataobject.meeting;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.*;

/**
 * 会议表决记录 DO
 *
 * @author 芋道源码
 */
@TableName("meeting_vote_record")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MeetingVoteRecordDO extends TenantBaseDO {

    /**
     * 记录编号
     */
    @TableId
    private Long id;
    /**
     * 表决编号
     */
    private Long voteId;
    /**
     * 用户编号
     */
    private Long userId;
    /**
     * 选项编号
     */
    private Long optionId;

}

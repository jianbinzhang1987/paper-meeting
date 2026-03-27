package cn.iocoder.yudao.module.meeting.dal.dataobject.meeting;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.*;

/**
 * 会议表决选项 DO
 *
 * @author 芋道源码
 */
@TableName("meeting_vote_option")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MeetingVoteOptionDO extends TenantBaseDO {

    /**
     * 选项编号
     */
    @TableId
    private Long id;
    /**
     * 表决编号
     */
    private Long voteId;
    /**
     * 选项内容
     */
    private String content;
    /**
     * 排序
     */
    private Integer sort;

}

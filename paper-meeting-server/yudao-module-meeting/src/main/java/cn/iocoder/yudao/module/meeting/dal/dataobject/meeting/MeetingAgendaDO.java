package cn.iocoder.yudao.module.meeting.dal.dataobject.meeting;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.*;

/**
 * 会议议题 DO
 *
 * @author 芋道源码
 */
@TableName("meeting_agenda")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MeetingAgendaDO extends TenantBaseDO {

    /**
     * 议题编号
     */
    @TableId
    private Long id;
    /**
     * 会议编号
     */
    private Long meetingId;
    /**
     * 父议题编号
     */
    private Long parentId;
    /**
     * 议题标题
     */
    private String title;
    /**
     * 议题内容
     */
    private String content;
    /**
     * 排序
     */
    private Integer sort;
    /**
     * 是否包含表决
     */
    private Boolean isVote;

}

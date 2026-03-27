package cn.iocoder.yudao.module.meeting.dal.dataobject.meeting;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.*;

import java.time.LocalDateTime;

/**
 * 会议 DO
 *
 * @author 芋道源码
 */
@TableName("meeting")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MeetingDO extends TenantBaseDO {

    /**
     * 会议编号
     */
    @TableId
    private Long id;
    /**
     * 会议名称
     */
    private String name;
    /**
     * 会议简述
     */
    private String description;
    /**
     * 开始时间
     */
    private LocalDateTime startTime;
    /**
     * 结束时间
     */
    private LocalDateTime endTime;
    /**
     * 会议室编号
     */
    private Long roomId;
    /**
     * 状态
     *
     * 0待发布 1待审批 2已预约 3进行中 4已结束 5已归档
     */
    private Integer status;
    /**
     * 类型
     *
     * 0即时 1预约 2模板
     */
    private Integer type;
    /**
     * 保密级别
     *
     * 0普通 1保密
     */
    private Integer level;
    /**
     * 控制方式
     *
     * 0秘书控制 1自由控制
     */
    private Integer controlType;
    /**
     * 是否需要审批
     */
    private Boolean requireApproval;
    /**
     * 会议密码
     */
    private String password;
    /**
     * 是否添加水印
     */
    private Boolean watermark;
    /**
     * 会议记录
     */
    private String summary;
    /**
     * 归档时间
     */
    private LocalDateTime archiveTime;

}

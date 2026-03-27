package cn.iocoder.yudao.module.meeting.dal.dataobject.room;

import cn.iocoder.yudao.framework.common.enums.CommonStatusEnum;
import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.*;

/**
 * 会议室 DO
 *
 * @author 芋道源码
 */
@TableName("meeting_room")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MeetingRoomDO extends TenantBaseDO {

    /**
     * 房间编号
     */
    @TableId
    private Long id;
    /**
     * 房间名称
     */
    private String name;
    /**
     * 所在位置
     */
    private String location;
    /**
     * 容纳人数
     */
    private Integer capacity;
    /**
     * 状态
     *
     * 枚举 {@link CommonStatusEnum}
     */
    private Integer status;
    /**
     * 座位配置(JSON)
     */
    private String config;

}

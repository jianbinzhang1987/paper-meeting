package cn.iocoder.yudao.module.meeting.dal.dataobject.terminal;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import java.time.LocalDateTime;

@TableName("meeting_terminal_status")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingTerminalStatusDO extends TenantBaseDO {

    @TableId
    private Long id;

    private Integer clientType;

    private String roomName;

    private String seatName;

    private String deviceName;

    private Long meetingId;

    private String meetingName;

    private Long userId;

    private String userName;

    private String themeMode;

    private String connectionStatus;

    private Long appVersionId;

    private String appVersionName;

    private Integer appVersionCode;

    private Long uiConfigId;

    private String uiConfigName;

    private Long brandingId;

    private String brandingName;

    private LocalDateTime lastBootstrapTime;

    private LocalDateTime lastHeartbeatTime;
}

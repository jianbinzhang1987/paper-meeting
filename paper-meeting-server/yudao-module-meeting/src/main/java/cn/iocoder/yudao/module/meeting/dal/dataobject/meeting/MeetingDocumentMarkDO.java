package cn.iocoder.yudao.module.meeting.dal.dataobject.meeting;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import java.time.LocalDateTime;

@TableName("meeting_document_mark")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class MeetingDocumentMarkDO extends TenantBaseDO {

    @TableId
    private Long id;

    private Long meetingId;

    private Long userId;

    private Long documentId;

    private Integer page;

    private String type;

    private String content;

    private LocalDateTime updatedAt;
}

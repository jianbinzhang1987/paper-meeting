package cn.iocoder.yudao.module.meeting.dal.dataobject.meeting;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.*;

/**
 * 会议资料 DO
 *
 * @author 芋道源码
 */
@TableName("meeting_file")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MeetingFileDO extends TenantBaseDO {

    /**
     * 文件编号
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
     * 文件名称
     */
    private String name;
    /**
     * 文件路径
     */
    private String url;
    /**
     * 文件类型
     */
    private String type;
    /**
     * 文件摘要
     */
    private String summary;
    /**
     * 文稿页数
     */
    private Integer pageCount;
    /**
     * 缩略图地址
     */
    private String thumbnailUrl;
    /**
     * 文件大小
     */
    private Long size;

}

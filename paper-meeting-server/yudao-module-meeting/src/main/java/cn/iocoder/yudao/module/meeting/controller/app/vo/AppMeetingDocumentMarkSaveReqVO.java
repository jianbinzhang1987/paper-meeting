package cn.iocoder.yudao.module.meeting.controller.app.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Schema(description = "客户端 - 文稿标记保存 Request VO")
@Data
public class AppMeetingDocumentMarkSaveReqVO {

    @NotNull(message = "会议编号不能为空")
    private Long meetingId;

    @NotNull(message = "用户编号不能为空")
    private Long userId;

    @NotNull(message = "文稿编号不能为空")
    private Long documentId;

    @NotNull(message = "页码不能为空")
    private Integer page;

    @NotBlank(message = "标记类型不能为空")
    private String type;

    @NotBlank(message = "标记内容不能为空")
    private String content;
}

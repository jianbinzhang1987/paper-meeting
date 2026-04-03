package cn.iocoder.yudao.module.meeting.controller.app.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Schema(description = "客户端 - 文稿标记删除 Request VO")
@Data
public class AppMeetingDocumentMarkDeleteReqVO {

    @NotNull(message = "标记编号不能为空")
    private Long id;

    @NotNull(message = "用户编号不能为空")
    private Long userId;
}

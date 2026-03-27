package cn.iocoder.yudao.module.meeting.controller.app.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Schema(description = "客户端 - 提交签名 Request VO")
@Data
public class AppMeetingSignatureSubmitReqVO {

    @Schema(description = "会议编号", requiredMode = Schema.RequiredMode.REQUIRED, example = "1")
    @NotNull(message = "会议编号不能为空")
    private Long meetingId;

    @Schema(description = "用户编号", requiredMode = Schema.RequiredMode.REQUIRED, example = "2001")
    @NotNull(message = "用户编号不能为空")
    private Long userId;

    @Schema(description = "签名图片 Base64", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank(message = "签名图片不能为空")
    private String imageBase64;

    @Schema(description = "笔迹点数量", example = "128")
    private Integer strokeCount;
}

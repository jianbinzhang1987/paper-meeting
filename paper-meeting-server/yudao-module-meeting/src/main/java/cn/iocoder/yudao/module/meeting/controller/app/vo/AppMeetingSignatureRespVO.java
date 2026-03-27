package cn.iocoder.yudao.module.meeting.controller.app.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Schema(description = "客户端 - 签名 Response VO")
@Data
public class AppMeetingSignatureRespVO {

    @Schema(description = "签名编号", example = "1")
    private Long id;

    @Schema(description = "会议编号", example = "1")
    private Long meetingId;

    @Schema(description = "用户编号", example = "2001")
    private Long userId;

    @Schema(description = "座位号")
    private String seatId;

    @Schema(description = "签名文件地址")
    private String fileUrl;

    @Schema(description = "笔迹点数量", example = "128")
    private Integer strokeCount;

    @Schema(description = "提交时间")
    private LocalDateTime submitTime;
}

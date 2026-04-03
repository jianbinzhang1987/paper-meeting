package cn.iocoder.yudao.module.meeting.controller.app.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Schema(description = "客户端 - 文稿标记 Response VO")
@Data
public class AppMeetingDocumentMarkRespVO {

    private Long id;

    private Long meetingId;

    private Long userId;

    private Long documentId;

    private Integer page;

    private String type;

    private String content;

    private LocalDateTime updatedAt;
}

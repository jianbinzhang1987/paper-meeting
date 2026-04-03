package cn.iocoder.yudao.module.meeting.controller.app.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Schema(description = "客户端 - 通知 Response VO")
@Data
public class AppMeetingNoticeRespVO {

    private Long id;

    private String title;

    private String content;

    private Boolean read;

    private LocalDateTime publishedTime;

    private LocalDateTime createTime;
}

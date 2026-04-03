package cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class MeetingPublicFileAccessSummaryRespVO {

    private Long fileId;

    private Long viewCount;

    private Long openCount;

    private Long downloadCount;

    private LocalDateTime lastAccessTime;
}

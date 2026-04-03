package cn.iocoder.yudao.module.meeting.controller.admin.publicfile.vo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class MeetingPublicFileAccessLogRespVO {

    private Long id;

    private Long fileId;

    private String fileName;

    private String accessType;

    private String source;

    private String operatorName;

    private LocalDateTime createTime;
}

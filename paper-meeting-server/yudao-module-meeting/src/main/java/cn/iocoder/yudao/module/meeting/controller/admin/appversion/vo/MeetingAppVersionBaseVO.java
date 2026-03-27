package cn.iocoder.yudao.module.meeting.controller.admin.appversion.vo;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class MeetingAppVersionBaseVO {

    @NotNull(message = "客户端类型不能为空")
    private Integer clientType;

    @NotNull(message = "安装包名称不能为空")
    private String name;

    @NotNull(message = "版本名称不能为空")
    private String versionName;

    @NotNull(message = "版本号不能为空")
    private Integer versionCode;

    @NotNull(message = "下载地址不能为空")
    private String downloadUrl;

    private String md5;

    private Boolean forceUpdate;

    private Boolean active;

    private String remark;
}

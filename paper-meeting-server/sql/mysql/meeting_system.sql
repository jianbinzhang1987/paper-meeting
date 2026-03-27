-- Meeting System SQL Schema

-- ----------------------------
-- Table structure for meeting_room
-- ----------------------------
DROP TABLE IF EXISTS `meeting_room`;
CREATE TABLE `meeting_room` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '房间编号',
  `name` varchar(100) NOT NULL COMMENT '房间名称',
  `location` varchar(255) DEFAULT NULL COMMENT '所在位置',
  `capacity` int DEFAULT 0 COMMENT '容纳人数',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态（0可用 1停用）',
  `config` text COMMENT '座位配置(JSON)',
  `creator` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT '0' COMMENT '租户编号',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会议室表';

-- ----------------------------
-- Table structure for meeting
-- ----------------------------
DROP TABLE IF EXISTS `meeting`;
CREATE TABLE `meeting` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '会议编号',
  `name` varchar(200) NOT NULL COMMENT '会议名称',
  `description` text COMMENT '会议简述',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NOT NULL COMMENT '结束时间',
  `room_id` bigint DEFAULT NULL COMMENT '会议室编号',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态（0待发布 1待审批 2已预约 3进行中 4已结束 5已归档）',
  `type` tinyint NOT NULL DEFAULT 0 COMMENT '类型（0即时 1预约 2模板）',
  `level` tinyint NOT NULL DEFAULT 0 COMMENT '保密级别（0普通 1保密）',
  `control_type` tinyint NOT NULL DEFAULT 0 COMMENT '控制方式（0秘书控制 1自由控制）',
  `require_approval` bit(1) NOT NULL DEFAULT b'1' COMMENT '是否需要审批',
  `password` varchar(100) DEFAULT NULL COMMENT '会议密码',
  `watermark` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否添加水印',
  `summary` text COMMENT '会议记录',
  `archive_time` datetime DEFAULT NULL COMMENT '归档时间',
  `creator` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT '0' COMMENT '租户编号',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会议基本信息表';

-- ----------------------------
-- Table structure for meeting_agenda
-- ----------------------------
DROP TABLE IF EXISTS `meeting_agenda`;
CREATE TABLE `meeting_agenda` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '议题编号',
  `meeting_id` bigint NOT NULL COMMENT '会议编号',
  `parent_id` bigint DEFAULT 0 COMMENT '父议题编号',
  `title` varchar(200) NOT NULL COMMENT '议题标题',
  `content` text COMMENT '议题内容',
  `sort` int DEFAULT 0 COMMENT '排序',
  `is_vote` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否包含表决',
  `creator` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT '0' COMMENT '租户编号',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会议议题表';

-- ----------------------------
-- Table structure for meeting_approval_log
-- ----------------------------
DROP TABLE IF EXISTS `meeting_approval_log`;
CREATE TABLE `meeting_approval_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `meeting_id` bigint NOT NULL COMMENT '会议编号',
  `action` tinyint NOT NULL COMMENT '操作类型（1提交预约 2审批通过 3审批驳回 4撤销审核）',
  `operator_id` bigint DEFAULT NULL COMMENT '操作人编号',
  `operator_name` varchar(64) DEFAULT NULL COMMENT '操作人姓名',
  `remark` varchar(500) DEFAULT NULL COMMENT '审批意见',
  `creator` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT '0' COMMENT '租户编号',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会议审批记录表';

-- ----------------------------
-- Table structure for meeting_attendee
-- ----------------------------
DROP TABLE IF EXISTS `meeting_attendee`;
CREATE TABLE `meeting_attendee` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `meeting_id` bigint NOT NULL COMMENT '会议编号',
  `user_id` bigint NOT NULL COMMENT '用户编号',
  `role` tinyint NOT NULL DEFAULT 0 COMMENT '角色（0与会人员 1主持人 2会议秘书）',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '签到状态（0未签到 1已签到）',
  `sign_in_time` datetime DEFAULT NULL COMMENT '签到时间',
  `seat_id` varchar(50) DEFAULT NULL COMMENT '座次编号',
  `creator` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT '0' COMMENT '租户编号',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='参会人员表';

-- ----------------------------
-- Table structure for meeting_file
-- ----------------------------
DROP TABLE IF EXISTS `meeting_file`;
CREATE TABLE `meeting_file` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '文件编号',
  `meeting_id` bigint NOT NULL COMMENT '会议编号',
  `agenda_id` bigint DEFAULT NULL COMMENT '关联议题',
  `name` varchar(255) NOT NULL COMMENT '文件名称',
  `url` varchar(512) NOT NULL COMMENT '文件路径',
  `type` varchar(50) DEFAULT NULL COMMENT '文件类型',
  `size` bigint DEFAULT 0 COMMENT '文件大小',
  `creator` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT '0' COMMENT '租户编号',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会议资料表';

-- ----------------------------
-- Table structure for meeting_vote
-- ----------------------------
DROP TABLE IF EXISTS `meeting_vote`;
CREATE TABLE `meeting_vote` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '表决编号',
  `meeting_id` bigint NOT NULL COMMENT '会议编号',
  `agenda_id` bigint DEFAULT NULL COMMENT '关联议题',
  `title` varchar(200) NOT NULL COMMENT '表决标题',
  `type` tinyint NOT NULL DEFAULT 0 COMMENT '类型（0单选 1多选）',
  `is_secret` bit(1) NOT NULL DEFAULT b'1' COMMENT '是否匿名',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态（0未开始 1进行中 2已结束）',
  `creator` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT '0' COMMENT '租户编号',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会议表决表';

-- ----------------------------
-- Table structure for meeting_vote_option
-- ----------------------------
DROP TABLE IF EXISTS `meeting_vote_option`;
CREATE TABLE `meeting_vote_option` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '选项编号',
  `vote_id` bigint NOT NULL COMMENT '表决编号',
  `content` varchar(255) NOT NULL COMMENT '选项内容',
  `sort` int DEFAULT 0 COMMENT '排序',
  `creator` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT '0' COMMENT '租户编号',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会议表决选项表';

-- ----------------------------
-- Table structure for meeting_vote_record
-- ----------------------------
DROP TABLE IF EXISTS `meeting_vote_record`;
CREATE TABLE `meeting_vote_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录编号',
  `vote_id` bigint NOT NULL COMMENT '表决编号',
  `user_id` bigint NOT NULL COMMENT '用户编号',
  `option_id` bigint NOT NULL COMMENT '选项编号',
  `creator` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT '0' COMMENT '租户编号',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会议表决记录表';

-- ----------------------------
-- Table structure for meeting_notification
-- ----------------------------
DROP TABLE IF EXISTS `meeting_notification`;
CREATE TABLE `meeting_notification` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '通知编号',
  `meeting_id` bigint NOT NULL COMMENT '会议编号',
  `content` text NOT NULL COMMENT '通知内容',
  `publish_status` tinyint NOT NULL DEFAULT 0 COMMENT '发布状态（0草稿 1已发布）',
  `published_time` datetime DEFAULT NULL COMMENT '发布时间',
  `creator` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT '0' COMMENT '租户编号',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会议消息通知表';

-- ----------------------------
-- Table structure for meeting_public_file
-- ----------------------------
DROP TABLE IF EXISTS `meeting_public_file`;
CREATE TABLE `meeting_public_file` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '资料编号',
  `category` varchar(100) NOT NULL COMMENT '资料分类',
  `name` varchar(255) NOT NULL COMMENT '资料名称',
  `url` varchar(512) NOT NULL COMMENT '资料地址',
  `file_type` varchar(50) DEFAULT NULL COMMENT '资料类型',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序号',
  `enabled` bit(1) NOT NULL DEFAULT b'1' COMMENT '是否启用',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `creator` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT '0' COMMENT '租户编号',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='公共资料库表';

-- ----------------------------
-- Table structure for meeting_ui_config
-- ----------------------------
DROP TABLE IF EXISTS `meeting_ui_config`;
CREATE TABLE `meeting_ui_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '样式编号',
  `name` varchar(100) NOT NULL COMMENT '样式名称',
  `font_size` int NOT NULL DEFAULT 16 COMMENT '基础字号',
  `primary_color` varchar(20) NOT NULL COMMENT '主色',
  `accent_color` varchar(20) DEFAULT NULL COMMENT '辅助色',
  `background_image_url` varchar(512) DEFAULT NULL COMMENT '背景图地址',
  `logo_url` varchar(512) DEFAULT NULL COMMENT 'Logo 地址',
  `extra_css` text COMMENT '扩展样式',
  `active` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否已启用',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `creator` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT '0' COMMENT '租户编号',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='客户端样式配置表';

-- ----------------------------
-- Table structure for meeting_app_version
-- ----------------------------
DROP TABLE IF EXISTS `meeting_app_version`;
CREATE TABLE `meeting_app_version` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '安装包编号',
  `client_type` tinyint NOT NULL COMMENT '客户端类型（1安卓客户端 2呼叫服务端 3大屏端 4信息发布端）',
  `name` varchar(100) NOT NULL COMMENT '安装包名称',
  `version_name` varchar(50) NOT NULL COMMENT '版本名称',
  `version_code` int NOT NULL COMMENT '版本号',
  `download_url` varchar(512) NOT NULL COMMENT '下载地址',
  `md5` varchar(64) DEFAULT NULL COMMENT 'MD5',
  `force_update` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否强制更新',
  `active` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否当前启用',
  `remark` varchar(500) DEFAULT NULL COMMENT '更新说明',
  `creator` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT '0' COMMENT '租户编号',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='安装包版本管理表';

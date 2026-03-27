-- 会议模块表结构增量补丁
-- 适用于基础会议表已存在，但扩展字段/扩展表未导入的环境

SET @ddl = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE `meeting` ADD COLUMN `control_type` tinyint NOT NULL DEFAULT 0 COMMENT ''控制方式（0秘书控制 1自由控制）'' AFTER `level`',
        'SELECT 1'
    )
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'meeting' AND column_name = 'control_type'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE `meeting` ADD COLUMN `require_approval` bit(1) NOT NULL DEFAULT b''1'' COMMENT ''是否需要审批'' AFTER `control_type`',
        'SELECT 1'
    )
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'meeting' AND column_name = 'require_approval'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE `meeting` ADD COLUMN `summary` text COMMENT ''会议记录'' AFTER `watermark`',
        'SELECT 1'
    )
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'meeting' AND column_name = 'summary'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE `meeting` ADD COLUMN `archive_time` datetime DEFAULT NULL COMMENT ''归档时间'' AFTER `summary`',
        'SELECT 1'
    )
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'meeting' AND column_name = 'archive_time'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

CREATE TABLE IF NOT EXISTS `meeting_notification` (
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

CREATE TABLE IF NOT EXISTS `meeting_public_file` (
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

CREATE TABLE IF NOT EXISTS `meeting_ui_config` (
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

CREATE TABLE IF NOT EXISTS `meeting_app_version` (
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

CREATE TABLE IF NOT EXISTS `meeting_signature` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '签名编号',
  `meeting_id` bigint NOT NULL COMMENT '会议编号',
  `user_id` bigint NOT NULL COMMENT '用户编号',
  `seat_id` varchar(64) DEFAULT NULL COMMENT '座位号',
  `file_url` varchar(512) NOT NULL COMMENT '签名文件地址',
  `stroke_count` int DEFAULT 0 COMMENT '笔迹点数量',
  `submit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  `creator` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `tenant_id` bigint NOT NULL DEFAULT '0' COMMENT '租户编号',
  PRIMARY KEY (`id`),
  KEY `idx_meeting_signature_meeting_user` (`meeting_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会议签名记录表';

SET @ddl = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE `meeting_file` ADD COLUMN `summary` varchar(1000) DEFAULT NULL COMMENT ''文件摘要'' AFTER `type`',
        'SELECT 1'
    )
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'meeting_file' AND column_name = 'summary'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE `meeting_file` ADD COLUMN `page_count` int DEFAULT 1 COMMENT ''页数'' AFTER `summary`',
        'SELECT 1'
    )
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'meeting_file' AND column_name = 'page_count'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @ddl = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE `meeting_file` ADD COLUMN `thumbnail_url` varchar(512) DEFAULT NULL COMMENT ''缩略图地址'' AFTER `page_count`',
        'SELECT 1'
    )
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'meeting_file' AND column_name = 'thumbnail_url'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

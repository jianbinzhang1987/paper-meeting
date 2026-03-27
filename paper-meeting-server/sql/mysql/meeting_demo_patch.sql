-- 会议模块字典与演示数据补丁
-- 适用于表结构已存在，但初始化演示数据未导入成功的环境

SET @tenant_id := 1;
SET @creator := 'admin';

START TRANSACTION;

INSERT INTO `system_dict_type`
(`name`, `type`, `status`, `remark`, `creator`, `create_time`, `updater`, `update_time`, `deleted`)
SELECT '客户端类型', 'meeting_client_type', 0, '会议客户端安装包类型', @creator, NOW(), @creator, NOW(), b'0'
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `system_dict_type` WHERE `type` = 'meeting_client_type' AND `deleted` = b'0'
);

INSERT INTO `system_dict_data`
(`sort`, `label`, `value`, `dict_type`, `status`, `color_type`, `css_class`, `remark`, `creator`, `create_time`, `updater`, `update_time`, `deleted`)
SELECT s.`sort`, s.`label`, s.`value`, 'meeting_client_type', 0, s.`color_type`, '', '', @creator, NOW(), @creator, NOW(), b'0'
FROM (
    SELECT 1 AS `sort`, '安卓客户端' AS `label`, '1' AS `value`, 'primary' AS `color_type`
    UNION ALL SELECT 2, '呼叫服务端', '2', 'warning'
    UNION ALL SELECT 3, '大屏端', '3', 'success'
    UNION ALL SELECT 4, '信息发布端', '4', 'info'
) s
LEFT JOIN `system_dict_data` d ON d.`dict_type` = 'meeting_client_type' AND d.`value` = s.`value` AND d.`deleted` = b'0'
WHERE d.`id` IS NULL;

INSERT INTO `meeting_room`
(`name`, `location`, `capacity`, `status`, `config`, `creator`, `create_time`, `updater`, `update_time`, `deleted`, `tenant_id`)
SELECT '第一会议室（演示）', '总部 3F A301', 24, 0, '{"layout":"u-shape","seats":24}', @creator, NOW(), @creator, NOW(), b'0', @tenant_id
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `meeting_room` WHERE `name` = '第一会议室（演示）' AND `tenant_id` = @tenant_id AND `deleted` = b'0'
);

INSERT INTO `meeting_room`
(`name`, `location`, `capacity`, `status`, `config`, `creator`, `create_time`, `updater`, `update_time`, `deleted`, `tenant_id`)
SELECT '第二会议室（演示）', '总部 5F B501', 16, 0, '{"layout":"classroom","seats":16}', @creator, NOW(), @creator, NOW(), b'0', @tenant_id
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `meeting_room` WHERE `name` = '第二会议室（演示）' AND `tenant_id` = @tenant_id AND `deleted` = b'0'
);

SET @demo_room_a_id := (
    SELECT `id` FROM `meeting_room`
    WHERE `name` = '第一会议室（演示）' AND `tenant_id` = @tenant_id AND `deleted` = b'0'
    ORDER BY `id` LIMIT 1
);

SET @demo_room_b_id := (
    SELECT `id` FROM `meeting_room`
    WHERE `name` = '第二会议室（演示）' AND `tenant_id` = @tenant_id AND `deleted` = b'0'
    ORDER BY `id` LIMIT 1
);

INSERT INTO `meeting`
(`name`, `description`, `start_time`, `end_time`, `room_id`, `status`, `type`, `level`, `control_type`, `require_approval`, `password`, `watermark`, `summary`, `archive_time`, `creator`, `create_time`, `updater`, `update_time`, `deleted`, `tenant_id`)
SELECT
    '季度经营分析会模板',
    '演示模板，可直接复制生成正式会议',
    '2026-04-01 09:00:00',
    '2026-04-01 11:00:00',
    @demo_room_a_id,
    0,
    2,
    0,
    0,
    b'1',
    NULL,
    b'1',
    '模板包含标准议程、资料上传和投票环节。',
    NULL,
    @creator,
    NOW(),
    @creator,
    NOW(),
    b'0',
    @tenant_id
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `meeting`
    WHERE `name` = '季度经营分析会模板' AND `tenant_id` = @tenant_id AND `deleted` = b'0'
);

INSERT INTO `meeting`
(`name`, `description`, `start_time`, `end_time`, `room_id`, `status`, `type`, `level`, `control_type`, `require_approval`, `password`, `watermark`, `summary`, `archive_time`, `creator`, `create_time`, `updater`, `update_time`, `deleted`, `tenant_id`)
SELECT
    '管理端功能联调会（演示）',
    '用于演示预约审批、消息发布、资料下发与客户端样式联动',
    '2026-04-08 14:00:00',
    '2026-04-08 16:00:00',
    @demo_room_b_id,
    2,
    1,
    0,
    0,
    b'1',
    '123456',
    b'1',
    '会后自动沉淀会议纪要并归档资料。',
    NULL,
    @creator,
    NOW(),
    @creator,
    NOW(),
    b'0',
    @tenant_id
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `meeting`
    WHERE `name` = '管理端功能联调会（演示）' AND `tenant_id` = @tenant_id AND `deleted` = b'0'
);

SET @demo_meeting_id := (
    SELECT `id` FROM `meeting`
    WHERE `name` = '管理端功能联调会（演示）' AND `tenant_id` = @tenant_id AND `deleted` = b'0'
    ORDER BY `id` LIMIT 1
);

INSERT INTO `meeting_notification`
(`meeting_id`, `content`, `publish_status`, `published_time`, `creator`, `create_time`, `updater`, `update_time`, `deleted`, `tenant_id`)
SELECT @demo_meeting_id, '请参会人员提前 10 分钟入场，移动终端登录后先完成签到。', 1, NOW(), @creator, NOW(), @creator, NOW(), b'0', @tenant_id
FROM DUAL
WHERE @demo_meeting_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM `meeting_notification`
      WHERE `meeting_id` = @demo_meeting_id AND `content` = '请参会人员提前 10 分钟入场，移动终端登录后先完成签到。' AND `deleted` = b'0'
  );

INSERT INTO `meeting_public_file`
(`category`, `name`, `url`, `file_type`, `sort`, `enabled`, `remark`, `creator`, `create_time`, `updater`, `update_time`, `deleted`, `tenant_id`)
SELECT '制度文件', '无纸化会议终端操作指南.pdf', 'https://example.com/files/meeting-terminal-guide.pdf', 'pdf', 1, b'1', '初始化演示资料', @creator, NOW(), @creator, NOW(), b'0', @tenant_id
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `meeting_public_file`
    WHERE `name` = '无纸化会议终端操作指南.pdf' AND `tenant_id` = @tenant_id AND `deleted` = b'0'
);

INSERT INTO `meeting_ui_config`
(`name`, `font_size`, `primary_color`, `accent_color`, `background_image_url`, `logo_url`, `extra_css`, `active`, `remark`, `creator`, `create_time`, `updater`, `update_time`, `deleted`, `tenant_id`)
SELECT '政务蓝标准主题', 18, '#1f4ba5', '#4f83ff', 'https://example.com/assets/meeting-bg-blue.jpg', 'https://example.com/assets/meeting-logo.png', '.meeting-header{letter-spacing:1px;}', b'1', '初始化演示主题', @creator, NOW(), @creator, NOW(), b'0', @tenant_id
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `meeting_ui_config`
    WHERE `name` = '政务蓝标准主题' AND `tenant_id` = @tenant_id AND `deleted` = b'0'
);

UPDATE `meeting_ui_config`
SET `active` = CASE WHEN `name` = '政务蓝标准主题' THEN b'1' ELSE b'0' END,
    `updater` = @creator,
    `update_time` = NOW()
WHERE `tenant_id` = @tenant_id
  AND `deleted` = b'0'
  AND (`active` = b'1' OR `name` = '政务蓝标准主题');

INSERT INTO `meeting_app_version`
(`client_type`, `name`, `version_name`, `version_code`, `download_url`, `md5`, `force_update`, `active`, `remark`, `creator`, `create_time`, `updater`, `update_time`, `deleted`, `tenant_id`)
SELECT 1, '安卓客户端安装包', 'v1.0.0', 100, 'https://example.com/apk/meeting-client-v1.0.0.apk', '0123456789abcdef0123456789abcdef', b'0', b'1', '初始化演示版本', @creator, NOW(), @creator, NOW(), b'0', @tenant_id
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `meeting_app_version`
    WHERE `client_type` = 1 AND `version_code` = 100 AND `tenant_id` = @tenant_id AND `deleted` = b'0'
);

UPDATE `meeting_app_version`
SET `active` = CASE WHEN `client_type` = 1 AND `version_code` = 100 THEN b'1' ELSE b'0' END,
    `updater` = @creator,
    `update_time` = NOW()
WHERE `tenant_id` = @tenant_id
  AND `deleted` = b'0'
  AND `client_type` = 1
  AND (`active` = b'1' OR `version_code` = 100);

COMMIT;

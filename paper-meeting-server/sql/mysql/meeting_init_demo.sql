-- 会议系统初始化脚本（菜单 + 字典 + 角色授权 + 演示数据）
-- 默认租户：1。如需其它租户，请修改 @tenant_id。
-- 建议执行顺序：ruoyi-vue-pro.sql -> meeting_system.sql -> 本脚本

SET @tenant_id := 1;
SET @creator := 'admin';

START TRANSACTION;

INSERT INTO `system_dict_type` (`name`, `type`, `status`, `remark`, `creator`, `create_time`, `updater`, `update_time`, `deleted`)
SELECT s.`name`, s.`type`, 0, s.`remark`, @creator, NOW(), @creator, NOW(), b'0'
FROM (
    SELECT '会议状态' AS `name`, 'meeting_status' AS `type`, '会议生命周期状态' AS `remark`
    UNION ALL
    SELECT '客户端类型', 'meeting_client_type', '会议客户端安装包类型'
) s
LEFT JOIN `system_dict_type` t ON t.`type` = s.`type` AND t.`deleted` = b'0'
WHERE t.`id` IS NULL;

INSERT INTO `system_dict_data` (`sort`, `label`, `value`, `dict_type`, `status`, `color_type`, `css_class`, `remark`, `creator`, `create_time`, `updater`, `update_time`, `deleted`)
SELECT s.`sort`, s.`label`, s.`value`, s.`dict_type`, 0, s.`color_type`, '', '', @creator, NOW(), @creator, NOW(), b'0'
FROM (
    SELECT 1 AS `sort`, '待发布' AS `label`, '0' AS `value`, 'meeting_status' AS `dict_type`, 'info' AS `color_type`
    UNION ALL SELECT 2, '待审批', '1', 'meeting_status', 'warning'
    UNION ALL SELECT 3, '已预约', '2', 'meeting_status', 'success'
    UNION ALL SELECT 4, '进行中', '3', 'meeting_status', 'primary'
    UNION ALL SELECT 5, '已结束', '4', 'meeting_status', 'danger'
    UNION ALL SELECT 6, '已归档', '5', 'meeting_status', 'success'
    UNION ALL SELECT 1, '安卓客户端', '1', 'meeting_client_type', 'primary'
    UNION ALL SELECT 2, '呼叫服务端', '2', 'meeting_client_type', 'warning'
    UNION ALL SELECT 3, '大屏端', '3', 'meeting_client_type', 'success'
    UNION ALL SELECT 4, '信息发布端', '4', 'meeting_client_type', 'info'
) s
LEFT JOIN `system_dict_data` d ON d.`dict_type` = s.`dict_type` AND d.`value` = s.`value` AND d.`deleted` = b'0'
WHERE d.`id` IS NULL;

INSERT INTO `system_menu` (`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `component_name`, `status`, `visible`, `keep_alive`, `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`)
SELECT '会议系统', '', 1, 10, 0, '/meeting', 'ep:calendar', NULL, NULL, 0, b'1', b'1', b'1', @creator, NOW(), @creator, NOW(), b'0'
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `system_menu` WHERE `parent_id` = 0 AND `path` = '/meeting' AND `deleted` = b'0'
);

SET @meeting_root_id := (
    SELECT `id` FROM `system_menu`
    WHERE `parent_id` = 0 AND `path` = '/meeting' AND `deleted` = b'0'
    ORDER BY `id` LIMIT 1
);

INSERT INTO `system_menu` (`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `component_name`, `status`, `visible`, `keep_alive`, `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`)
SELECT s.`name`, s.`permission`, 2, s.`sort`, @meeting_root_id, s.`path`, s.`icon`, s.`component`, s.`component_name`, 0, b'1', b'1', b'0', @creator, NOW(), @creator, NOW(), b'0'
FROM (
    SELECT '会议首页' AS `name`, 'meeting:room:query' AS `permission`, 1 AS `sort`, 'home' AS `path`, 'ep:home-filled' AS `icon`, 'meeting/home/index' AS `component`, 'MeetingHome' AS `component_name`
    UNION ALL SELECT '我的会议', 'meeting:info:query', 2, 'my', 'ep:user', 'meeting/my/index', 'MeetingMy'
    UNION ALL SELECT '预定审批', 'meeting:info:approve', 3, 'approval', 'ep:finished', 'meeting/approval/index', 'MeetingApproval'
    UNION ALL SELECT '会议列表', 'meeting:info:query', 4, 'list', 'ep:tickets', 'meeting/list/index', 'MeetingList'
    UNION ALL SELECT '已归档会议', 'meeting:info:query', 5, 'archived', 'ep:folder-opened', 'meeting/archived/index', 'MeetingArchived'
    UNION ALL SELECT '会议模板', 'meeting:template:query', 6, 'template', 'ep:files', 'meeting/template/index', 'MeetingTemplate'
    UNION ALL SELECT '会议室管理', 'meeting:room:query', 7, 'room', 'ep:office-building', 'meeting/room/index', 'MeetingRoom'
    UNION ALL SELECT '会中消息', 'meeting:notification:query', 8, 'notification', 'ep:chat-dot-round', 'meeting/notification/index', 'MeetingNotification'
    UNION ALL SELECT '公共资料库', 'meeting:public-file:query', 9, 'public-file', 'ep:collection', 'meeting/public-file/index', 'MeetingPublicFile'
    UNION ALL SELECT '客户端样式', 'meeting:ui-config:query', 10, 'ui-config', 'ep:brush', 'meeting/ui-config/index', 'MeetingUiConfig'
    UNION ALL SELECT '安装包管理', 'meeting:app-version:query', 11, 'app-version', 'ep:download', 'meeting/app-version/index', 'MeetingAppVersion'
) s
LEFT JOIN `system_menu` m ON m.`parent_id` = @meeting_root_id AND m.`path` = s.`path` AND m.`deleted` = b'0'
WHERE m.`id` IS NULL;

INSERT INTO `system_menu` (`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `component_name`, `status`, `visible`, `keep_alive`, `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`)
SELECT s.`name`, s.`permission`, 3, s.`sort`, @meeting_root_id, '', '', '', NULL, 0, b'1', b'1', b'1', @creator, NOW(), @creator, NOW(), b'0'
FROM (
    SELECT '会议查询' AS `name`, 'meeting:info:query' AS `permission`, 1 AS `sort`
    UNION ALL SELECT '会议创建', 'meeting:info:create', 2
    UNION ALL SELECT '会议修改', 'meeting:info:update', 3
    UNION ALL SELECT '会议删除', 'meeting:info:delete', 4
    UNION ALL SELECT '会议审批', 'meeting:info:approve', 5
    UNION ALL SELECT '会议归档', 'meeting:info:archive', 6
    UNION ALL SELECT '会议室查询', 'meeting:room:query', 7
    UNION ALL SELECT '会议室创建', 'meeting:room:create', 8
    UNION ALL SELECT '会议室修改', 'meeting:room:update', 9
    UNION ALL SELECT '会议室删除', 'meeting:room:delete', 10
    UNION ALL SELECT '消息查询', 'meeting:notification:query', 11
    UNION ALL SELECT '消息创建', 'meeting:notification:create', 12
    UNION ALL SELECT '消息修改', 'meeting:notification:update', 13
    UNION ALL SELECT '消息删除', 'meeting:notification:delete', 14
    UNION ALL SELECT '模板查询', 'meeting:template:query', 15
    UNION ALL SELECT '模板创建', 'meeting:template:create', 16
    UNION ALL SELECT '议题查询', 'meeting:agenda:query', 17
    UNION ALL SELECT '议题创建', 'meeting:agenda:create', 18
    UNION ALL SELECT '议题删除', 'meeting:agenda:delete', 19
    UNION ALL SELECT '参会人查询', 'meeting:attendee:query', 20
    UNION ALL SELECT '参会人创建', 'meeting:attendee:create', 21
    UNION ALL SELECT '参会人修改', 'meeting:attendee:update', 22
    UNION ALL SELECT '参会人删除', 'meeting:attendee:delete', 23
    UNION ALL SELECT '会议资料查询', 'meeting:file:query', 24
    UNION ALL SELECT '会议资料创建', 'meeting:file:create', 25
    UNION ALL SELECT '会议资料删除', 'meeting:file:delete', 26
    UNION ALL SELECT '表决查询', 'meeting:vote:query', 27
    UNION ALL SELECT '表决创建', 'meeting:vote:create', 28
    UNION ALL SELECT '表决修改', 'meeting:vote:update', 29
    UNION ALL SELECT '表决删除', 'meeting:vote:delete', 30
    UNION ALL SELECT '公共资料查询', 'meeting:public-file:query', 31
    UNION ALL SELECT '公共资料创建', 'meeting:public-file:create', 32
    UNION ALL SELECT '公共资料修改', 'meeting:public-file:update', 33
    UNION ALL SELECT '公共资料删除', 'meeting:public-file:delete', 34
    UNION ALL SELECT '样式查询', 'meeting:ui-config:query', 35
    UNION ALL SELECT '样式创建', 'meeting:ui-config:create', 36
    UNION ALL SELECT '样式修改', 'meeting:ui-config:update', 37
    UNION ALL SELECT '样式删除', 'meeting:ui-config:delete', 38
    UNION ALL SELECT '安装包查询', 'meeting:app-version:query', 39
    UNION ALL SELECT '安装包创建', 'meeting:app-version:create', 40
    UNION ALL SELECT '安装包修改', 'meeting:app-version:update', 41
    UNION ALL SELECT '安装包删除', 'meeting:app-version:delete', 42
) s
LEFT JOIN `system_menu` m ON m.`parent_id` = @meeting_root_id AND m.`permission` = s.`permission` AND m.`type` = 3 AND m.`deleted` = b'0'
WHERE m.`id` IS NULL;

INSERT INTO `system_role` (`name`, `code`, `sort`, `data_scope`, `data_scope_dept_ids`, `status`, `type`, `remark`, `creator`, `create_time`, `updater`, `update_time`, `deleted`, `tenant_id`)
SELECT '会议管理员', 'meeting_admin', 10, 1, '', 0, 2, '会议系统初始化脚本创建', @creator, NOW(), @creator, NOW(), b'0', @tenant_id
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `system_role` WHERE `code` = 'meeting_admin' AND `tenant_id` = @tenant_id AND `deleted` = b'0'
);

SET @meeting_admin_role_id := (
    SELECT `id` FROM `system_role`
    WHERE `code` = 'meeting_admin' AND `tenant_id` = @tenant_id AND `deleted` = b'0'
    ORDER BY `id` LIMIT 1
);

SET @super_admin_role_id := (
    SELECT `id` FROM `system_role`
    WHERE `code` = 'super_admin' AND `tenant_id` = @tenant_id AND `deleted` = b'0'
    ORDER BY `id` LIMIT 1
);

INSERT INTO `system_role_menu` (`role_id`, `menu_id`, `creator`, `create_time`, `updater`, `update_time`, `deleted`, `tenant_id`)
SELECT @meeting_admin_role_id, m.`id`, @creator, NOW(), @creator, NOW(), b'0', @tenant_id
FROM `system_menu` m
WHERE m.`deleted` = b'0'
  AND (m.`id` = @meeting_root_id OR m.`parent_id` = @meeting_root_id)
  AND NOT EXISTS (
      SELECT 1 FROM `system_role_menu` rm
      WHERE rm.`role_id` = @meeting_admin_role_id AND rm.`menu_id` = m.`id` AND rm.`tenant_id` = @tenant_id AND rm.`deleted` = b'0'
  );

INSERT INTO `system_role_menu` (`role_id`, `menu_id`, `creator`, `create_time`, `updater`, `update_time`, `deleted`, `tenant_id`)
SELECT @super_admin_role_id, m.`id`, @creator, NOW(), @creator, NOW(), b'0', @tenant_id
FROM `system_menu` m
WHERE @super_admin_role_id IS NOT NULL
  AND m.`deleted` = b'0'
  AND (m.`id` = @meeting_root_id OR m.`parent_id` = @meeting_root_id)
  AND NOT EXISTS (
      SELECT 1 FROM `system_role_menu` rm
      WHERE rm.`role_id` = @super_admin_role_id AND rm.`menu_id` = m.`id` AND rm.`tenant_id` = @tenant_id AND rm.`deleted` = b'0'
  );

INSERT INTO `meeting_room` (`name`, `location`, `capacity`, `status`, `config`, `creator`, `create_time`, `updater`, `update_time`, `deleted`, `tenant_id`)
SELECT s.`name`, s.`location`, s.`capacity`, 0, s.`config`, @creator, NOW(), @creator, NOW(), b'0', @tenant_id
FROM (
    SELECT '第一会议室（演示）' AS `name`, '总部 3F A301' AS `location`, 24 AS `capacity`, '{"layout":"u-shape","seats":24}' AS `config`
    UNION ALL
    SELECT '第二会议室（演示）', '总部 5F B501', 16, '{"layout":"classroom","seats":16}'
) s
LEFT JOIN `meeting_room` r ON r.`name` = s.`name` AND r.`tenant_id` = @tenant_id AND r.`deleted` = b'0'
WHERE r.`id` IS NULL;

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

INSERT INTO `meeting` (`name`, `description`, `start_time`, `end_time`, `room_id`, `status`, `type`, `level`, `control_type`, `require_approval`, `password`, `watermark`, `summary`, `archive_time`, `creator`, `create_time`, `updater`, `update_time`, `deleted`, `tenant_id`)
SELECT s.`name`, s.`description`, s.`start_time`, s.`end_time`, s.`room_id`, s.`status`, s.`type`, s.`level`, s.`control_type`, s.`require_approval`, s.`password`, s.`watermark`, s.`summary`, NULL, @creator, NOW(), @creator, NOW(), b'0', @tenant_id
FROM (
    SELECT '季度经营分析会模板' AS `name`, '演示模板，可直接复制生成正式会议' AS `description`, '2026-04-01 09:00:00' AS `start_time`, '2026-04-01 11:00:00' AS `end_time`, @demo_room_a_id AS `room_id`, 0 AS `status`, 2 AS `type`, 0 AS `level`, 0 AS `control_type`, b'1' AS `require_approval`, NULL AS `password`, b'1' AS `watermark`, '模板包含标准议程、资料上传和投票环节。' AS `summary`
    UNION ALL
    SELECT '管理端功能联调会（演示）', '用于演示预约审批、消息发布、资料下发与客户端样式联动', '2026-04-08 14:00:00', '2026-04-08 16:00:00', @demo_room_b_id, 2, 1, 0, 0, b'1', '123456', b'1', '会后自动沉淀会议纪要并归档资料。'
) s
LEFT JOIN `meeting` m ON m.`name` = s.`name` AND m.`tenant_id` = @tenant_id AND m.`deleted` = b'0'
WHERE m.`id` IS NULL;

SET @demo_meeting_id := (
    SELECT `id` FROM `meeting`
    WHERE `name` = '管理端功能联调会（演示）' AND `tenant_id` = @tenant_id AND `deleted` = b'0'
    ORDER BY `id` LIMIT 1
);

INSERT INTO `meeting_notification` (`meeting_id`, `content`, `publish_status`, `published_time`, `creator`, `create_time`, `updater`, `update_time`, `deleted`, `tenant_id`)
SELECT @demo_meeting_id, '请参会人员提前 10 分钟入场，移动终端登录后先完成签到。', 1, NOW(), @creator, NOW(), @creator, NOW(), b'0', @tenant_id
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `meeting_notification`
    WHERE `meeting_id` = @demo_meeting_id AND `content` = '请参会人员提前 10 分钟入场，移动终端登录后先完成签到。' AND `deleted` = b'0'
);

INSERT INTO `meeting_public_file` (`category`, `name`, `url`, `file_type`, `sort`, `enabled`, `remark`, `creator`, `create_time`, `updater`, `update_time`, `deleted`, `tenant_id`)
SELECT '制度文件', '无纸化会议终端操作指南.pdf', 'https://example.com/files/meeting-terminal-guide.pdf', 'pdf', 1, b'1', '初始化演示资料', @creator, NOW(), @creator, NOW(), b'0', @tenant_id
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `meeting_public_file`
    WHERE `name` = '无纸化会议终端操作指南.pdf' AND `tenant_id` = @tenant_id AND `deleted` = b'0'
);

INSERT INTO `meeting_ui_config` (`name`, `font_size`, `primary_color`, `accent_color`, `background_image_url`, `logo_url`, `extra_css`, `active`, `remark`, `creator`, `create_time`, `updater`, `update_time`, `deleted`, `tenant_id`)
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
WHERE `tenant_id` = @tenant_id AND `deleted` = b'0' AND (`active` = b'1' OR `name` = '政务蓝标准主题');

INSERT INTO `meeting_app_version` (`client_type`, `name`, `version_name`, `version_code`, `download_url`, `md5`, `force_update`, `active`, `remark`, `creator`, `create_time`, `updater`, `update_time`, `deleted`, `tenant_id`)
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
WHERE `tenant_id` = @tenant_id AND `deleted` = b'0' AND `client_type` = 1 AND (`active` = b'1' OR `version_code` = 100);

COMMIT;

-- 会议系统菜单全量增量修复脚本
-- 适用于旧环境漏菜单、漏授权，或菜单排序与组件路径不一致的场景

SET @tenant_id := 1;
SET @creator := 'admin';

START TRANSACTION;

INSERT INTO `system_menu`
(`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `component_name`, `status`, `visible`, `keep_alive`, `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`)
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

INSERT INTO `system_menu`
(`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `component_name`, `status`, `visible`, `keep_alive`, `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`)
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
WHERE @meeting_root_id IS NOT NULL
  AND m.`id` IS NULL;

UPDATE `system_menu` m
JOIN (
    SELECT 'home' AS `path`, 1 AS `sort`, 'meeting:room:query' AS `permission`, 'ep:home-filled' AS `icon`, 'meeting/home/index' AS `component`, 'MeetingHome' AS `component_name`
    UNION ALL SELECT 'my', 2, 'meeting:info:query', 'ep:user', 'meeting/my/index', 'MeetingMy'
    UNION ALL SELECT 'approval', 3, 'meeting:info:approve', 'ep:finished', 'meeting/approval/index', 'MeetingApproval'
    UNION ALL SELECT 'list', 4, 'meeting:info:query', 'ep:tickets', 'meeting/list/index', 'MeetingList'
    UNION ALL SELECT 'archived', 5, 'meeting:info:query', 'ep:folder-opened', 'meeting/archived/index', 'MeetingArchived'
    UNION ALL SELECT 'template', 6, 'meeting:template:query', 'ep:files', 'meeting/template/index', 'MeetingTemplate'
    UNION ALL SELECT 'room', 7, 'meeting:room:query', 'ep:office-building', 'meeting/room/index', 'MeetingRoom'
    UNION ALL SELECT 'notification', 8, 'meeting:notification:query', 'ep:chat-dot-round', 'meeting/notification/index', 'MeetingNotification'
    UNION ALL SELECT 'public-file', 9, 'meeting:public-file:query', 'ep:collection', 'meeting/public-file/index', 'MeetingPublicFile'
    UNION ALL SELECT 'ui-config', 10, 'meeting:ui-config:query', 'ep:brush', 'meeting/ui-config/index', 'MeetingUiConfig'
    UNION ALL SELECT 'app-version', 11, 'meeting:app-version:query', 'ep:download', 'meeting/app-version/index', 'MeetingAppVersion'
) s ON m.`parent_id` = @meeting_root_id AND m.`path` = s.`path`
SET m.`name` = s.`name`,
    m.`sort` = s.`sort`,
    m.`permission` = s.`permission`,
    m.`icon` = s.`icon`,
    m.`component` = s.`component`,
    m.`component_name` = s.`component_name`,
    m.`status` = 0,
    m.`visible` = b'1',
    m.`keep_alive` = b'1',
    m.`always_show` = b'0',
    m.`updater` = @creator,
    m.`update_time` = NOW()
WHERE m.`deleted` = b'0';

INSERT INTO `system_menu`
(`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `component_name`, `status`, `visible`, `keep_alive`, `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`)
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
    UNION ALL SELECT '消息发布', 'meeting:notification:publish', 43
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
    UNION ALL SELECT '表决发布结果', 'meeting:vote:publish', 44
    UNION ALL SELECT '表决导出', 'meeting:vote:export', 45
    UNION ALL SELECT '强制返回同屏', 'meeting:vote:force-return', 46
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
WHERE @meeting_root_id IS NOT NULL
  AND m.`id` IS NULL;

UPDATE `system_menu` m
JOIN (
    SELECT 'meeting:info:query' AS `permission`, 1 AS `sort`, '会议查询' AS `name`
    UNION ALL SELECT 'meeting:info:create', 2, '会议创建'
    UNION ALL SELECT 'meeting:info:update', 3, '会议修改'
    UNION ALL SELECT 'meeting:info:delete', 4, '会议删除'
    UNION ALL SELECT 'meeting:info:approve', 5, '会议审批'
    UNION ALL SELECT 'meeting:info:archive', 6, '会议归档'
    UNION ALL SELECT 'meeting:room:query', 7, '会议室查询'
    UNION ALL SELECT 'meeting:room:create', 8, '会议室创建'
    UNION ALL SELECT 'meeting:room:update', 9, '会议室修改'
    UNION ALL SELECT 'meeting:room:delete', 10, '会议室删除'
    UNION ALL SELECT 'meeting:notification:query', 11, '消息查询'
    UNION ALL SELECT 'meeting:notification:create', 12, '消息创建'
    UNION ALL SELECT 'meeting:notification:update', 13, '消息修改'
    UNION ALL SELECT 'meeting:notification:delete', 14, '消息删除'
    UNION ALL SELECT 'meeting:notification:publish', 43, '消息发布'
    UNION ALL SELECT 'meeting:template:query', 15, '模板查询'
    UNION ALL SELECT 'meeting:template:create', 16, '模板创建'
    UNION ALL SELECT 'meeting:agenda:query', 17, '议题查询'
    UNION ALL SELECT 'meeting:agenda:create', 18, '议题创建'
    UNION ALL SELECT 'meeting:agenda:delete', 19, '议题删除'
    UNION ALL SELECT 'meeting:attendee:query', 20, '参会人查询'
    UNION ALL SELECT 'meeting:attendee:create', 21, '参会人创建'
    UNION ALL SELECT 'meeting:attendee:update', 22, '参会人修改'
    UNION ALL SELECT 'meeting:attendee:delete', 23, '参会人删除'
    UNION ALL SELECT 'meeting:file:query', 24, '会议资料查询'
    UNION ALL SELECT 'meeting:file:create', 25, '会议资料创建'
    UNION ALL SELECT 'meeting:file:delete', 26, '会议资料删除'
    UNION ALL SELECT 'meeting:vote:query', 27, '表决查询'
    UNION ALL SELECT 'meeting:vote:create', 28, '表决创建'
    UNION ALL SELECT 'meeting:vote:update', 29, '表决修改'
    UNION ALL SELECT 'meeting:vote:delete', 30, '表决删除'
    UNION ALL SELECT 'meeting:vote:publish', 44, '表决发布结果'
    UNION ALL SELECT 'meeting:vote:export', 45, '表决导出'
    UNION ALL SELECT 'meeting:vote:force-return', 46, '强制返回同屏'
    UNION ALL SELECT 'meeting:public-file:query', 31, '公共资料查询'
    UNION ALL SELECT 'meeting:public-file:create', 32, '公共资料创建'
    UNION ALL SELECT 'meeting:public-file:update', 33, '公共资料修改'
    UNION ALL SELECT 'meeting:public-file:delete', 34, '公共资料删除'
    UNION ALL SELECT 'meeting:ui-config:query', 35, '样式查询'
    UNION ALL SELECT 'meeting:ui-config:create', 36, '样式创建'
    UNION ALL SELECT 'meeting:ui-config:update', 37, '样式修改'
    UNION ALL SELECT 'meeting:ui-config:delete', 38, '样式删除'
    UNION ALL SELECT 'meeting:app-version:query', 39, '安装包查询'
    UNION ALL SELECT 'meeting:app-version:create', 40, '安装包创建'
    UNION ALL SELECT 'meeting:app-version:update', 41, '安装包修改'
    UNION ALL SELECT 'meeting:app-version:delete', 42, '安装包删除'
) s ON m.`parent_id` = @meeting_root_id AND m.`permission` = s.`permission` AND m.`type` = 3
SET m.`name` = s.`name`,
    m.`sort` = s.`sort`,
    m.`path` = '',
    m.`icon` = '',
    m.`component` = '',
    m.`component_name` = NULL,
    m.`status` = 0,
    m.`visible` = b'1',
    m.`keep_alive` = b'1',
    m.`always_show` = b'1',
    m.`updater` = @creator,
    m.`update_time` = NOW()
WHERE m.`deleted` = b'0';

SET @meeting_admin_role_id := (
    SELECT `id` FROM `system_role`
    WHERE `code` = 'meeting_admin' AND `tenant_id` = @tenant_id AND `deleted` = b'0'
    ORDER BY `id` LIMIT 1
);

INSERT INTO `system_role_menu`
(`role_id`, `menu_id`, `creator`, `create_time`, `updater`, `update_time`, `deleted`, `tenant_id`)
SELECT r.`id`, m.`id`, @creator, NOW(), @creator, NOW(), b'0', @tenant_id
FROM `system_role` r
JOIN `system_menu` m ON (m.`id` = @meeting_root_id OR m.`parent_id` = @meeting_root_id) AND m.`deleted` = b'0'
WHERE r.`tenant_id` = @tenant_id
  AND r.`deleted` = b'0'
  AND r.`code` IN ('super_admin', 'tenant_admin', 'meeting_admin')
  AND NOT EXISTS (
      SELECT 1 FROM `system_role_menu` rm
      WHERE rm.`role_id` = r.`id` AND rm.`menu_id` = m.`id` AND rm.`tenant_id` = @tenant_id AND rm.`deleted` = b'0'
  );

COMMIT;

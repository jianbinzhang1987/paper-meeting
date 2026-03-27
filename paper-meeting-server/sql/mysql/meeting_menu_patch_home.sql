-- 会议系统首页菜单增量补丁
-- 适用于已导入旧版会议菜单、但缺少“会议首页”菜单的环境

SET @tenant_id := 1;
SET @creator := 'admin';

START TRANSACTION;

SET @meeting_root_id := (
    SELECT `id` FROM `system_menu`
    WHERE `parent_id` = 0 AND `path` = '/meeting' AND `deleted` = b'0'
    ORDER BY `id` LIMIT 1
);

INSERT INTO `system_menu`
(`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `component_name`, `status`, `visible`, `keep_alive`, `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`)
SELECT '会议首页', 'meeting:room:query', 2, 1, @meeting_root_id, 'home', 'ep:home-filled', 'meeting/home/index', 'MeetingHome', 0, b'1', b'1', b'0', @creator, NOW(), @creator, NOW(), b'0'
FROM DUAL
WHERE @meeting_root_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM `system_menu`
      WHERE `parent_id` = @meeting_root_id AND `path` = 'home' AND `deleted` = b'0'
  );

UPDATE `system_menu`
SET `sort` = CASE
        WHEN `path` = 'home' THEN 1
        WHEN `path` = 'my' THEN 2
        WHEN `path` = 'approval' THEN 3
        WHEN `path` = 'list' THEN 4
        WHEN `path` = 'archived' THEN 5
        WHEN `path` = 'notification' THEN 6
        WHEN `path` = 'template' THEN 7
        WHEN `path` = 'room' THEN 8
        WHEN `path` = 'public-file' THEN 9
        WHEN `path` = 'ui-config' THEN 10
        WHEN `path` = 'app-version' THEN 11
        ELSE `sort`
    END,
    `updater` = @creator,
    `update_time` = NOW()
WHERE `parent_id` = @meeting_root_id
  AND `deleted` = b'0'
  AND `path` IN ('home', 'my', 'approval', 'list', 'archived', 'notification', 'template', 'room', 'public-file', 'ui-config', 'app-version');

SET @home_menu_id := (
    SELECT `id` FROM `system_menu`
    WHERE `parent_id` = @meeting_root_id AND `path` = 'home' AND `deleted` = b'0'
    ORDER BY `id` LIMIT 1
);

INSERT INTO `system_role_menu`
(`role_id`, `menu_id`, `creator`, `create_time`, `updater`, `update_time`, `deleted`, `tenant_id`)
SELECT r.`id`, @home_menu_id, @creator, NOW(), @creator, NOW(), b'0', @tenant_id
FROM `system_role` r
WHERE @home_menu_id IS NOT NULL
  AND r.`tenant_id` = @tenant_id
  AND r.`deleted` = b'0'
  AND r.`code` IN ('super_admin', 'meeting_admin', 'tenant_admin')
  AND NOT EXISTS (
      SELECT 1 FROM `system_role_menu` rm
      WHERE rm.`role_id` = r.`id` AND rm.`menu_id` = @home_menu_id AND rm.`tenant_id` = @tenant_id AND rm.`deleted` = b'0'
  );

COMMIT;

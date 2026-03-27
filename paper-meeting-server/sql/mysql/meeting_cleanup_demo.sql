-- 会议系统初始化回滚脚本
-- 默认租户：1。如需其它租户，请修改 @tenant_id。
-- 本脚本用于清理 meeting_init_demo.sql 产生的菜单、角色授权、字典和演示数据。

SET @tenant_id := 1;
SET @updater := 'admin';

START TRANSACTION;

SET @meeting_root_id := (
    SELECT `id` FROM `system_menu`
    WHERE `parent_id` = 0 AND `path` = '/meeting' AND `deleted` = b'0'
    ORDER BY `id` LIMIT 1
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

UPDATE `meeting_notification`
SET `deleted` = b'1',
    `updater` = @updater,
    `update_time` = NOW()
WHERE `tenant_id` = @tenant_id
  AND `deleted` = b'0'
  AND `content` = '请参会人员提前 10 分钟入场，移动终端登录后先完成签到。';

UPDATE `meeting`
SET `deleted` = b'1',
    `updater` = @updater,
    `update_time` = NOW()
WHERE `tenant_id` = @tenant_id
  AND `deleted` = b'0'
  AND `name` IN ('季度经营分析会模板', '管理端功能联调会（演示）');

UPDATE `meeting_room`
SET `deleted` = b'1',
    `updater` = @updater,
    `update_time` = NOW()
WHERE `tenant_id` = @tenant_id
  AND `deleted` = b'0'
  AND `name` IN ('第一会议室（演示）', '第二会议室（演示）');

UPDATE `meeting_public_file`
SET `deleted` = b'1',
    `updater` = @updater,
    `update_time` = NOW()
WHERE `tenant_id` = @tenant_id
  AND `deleted` = b'0'
  AND `name` = '无纸化会议终端操作指南.pdf'
  AND `url` = 'https://example.com/files/meeting-terminal-guide.pdf';

UPDATE `meeting_ui_config`
SET `deleted` = b'1',
    `active` = b'0',
    `updater` = @updater,
    `update_time` = NOW()
WHERE `tenant_id` = @tenant_id
  AND `deleted` = b'0'
  AND `name` = '政务蓝标准主题';

UPDATE `meeting_app_version`
SET `deleted` = b'1',
    `active` = b'0',
    `updater` = @updater,
    `update_time` = NOW()
WHERE `tenant_id` = @tenant_id
  AND `deleted` = b'0'
  AND `client_type` = 1
  AND `version_code` = 100
  AND `name` = '安卓客户端安装包';

UPDATE `system_role_menu`
SET `deleted` = b'1',
    `updater` = @updater,
    `update_time` = NOW()
WHERE `tenant_id` = @tenant_id
  AND `deleted` = b'0'
  AND (
      (`role_id` = @meeting_admin_role_id)
      OR (`role_id` = @super_admin_role_id AND `menu_id` IN (
          SELECT `id` FROM `system_menu`
          WHERE (`id` = @meeting_root_id OR `parent_id` = @meeting_root_id) AND `deleted` = b'0'
      ))
  );

UPDATE `system_role`
SET `deleted` = b'1',
    `updater` = @updater,
    `update_time` = NOW()
WHERE `tenant_id` = @tenant_id
  AND `deleted` = b'0'
  AND `code` = 'meeting_admin';

UPDATE `system_menu`
SET `deleted` = b'1',
    `updater` = @updater,
    `update_time` = NOW()
WHERE `deleted` = b'0'
  AND (`id` = @meeting_root_id OR `parent_id` = @meeting_root_id);

UPDATE `system_dict_data`
SET `deleted` = b'1',
    `updater` = @updater,
    `update_time` = NOW()
WHERE `deleted` = b'0'
  AND `dict_type` IN ('meeting_status', 'meeting_client_type');

UPDATE `system_dict_type`
SET `deleted` = b'1',
    `updater` = @updater,
    `update_time` = NOW()
WHERE `deleted` = b'0'
  AND `type` IN ('meeting_status', 'meeting_client_type');

COMMIT;

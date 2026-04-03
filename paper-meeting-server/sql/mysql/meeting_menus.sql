-- 会议系统菜单 SQL
-- 执行前请按实际环境确认 system_menu 表结构与顶级菜单策略

INSERT INTO `system_menu` (`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `status`, `visible`, `keep_alive`, `always_show`, `create_time`, `update_time`, `deleted`)
VALUES ('会议系统', '', 1, 10, 0, '/meeting', 'ep:calendar', '', 0, 1, 1, 1, NOW(), NOW(), 0);

SET @meeting_root_id = LAST_INSERT_ID();

INSERT INTO `system_menu` (`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `status`, `visible`, `keep_alive`, `always_show`, `create_time`, `update_time`, `deleted`)
VALUES
('会议工作台', '', 2, 1, @meeting_root_id, 'workspace', 'ep:monitor', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('会中服务', '', 2, 2, @meeting_root_id, 'service', 'ep:operation', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('资源配置', '', 2, 3, @meeting_root_id, 'resource', 'ep:collection-tag', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('终端运维', '', 2, 4, @meeting_root_id, 'terminal', 'ep:cpu', '', 0, 1, 1, 1, NOW(), NOW(), 0);

SET @meeting_workspace_id = LAST_INSERT_ID() - 3;
SET @meeting_service_id = LAST_INSERT_ID() - 2;
SET @meeting_resource_id = LAST_INSERT_ID() - 1;
SET @meeting_terminal_id = LAST_INSERT_ID();

INSERT INTO `system_menu` (`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `status`, `visible`, `keep_alive`, `always_show`, `create_time`, `update_time`, `deleted`)
VALUES
('会议首页', 'meeting:room:query', 2, 1, @meeting_workspace_id, 'home', 'ep:home-filled', 'meeting/home/index', 0, 1, 1, 0, NOW(), NOW(), 0),
('我的会议', 'meeting:info:query', 2, 2, @meeting_workspace_id, 'my', 'ep:user', 'meeting/my/index', 0, 1, 1, 0, NOW(), NOW(), 0),
('预定审批', 'meeting:info:approve', 2, 3, @meeting_workspace_id, 'approval', 'ep:finished', 'meeting/approval/index', 0, 1, 1, 0, NOW(), NOW(), 0),
('会议列表', 'meeting:info:query', 2, 4, @meeting_workspace_id, 'list', 'ep:tickets', 'meeting/list/index', 0, 1, 1, 0, NOW(), NOW(), 0),
('已归档会议', 'meeting:info:query', 2, 5, @meeting_workspace_id, 'archived', 'ep:folder-opened', 'meeting/archived/index', 0, 1, 1, 0, NOW(), NOW(), 0),
('会议模板', 'meeting:template:query', 2, 6, @meeting_workspace_id, 'template', 'ep:files', 'meeting/template/index', 0, 1, 1, 0, NOW(), NOW(), 0),
('会议室管理', 'meeting:room:query', 2, 7, @meeting_workspace_id, 'room', 'ep:office-building', 'meeting/room/index', 0, 1, 1, 0, NOW(), NOW(), 0),
('表决控制中心', 'meeting:vote:query', 2, 1, @meeting_service_id, 'control', 'ep:histogram', 'meeting/control/index', 0, 1, 1, 0, NOW(), NOW(), 0),
('会中消息', 'meeting:notification:query', 2, 2, @meeting_service_id, 'notification', 'ep:chat-dot-round', 'meeting/notification/index', 0, 1, 1, 0, NOW(), NOW(), 0),
('公共资料库', 'meeting:public-file:query', 2, 1, @meeting_resource_id, 'public-file', 'ep:collection', 'meeting/public-file/index', 0, 1, 1, 0, NOW(), NOW(), 0),
('会议贴牌', 'meeting:branding:query', 2, 2, @meeting_resource_id, 'branding', 'ep:brush-filled', 'meeting/branding/index', 0, 1, 1, 0, NOW(), NOW(), 0),
('会议用户组', 'meeting:user-group:query', 2, 3, @meeting_resource_id, 'user-group', 'ep:user-filled', 'meeting/user-group/index', 0, 1, 1, 0, NOW(), NOW(), 0),
('客户端样式', 'meeting:ui-config:query', 2, 1, @meeting_terminal_id, 'ui-config', 'ep:brush', 'meeting/ui-config/index', 0, 1, 1, 0, NOW(), NOW(), 0),
('安装包管理', 'meeting:app-version:query', 2, 2, @meeting_terminal_id, 'app-version', 'ep:download', 'meeting/app-version/index', 0, 1, 1, 0, NOW(), NOW(), 0);

INSERT INTO `system_menu` (`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `status`, `visible`, `keep_alive`, `always_show`, `create_time`, `update_time`, `deleted`)
VALUES
('会议查询', 'meeting:info:query', 3, 1, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('会议创建', 'meeting:info:create', 3, 2, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('会议修改', 'meeting:info:update', 3, 3, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('会议删除', 'meeting:info:delete', 3, 4, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('会议审批', 'meeting:info:approve', 3, 5, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('会议归档', 'meeting:info:archive', 3, 6, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('会议室查询', 'meeting:room:query', 3, 7, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('会议室创建', 'meeting:room:create', 3, 8, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('会议室修改', 'meeting:room:update', 3, 9, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('会议室删除', 'meeting:room:delete', 3, 10, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('消息查询', 'meeting:notification:query', 3, 11, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('消息创建', 'meeting:notification:create', 3, 12, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('消息修改', 'meeting:notification:update', 3, 13, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('消息删除', 'meeting:notification:delete', 3, 14, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('消息发布', 'meeting:notification:publish', 3, 53, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('模板查询', 'meeting:template:query', 3, 15, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('模板创建', 'meeting:template:create', 3, 16, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('议题查询', 'meeting:agenda:query', 3, 17, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('议题创建', 'meeting:agenda:create', 3, 18, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('议题删除', 'meeting:agenda:delete', 3, 19, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('参会人查询', 'meeting:attendee:query', 3, 20, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('参会人创建', 'meeting:attendee:create', 3, 21, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('参会人修改', 'meeting:attendee:update', 3, 22, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('参会人删除', 'meeting:attendee:delete', 3, 23, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('会议资料查询', 'meeting:file:query', 3, 24, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('会议资料创建', 'meeting:file:create', 3, 25, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('会议资料删除', 'meeting:file:delete', 3, 26, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('表决查询', 'meeting:vote:query', 3, 27, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('表决创建', 'meeting:vote:create', 3, 28, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('表决修改', 'meeting:vote:update', 3, 29, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('表决删除', 'meeting:vote:delete', 3, 30, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('表决发布结果', 'meeting:vote:publish', 3, 54, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('表决导出', 'meeting:vote:export', 3, 55, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('强制返回同屏', 'meeting:vote:force-return', 3, 56, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('公共资料查询', 'meeting:public-file:query', 3, 31, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('公共资料创建', 'meeting:public-file:create', 3, 32, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('公共资料修改', 'meeting:public-file:update', 3, 33, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('公共资料删除', 'meeting:public-file:delete', 3, 34, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('样式查询', 'meeting:ui-config:query', 3, 35, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('样式创建', 'meeting:ui-config:create', 3, 36, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('样式修改', 'meeting:ui-config:update', 3, 37, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('样式删除', 'meeting:ui-config:delete', 3, 38, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('安装包查询', 'meeting:app-version:query', 3, 39, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('安装包创建', 'meeting:app-version:create', 3, 40, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('安装包修改', 'meeting:app-version:update', 3, 41, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('安装包删除', 'meeting:app-version:delete', 3, 42, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('贴牌查询', 'meeting:branding:query', 3, 43, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('贴牌创建', 'meeting:branding:create', 3, 44, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('贴牌修改', 'meeting:branding:update', 3, 45, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('贴牌删除', 'meeting:branding:delete', 3, 46, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('用户组查询', 'meeting:user-group:query', 3, 47, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('用户组创建', 'meeting:user-group:create', 3, 48, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('用户组修改', 'meeting:user-group:update', 3, 49, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('用户组删除', 'meeting:user-group:delete', 3, 50, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('消息明细查询', 'meeting:notification:query', 3, 51, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0),
('终端状态查询', 'meeting:terminal-status:query', 3, 52, @meeting_root_id, '', '', '', 0, 1, 1, 1, NOW(), NOW(), 0);

INSERT INTO `system_dict_type` (`name`, `type`, `status`, `remark`, `create_time`, `update_time`, `deleted`)
VALUES
('会议状态', 'meeting_status', 0, '会议生命周期状态', NOW(), NOW(), 0),
('客户端类型', 'meeting_client_type', 0, '会议客户端安装包类型', NOW(), NOW(), 0);

INSERT INTO `system_dict_data` (`sort`, `label`, `value`, `dict_type`, `status`, `color_type`, `css_class`, `remark`, `create_time`, `update_time`, `deleted`)
VALUES
(1, '待发布', '0', 'meeting_status', 0, 'info', '', '', NOW(), NOW(), 0),
(2, '待审批', '1', 'meeting_status', 0, 'warning', '', '', NOW(), NOW(), 0),
(3, '已预约', '2', 'meeting_status', 0, 'success', '', '', NOW(), NOW(), 0),
(4, '进行中', '3', 'meeting_status', 0, 'primary', '', '', NOW(), NOW(), 0),
(5, '已结束', '4', 'meeting_status', 0, 'danger', '', '', NOW(), NOW(), 0),
(6, '已归档', '5', 'meeting_status', 0, 'success', '', '', NOW(), NOW(), 0),
(1, '安卓客户端', '1', 'meeting_client_type', 0, 'primary', '', '', NOW(), NOW(), 0),
(2, '呼叫服务端', '2', 'meeting_client_type', 0, 'warning', '', '', NOW(), NOW(), 0),
(3, '大屏端', '3', 'meeting_client_type', 0, 'success', '', '', NOW(), NOW(), 0),
(4, '信息发布端', '4', 'meeting_client_type', 0, 'info', '', '', NOW(), NOW(), 0);

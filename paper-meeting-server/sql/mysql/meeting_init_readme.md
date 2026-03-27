# 会议系统初始化说明

## 1. 适用范围

本文档对应以下脚本：

- `meeting_system.sql`
- `meeting_init_demo.sql`
- `meeting_cleanup_demo.sql`
- `meeting_menu_patch_home.sql`
- `meeting_menu_patch_all.sql`

适用于无纸化会议系统管理端模块的数据库初始化、菜单权限导入、演示数据加载与回滚。

## 2. 执行顺序

首次初始化建议按以下顺序执行：

1. `ruoyi-vue-pro.sql`
2. `meeting_system.sql`
3. `meeting_init_demo.sql`

如仅需重置演示数据和会议模块初始化内容，可执行：

1. `meeting_cleanup_demo.sql`
2. `meeting_init_demo.sql`

如老环境已导入旧版会议菜单，但缺少“会议首页”菜单，可单独执行：

1. `meeting_menu_patch_home.sql`

如老环境存在多个会议菜单缺失、菜单排序不对、组件路径不一致或角色未授权，建议直接执行：

1. `meeting_menu_patch_all.sql`

该脚本同时会补齐会议模块按钮权限菜单及对应角色授权。

## 3. 脚本说明

### 3.1 `meeting_system.sql`

用途：

- 创建会议模块业务表
- 创建会议室、会议、议题、资料、投票、消息通知、公共资料库、客户端样式、安装包管理等表结构

注意：

- 该脚本包含 `DROP TABLE IF EXISTS`
- 应只在新环境初始化或明确允许重建会议模块表结构时执行

### 3.2 `meeting_init_demo.sql`

用途：

- 初始化会议模块菜单
- 初始化会议状态、客户端类型字典
- 初始化 `meeting_admin` 角色
- 为 `meeting_admin` 和当前租户 `super_admin` 授权会议菜单
- 插入演示会议室、模板会议、演示会议、通知、公共资料、UI 主题、安装包版本

默认参数：

- `@tenant_id := 1`
- `@creator := 'admin'`

特点：

- 幂等执行
- 重复执行不会重复插入同一批初始化数据

### 3.3 `meeting_cleanup_demo.sql`

用途：

- 回滚 `meeting_init_demo.sql` 产生的初始化数据
- 清理会议菜单、角色授权、会议演示数据、字典数据

默认参数：

- `@tenant_id := 1`
- `@updater := 'admin'`

特点：

- 使用软删除方式回滚
- 不删除会议业务表结构

## 4. 初始化后应看到的结果

执行 `meeting_init_demo.sql` 后，管理端应至少具备以下内容：

### 4.1 菜单

- 会议系统
- 会议首页
- 我的会议
- 预定审批
- 会议列表
- 已归档会议
- 消息管理
- 会议模板
- 会议室管理
- 公共资料库
- 客户端样式
- 安装包管理

### 4.2 角色

- `meeting_admin`

### 4.3 字典

- `meeting_status`
- `meeting_client_type`

### 4.4 演示数据

- 2 个演示会议室
- 1 个会议模板
- 1 个演示会议
- 1 条会议通知
- 1 条公共资料
- 1 套客户端样式
- 1 个安卓安装包版本

## 5. 建议验证项

导入完成后建议执行以下检查：

### 5.1 菜单检查

确认 `system_menu` 中存在根路径为 `/meeting` 的菜单树。

### 5.2 角色检查

确认 `system_role` 中存在：

- `code = 'meeting_admin'`

确认 `system_role_menu` 中已为以下角色分配会议菜单：

- `meeting_admin`
- 当前租户下的 `super_admin`

### 5.3 业务数据检查

确认以下表存在演示数据：

- `meeting_room`
- `meeting`
- `meeting_notification`
- `meeting_public_file`
- `meeting_ui_config`
- `meeting_app_version`

## 6. 回滚说明

如需回滚初始化内容，执行：

```sql
source meeting_cleanup_demo.sql;
```

回滚后会发生：

- 会议菜单树被软删除
- `meeting_admin` 角色被软删除
- 初始化的会议字典及字典项被软删除
- 初始化的演示业务数据被软删除

回滚后不会发生：

- 不会删除会议模块表结构
- 不会清理非初始化脚本插入的其他会议业务数据

## 7. 风险说明

执行 `meeting_cleanup_demo.sql` 前请确认：

- 当前 `/meeting` 菜单树确实由初始化脚本创建
- `meeting_status` 和 `meeting_client_type` 字典未被其他模块复用
- 演示数据名称未被人工复用为正式业务数据

如果线上环境已经基于这些菜单、字典或演示记录继续扩展，请先备份，再调整脚本后执行。

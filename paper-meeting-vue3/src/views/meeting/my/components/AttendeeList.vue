<template>
  <div>
    <div class="mb-10px flex gap-12px items-center">
      <el-button type="primary" @click="handleAdd">添加人员</el-button>
      <el-button type="warning" @click="handleImportGroup">按用户组导入</el-button>
      <el-button type="success" @click="handleExport">导出签到表</el-button>
    </div>
    <el-table :data="list">
      <el-table-column label="姓名" min-width="140">
        <template #default="scope">
          {{ getUserName(scope.row.userId) }}
        </template>
      </el-table-column>
      <el-table-column label="角色" prop="role">
        <template #default="scope">
          {{ roleLabelMap[scope.row.role] || '与会人员' }}
        </template>
      </el-table-column>
      <el-table-column label="状态" prop="status">
        <template #default="scope">
          {{ scope.row.status === 0 ? '未签到' : '已签到' }}
        </template>
      </el-table-column>
      <el-table-column label="入场时间" prop="signInTime" :formatter="dateFormatter" />
      <el-table-column label="座位" prop="seatId" />
      <el-table-column label="操作" width="120">
        <template #default="scope">
          <el-button link type="danger" @click="handleDelete(scope.row.id)">移除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="dialogVisible" title="添加人员" append-to-body>
      <el-form :model="formData" label-width="80px">
        <el-form-item label="人员" prop="userId">
          <el-select v-model="formData.userId" filterable placeholder="搜索系统用户">
            <el-option v-for="u in userList" :key="u.id" :label="u.nickname" :value="u.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-radio-group v-model="formData.role">
            <el-radio :label="0">与会人员</el-radio>
            <el-radio :label="1">主持人</el-radio>
            <el-radio :label="2">会议秘书</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitForm">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="groupDialogVisible" title="按用户组导入" append-to-body width="640px">
      <el-form :model="groupFormData" label-width="90px">
        <el-form-item label="用户组">
          <el-select v-model="groupFormData.groupIds" multiple filterable class="!w-full" placeholder="请选择会议用户组">
            <el-option v-for="item in groupList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="角色">
          <el-radio-group v-model="groupFormData.role">
            <el-radio :label="0">与会人员</el-radio>
            <el-radio :label="1">主持人</el-radio>
            <el-radio :label="2">会议秘书</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="groupDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitImportGroup">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import * as AttendeeApi from '@/api/meeting/attendee'
import * as MeetingUserGroupApi from '@/api/meeting/userGroup'
import * as UserApi from '@/api/system/user'
import { dateFormatter } from '@/utils/formatTime'

const props = defineProps<{ meetingId: number }>()
const list = ref<AttendeeApi.MeetingAttendeeVO[]>([])
const dialogVisible = ref(false)
const groupDialogVisible = ref(false)
const userList = ref<UserApi.UserVO[]>([])
const groupList = ref<MeetingUserGroupApi.MeetingUserGroupVO[]>([])
const userMap = computed(() =>
  userList.value.reduce<Record<number, UserApi.UserVO>>((acc, item) => {
    acc[item.id] = item
    return acc
  }, {})
)
const roleLabelMap: Record<number, string> = {
  0: '与会人员',
  1: '主持人',
  2: '会议秘书'
}
const formData = ref({
  meetingId: 0,
  userId: undefined as number | undefined,
  role: 0,
  status: 0
})
const groupFormData = ref({
  meetingId: 0,
  groupIds: [] as number[],
  role: 0
})

const getList = async () => {
  if (!props.meetingId) return
  const [attendees, users] = await Promise.all([
    AttendeeApi.getAttendeeList(props.meetingId),
    userList.value.length ? Promise.resolve(userList.value) : UserApi.getSimpleUserList()
  ])
  list.value = attendees
  userList.value = users
}

const handleAdd = async () => {
  formData.value = {
    meetingId: props.meetingId,
    userId: undefined,
    role: 0,
    status: 0
  }
  userList.value = await UserApi.getSimpleUserList()
  dialogVisible.value = true
}

const handleImportGroup = async () => {
  groupFormData.value = {
    meetingId: props.meetingId,
    groupIds: [],
    role: 0
  }
  groupList.value = await MeetingUserGroupApi.getMeetingUserGroupSimpleList()
  groupDialogVisible.value = true
}

const submitForm = async () => {
  await AttendeeApi.createAttendee(formData.value as AttendeeApi.MeetingAttendeeVO)
  dialogVisible.value = false
  await getList()
}

const handleDelete = async (id: number) => {
  await AttendeeApi.deleteAttendee(id)
  await getList()
}

const handleExport = async () => {
  await AttendeeApi.exportAttendeeExcel(props.meetingId)
}

const submitImportGroup = async () => {
  await AttendeeApi.importAttendeeGroups(groupFormData.value)
  groupDialogVisible.value = false
  await getList()
}

const getUserName = (userId: number) => {
  return userMap.value[userId]?.nickname || `用户#${userId}`
}

watch(
  () => props.meetingId,
  (val) => {
    if (val) getList()
  },
  { immediate: true }
)
</script>

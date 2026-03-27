<template>
  <Dialog v-model="dialogVisible" title="会议详情/配置" width="80%">
    <el-tabs v-model="activeTab">
      <el-tab-pane label="基本信息" name="basic">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="会议名称">{{ meeting.name }}</el-descriptions-item>
          <el-descriptions-item label="会议状态">
             <dict-tag :type="DICT_TYPE.MEETING_STATUS" :value="meeting.status" />
          </el-descriptions-item>
          <el-descriptions-item label="开始时间">{{ dateFormatter(null, null, meeting.startTime) }}</el-descriptions-item>
          <el-descriptions-item label="结束时间">{{ dateFormatter(null, null, meeting.endTime) }}</el-descriptions-item>
          <el-descriptions-item label="会议室">{{ meeting.roomName }}</el-descriptions-item>
          <el-descriptions-item label="会议级别">{{ meeting.level === 0 ? '普通' : '保密' }}</el-descriptions-item>
          <el-descriptions-item label="控制方式">{{ meeting.controlType === 1 ? '自由控制' : '秘书控制' }}</el-descriptions-item>
          <el-descriptions-item label="需要审批">{{ meeting.requireApproval ? '是' : '否' }}</el-descriptions-item>
          <el-descriptions-item label="会议记录" :span="2">{{ meeting.summary || '-' }}</el-descriptions-item>
        </el-descriptions>
      </el-tab-pane>
      <el-tab-pane label="议题管理" name="agenda">
        <AgendaList :meeting-id="meeting.id" />
      </el-tab-pane>
      <el-tab-pane label="参会人员" name="attendee">
        <AttendeeList :meeting-id="meeting.id" />
      </el-tab-pane>
      <el-tab-pane label="会议资料" name="file">
        <FileList :meeting-id="meeting.id" />
      </el-tab-pane>
      <el-tab-pane label="投票表决" name="vote">
        <VoteList :meeting-id="meeting.id" />
      </el-tab-pane>
      <el-tab-pane label="实时调度" name="realtime">
        <RealtimeConsole :meeting-id="meeting.id" :visible="dialogVisible" />
      </el-tab-pane>
      <el-tab-pane label="排座管理" name="seating">
        <SeatingArrangement :meeting-id="meeting.id" />
      </el-tab-pane>
    </el-tabs>
    <template #footer>
      <el-button @click="dialogVisible = false">关 闭</el-button>
    </template>
  </Dialog>
</template>

<script lang="ts" setup>
import { dateFormatter } from '@/utils/formatTime'
import { DICT_TYPE } from '@/utils/dict'
import * as MeetingApi from '@/api/meeting/info'
import AgendaList from './AgendaList.vue'
import AttendeeList from './AttendeeList.vue'
import FileList from './FileList.vue'
import VoteList from './VoteList.vue'
import SeatingArrangement from './SeatingArrangement.vue'
import RealtimeConsole from './RealtimeConsole.vue'

const dialogVisible = ref(false)
const activeTab = ref('basic')
const meeting = ref<any>({})

/** 打开弹窗 */
const open = async (id: number) => {
  dialogVisible.value = true
  activeTab.value = 'basic'
  meeting.value = await MeetingApi.getMeeting(id)
}
defineExpose({ open })
</script>

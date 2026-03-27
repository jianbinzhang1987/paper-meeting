<template>
  <ContentWrap>
    <!-- 搜索 -->
    <el-form
      class="-mb-15px"
      :model="queryParams"
      ref="queryFormRef"
      :inline="true"
      label-width="68px"
    >
      <el-form-item label="会议名称" prop="name">
        <el-input
          v-model="queryParams.name"
          placeholder="请输入会议名称"
          clearable
          @keyup.enter="handleQuery"
          class="!w-240px"
        />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select
          v-model="queryParams.status"
          placeholder="请选择状态"
          clearable
          class="!w-240px"
        >
          <el-option label="待发布" :value="0" />
          <el-option label="待审批" :value="1" />
          <el-option label="已预约" :value="2" />
          <el-option label="进行中" :value="3" />
          <el-option label="已结束" :value="4" />
          <el-option label="已归档" :value="5" />
        </el-select>
      </el-form-item>
      <el-form-item label="开始时间" prop="startTime">
        <el-date-picker
          v-model="queryParams.startTime"
          value-format="YYYY-MM-DD HH:mm:ss"
          type="datetimerange"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          class="!w-240px"
        />
      </el-form-item>
      <el-form-item>
        <el-button @click="handleQuery"><Icon icon="ep:search" />搜索</el-button>
        <el-button @click="resetQuery"><Icon icon="ep:refresh" />重置</el-button>
      </el-form-item>
    </el-form>
  </ContentWrap>

  <ContentWrap>
    <el-table v-loading="loading" :data="list">
      <el-table-column label="会议编号" align="center" prop="id" />
      <el-table-column label="会议名称" align="center" prop="name" :show-overflow-tooltip="true" />
      <el-table-column label="创建人" align="center" prop="creatorName" width="120" />
      <el-table-column label="开始时间" align="center" prop="startTime" :formatter="dateFormatter" width="180" />
      <el-table-column label="结束时间" align="center" prop="endTime" :formatter="dateFormatter" width="180" />
      <el-table-column label="状态" align="center" prop="status">
        <template #default="scope">
          <dict-tag :type="DICT_TYPE.MEETING_STATUS" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="420">
        <template #default="scope">
          <el-button link type="primary" @click="handleDetail(scope.row.id)">详情</el-button>
          <el-button link type="primary" @click="openForm('update', scope.row.id)">编辑</el-button>
          <el-button
            link
            type="danger"
            v-if="scope.row.status === 2 || scope.row.status === 3"
            @click="handleForceStop(scope.row)"
          >
            强制结束
          </el-button>
          <el-button link type="success" v-if="scope.row.status === 4" @click="handleArchive(scope.row.id)">归档</el-button>
          <el-button
            link
            type="success"
            v-if="scope.row.status === 4 || scope.row.status === 5"
            @click="handleExportAttendee(scope.row.id)"
          >
            导出签到表
          </el-button>
          <el-button
            link
            type="success"
            v-if="scope.row.status === 4 || scope.row.status === 5"
            @click="handleExportFiles(scope.row.id)"
          >
            导出资料
          </el-button>
          <el-button
            link
            type="success"
            v-if="scope.row.status === 4 || scope.row.status === 5"
            @click="handleExportVotes(scope.row.id)"
          >
            导出表决
          </el-button>
          <el-button link type="danger" @click="handleDelete(scope.row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <Pagination
      :total="total"
      v-model:page="queryParams.pageNo"
      v-model:limit="queryParams.pageSize"
      @pagination="getList"
    />
  </ContentWrap>
  
  <MeetingForm ref="formRef" @success="getList" />
  <MeetingDetail ref="detailRef" />
</template>

<script lang="ts" setup>
import { dateFormatter } from '@/utils/formatTime'
import * as AttendeeApi from '@/api/meeting/attendee'
import * as MeetingFileApi from '@/api/meeting/file'
import * as MeetingApi from '@/api/meeting/info'
import * as MeetingVoteApi from '@/api/meeting/vote'
import MeetingForm from '../my/MeetingForm.vue'
import MeetingDetail from '../my/components/MeetingDetail.vue'
import { DICT_TYPE } from '@/utils/dict'

defineOptions({ name: 'MeetingList' })

const message = useMessage()
const loading = ref(true)
const total = ref(0)
const list = ref([])
const queryParams = reactive({
  pageNo: 1,
  pageSize: 10,
  name: undefined,
  status: undefined,
  startTime: []
})
const queryFormRef = ref()

/** 查询列表 */
const getList = async () => {
  loading.value = true
  try {
    const data = await MeetingApi.getMeetingPage(queryParams)
    list.value = data.list
    total.value = data.total
  } finally {
    loading.value = false
  }
}

/** 搜索按钮操作 */
const handleQuery = () => {
  queryParams.pageNo = 1
  getList()
}

/** 重置按钮操作 */
const resetQuery = () => {
  queryFormRef.value?.resetFields()
  handleQuery()
}

/** 详情查看 */
const detailRef = ref()
const handleDetail = (id: number) => {
  detailRef.value.open(id)
}

const formRef = ref()
const openForm = (type: string, id?: number) => {
  formRef.value.open(type, id)
}

/** 归档操作 */
const handleArchive = async (id: number) => {
  try {
    await message.confirm('确认归档该会议吗？')
    await MeetingApi.archiveMeeting(id)
    message.success('归档成功')
    await getList()
  } catch {}
}

const handleForceStop = async (row: any) => {
  try {
    await message.confirm(`确认强制结束会议“${row.name}”吗？`)
    await MeetingApi.stopMeeting(row.id)
    message.success('会议已结束')
    await getList()
  } catch {}
}

const handleDelete = async (id: number) => {
  try {
    await message.delConfirm()
    await MeetingApi.deleteMeeting(id)
    message.success('删除成功')
    await getList()
  } catch {}
}

const handleExportAttendee = async (id: number) => {
  await AttendeeApi.exportAttendeeExcel(id)
}

const handleExportFiles = async (id: number) => {
  await MeetingFileApi.exportMeetingFileExcel(id)
}

const handleExportVotes = async (id: number) => {
  await MeetingVoteApi.exportMeetingVoteExcel(id)
}

onMounted(() => {
  getList()
})
</script>

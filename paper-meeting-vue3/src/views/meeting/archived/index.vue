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
      <el-table-column label="开始时间" align="center" prop="startTime" :formatter="dateFormatter" width="180" />
      <el-table-column label="结束时间" align="center" prop="endTime" :formatter="dateFormatter" width="180" />
      <el-table-column label="归档人" align="center" prop="updater" />
      <el-table-column label="归档时间" align="center" prop="updateTime" :formatter="dateFormatter" width="180" />
      <el-table-column label="操作" align="center" width="320">
        <template #default="scope">
          <el-button link type="primary" @click="handleDetail(scope.row.id)">查看详情</el-button>
          <el-button link type="success" @click="handleExportFiles(scope.row.id)">导出资料</el-button>
          <el-button link type="success" @click="handleExportVotes(scope.row.id)">导出表决</el-button>
          <el-button link type="warning" @click="handleRollback(scope.row.id)">撤回归档</el-button>
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
  
  <MeetingDetail ref="detailRef" />
</template>

<script lang="ts" setup>
import { dateFormatter } from '@/utils/formatTime'
import * as MeetingFileApi from '@/api/meeting/file'
import * as MeetingApi from '@/api/meeting/info'
import * as MeetingVoteApi from '@/api/meeting/vote'
import MeetingDetail from '../my/components/MeetingDetail.vue'

defineOptions({ name: 'ArchivedMeeting' })

const message = useMessage()
const loading = ref(true)
const total = ref(0)
const list = ref([])
const queryParams = reactive({
  pageNo: 1,
  pageSize: 10,
  name: undefined,
  status: 5 // 已归档
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

/** 查看详情 */
const detailRef = ref()
const handleDetail = (id: number) => {
  detailRef.value.open(id)
}

const handleRollback = async (id: number) => {
  try {
    await message.confirm('确认撤回归档并恢复到已结束状态吗？')
    await MeetingApi.rollbackArchiveMeeting(id)
    message.success('撤回归档成功')
    await getList()
  } catch {}
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

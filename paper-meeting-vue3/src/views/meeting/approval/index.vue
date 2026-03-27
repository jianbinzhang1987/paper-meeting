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
      <el-table-column label="预约人" align="center" prop="creatorName" />
      <el-table-column label="预约时间" align="center" prop="createTime" :formatter="dateFormatter" width="180" />
      <el-table-column label="开始时间" align="center" prop="startTime" :formatter="dateFormatter" width="180" />
      <el-table-column label="结束时间" align="center" prop="endTime" :formatter="dateFormatter" width="180" />
      <el-table-column label="操作" align="center" width="260">
        <template #default="scope">
          <el-button link type="primary" @click="handleApprove(scope.row, true)">通过</el-button>
          <el-button link type="danger" @click="handleApprove(scope.row, false)">驳回</el-button>
          <el-button link type="info" @click="handleOpenHistory(scope.row)">审批历史</el-button>
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

  <Dialog v-model="historyVisible" title="审批历史" width="760px">
    <el-table v-loading="historyLoading" :data="historyList">
      <el-table-column label="操作时间" prop="createTime" :formatter="dateFormatter" width="180" />
      <el-table-column label="操作类型" prop="actionName" width="120" />
      <el-table-column label="操作人" prop="operatorName" width="120" />
      <el-table-column label="意见" prop="remark" min-width="220" show-overflow-tooltip />
    </el-table>
  </Dialog>
</template>

<script lang="ts" setup>
import { dateFormatter } from '@/utils/formatTime'
import * as MeetingApi from '@/api/meeting/info'

defineOptions({ name: 'MeetingApproval' })

const message = useMessage()
const loading = ref(true)
const total = ref(0)
const list = ref([])
const queryParams = reactive({
  pageNo: 1,
  pageSize: 10,
  name: undefined,
  status: 1 // 待审批
})
const queryFormRef = ref()
const historyVisible = ref(false)
const historyLoading = ref(false)
const historyList = ref<MeetingApi.MeetingApprovalLogVO[]>([])

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

/** 审批操作 */
const handleApprove = async (row: any, approved: boolean) => {
  try {
    const text = approved ? '通过' : '驳回'
    const result = await message.prompt(`请输入${text}意见`, '审批意见')
    await message.confirm(`确认${text}该会议预约吗？`)
    await MeetingApi.approveBooking({
      id: row.id,
      approved,
      remark: result.value
    })
    message.success(`${text}成功`)
    await getList()
  } catch {}
}

const handleOpenHistory = async (row: any) => {
  historyVisible.value = true
  historyLoading.value = true
  try {
    historyList.value = await MeetingApi.getApprovalLogList(row.id)
  } finally {
    historyLoading.value = false
  }
}

onMounted(() => {
  getList()
})
</script>

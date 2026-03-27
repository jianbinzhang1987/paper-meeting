<template>
  <ContentWrap>
    <el-form :model="queryParams" :inline="true" class="-mb-15px">
      <el-form-item label="模板名称">
        <el-input v-model="queryParams.name" placeholder="请输入模板名称" class="!w-240px" clearable />
      </el-form-item>
      <el-form-item>
        <el-button @click="handleQuery"><Icon icon="ep:search" />搜索</el-button>
        <el-button @click="resetQuery"><Icon icon="ep:refresh" />重置</el-button>
        <el-button type="primary" @click="openForm('create')"><Icon icon="ep:plus" />新增模板</el-button>
      </el-form-item>
    </el-form>
  </ContentWrap>

  <ContentWrap>
    <el-table v-loading="loading" :data="list">
      <el-table-column label="编号" prop="id" width="90" />
      <el-table-column label="模板名称" prop="name" min-width="220" />
      <el-table-column label="开始时间" prop="startTime" :formatter="dateFormatter" width="180" />
      <el-table-column label="结束时间" prop="endTime" :formatter="dateFormatter" width="180" />
      <el-table-column label="会议级别" width="100">
        <template #default="scope">{{ scope.row.level === 1 ? '保密' : '普通' }}</template>
      </el-table-column>
      <el-table-column label="操作" width="260">
        <template #default="scope">
          <el-button link type="primary" @click="openForm('update', scope.row.id)">编辑</el-button>
          <el-button link type="success" @click="handleGenerate(scope.row.id)">生成会议</el-button>
          <el-button link type="primary" @click="openDetail(scope.row.id)">详情</el-button>
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
import * as MeetingApi from '@/api/meeting/info'
import MeetingForm from '../my/MeetingForm.vue'
import MeetingDetail from '../my/components/MeetingDetail.vue'

defineOptions({ name: 'MeetingTemplate' })

const message = useMessage()
const loading = ref(false)
const total = ref(0)
const list = ref<any[]>([])
const queryParams = reactive({
  pageNo: 1,
  pageSize: 10,
  name: undefined,
  type: 2
})

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

const handleQuery = () => {
  queryParams.pageNo = 1
  getList()
}

const resetQuery = () => {
  queryParams.name = undefined
  handleQuery()
}

const formRef = ref()
const detailRef = ref()

const openForm = (type: string, id?: number) => {
  formRef.value.open(type, id, 2)
}

const openDetail = (id: number) => {
  detailRef.value.open(id)
}

const handleGenerate = async (id: number) => {
  await MeetingApi.copyMeeting(id)
  message.success('已生成会议草稿')
}

const handleDelete = async (id: number) => {
  try {
    await message.delConfirm()
    await MeetingApi.deleteMeeting(id)
    message.success('删除成功')
    await getList()
  } catch {}
}

onMounted(getList)
</script>

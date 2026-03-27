<template>
  <ContentWrap>
    <el-form :model="queryParams" :inline="true" class="-mb-15px">
      <el-form-item label="会议编号">
        <el-input v-model="queryParams.meetingId" placeholder="请输入会议编号" class="!w-180px" clearable />
      </el-form-item>
      <el-form-item label="状态">
        <el-select v-model="queryParams.publishStatus" class="!w-180px" clearable>
          <el-option label="草稿" :value="0" />
          <el-option label="已发布" :value="1" />
        </el-select>
      </el-form-item>
      <el-form-item label="内容">
        <el-input v-model="queryParams.content" placeholder="请输入通知内容" class="!w-240px" clearable />
      </el-form-item>
      <el-form-item>
        <el-button @click="handleQuery"><Icon icon="ep:search" />搜索</el-button>
        <el-button @click="resetQuery"><Icon icon="ep:refresh" />重置</el-button>
        <el-button type="primary" @click="openForm('create')"><Icon icon="ep:plus" />新增消息</el-button>
      </el-form-item>
    </el-form>
  </ContentWrap>

  <ContentWrap>
    <el-table v-loading="loading" :data="list">
      <el-table-column label="编号" prop="id" width="90" />
      <el-table-column label="会议编号" prop="meetingId" width="120" />
      <el-table-column label="内容" prop="content" min-width="360" show-overflow-tooltip />
      <el-table-column label="状态" width="100">
        <template #default="scope">
          <el-tag :type="scope.row.publishStatus === 1 ? 'success' : 'info'">
            {{ scope.row.publishStatus === 1 ? '已发布' : '草稿' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="发布时间" prop="publishedTime" :formatter="dateFormatter" width="180" />
      <el-table-column label="创建时间" prop="createTime" :formatter="dateFormatter" width="180" />
      <el-table-column label="操作" width="220">
        <template #default="scope">
          <el-button link type="primary" @click="openForm('update', scope.row.id)">编辑</el-button>
          <el-button link type="success" v-if="scope.row.publishStatus !== 1" @click="handlePublish(scope.row.id)">发布</el-button>
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

  <Dialog v-model="dialogVisible" :title="dialogTitle" width="640px">
    <el-form ref="formRef" :model="formData" :rules="formRules" label-width="88px" v-loading="formLoading">
      <el-form-item label="会议编号" prop="meetingId">
        <el-input-number v-model="formData.meetingId" :min="1" class="!w-full" />
      </el-form-item>
      <el-form-item label="通知内容" prop="content">
        <el-input v-model="formData.content" type="textarea" :rows="5" />
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="dialogVisible = false">取消</el-button>
      <el-button type="primary" :loading="formLoading" @click="submitForm">确定</el-button>
    </template>
  </Dialog>
</template>

<script lang="ts" setup>
import { dateFormatter } from '@/utils/formatTime'
import * as NotificationApi from '@/api/meeting/notification'

defineOptions({ name: 'MeetingNotification' })

const message = useMessage()
const loading = ref(false)
const total = ref(0)
const list = ref<any[]>([])
const queryParams = reactive({
  pageNo: 1,
  pageSize: 10,
  meetingId: undefined,
  publishStatus: undefined,
  content: undefined
})

const dialogVisible = ref(false)
const dialogTitle = ref('')
const formLoading = ref(false)
const formType = ref<'create' | 'update'>('create')
const formRef = ref()
const formData = ref<any>({
  id: undefined,
  meetingId: undefined,
  content: ''
})
const formRules = reactive({
  meetingId: [{ required: true, message: '会议编号不能为空', trigger: 'blur' }],
  content: [{ required: true, message: '通知内容不能为空', trigger: 'blur' }]
})

const getList = async () => {
  loading.value = true
  try {
    const data = await NotificationApi.getMeetingNotificationPage(queryParams)
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
  queryParams.meetingId = undefined
  queryParams.publishStatus = undefined
  queryParams.content = undefined
  handleQuery()
}

const openForm = async (type: 'create' | 'update', id?: number) => {
  dialogVisible.value = true
  dialogTitle.value = type === 'create' ? '新增消息' : '编辑消息'
  formType.value = type
  formData.value = { id: undefined, meetingId: undefined, content: '' }
  if (id) {
    formLoading.value = true
    try {
      formData.value = await NotificationApi.getMeetingNotification(id)
    } finally {
      formLoading.value = false
    }
  }
}

const submitForm = async () => {
  const valid = await formRef.value?.validate()
  if (!valid) return
  formLoading.value = true
  try {
    if (formType.value === 'create') {
      await NotificationApi.createMeetingNotification(formData.value)
      message.success('创建成功')
    } else {
      await NotificationApi.updateMeetingNotification(formData.value)
      message.success('更新成功')
    }
    dialogVisible.value = false
    await getList()
  } finally {
    formLoading.value = false
  }
}

const handlePublish = async (id: number) => {
  await NotificationApi.publishMeetingNotification(id)
  message.success('发布成功')
  await getList()
}

const handleDelete = async (id: number) => {
  try {
    await message.delConfirm()
    await NotificationApi.deleteMeetingNotification(id)
    message.success('删除成功')
    await getList()
  } catch {}
}

onMounted(getList)
</script>

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
      <el-table-column label="阅读进度" width="180">
        <template #default="scope">
          <span>{{ scope.row.readCount || 0 }}/{{ scope.row.attendeeCount || 0 }}</span>
          <el-tag class="ml-8px" size="small" type="info">未读 {{ scope.row.unreadCount || 0 }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="发布时间" prop="publishedTime" :formatter="dateFormatter" width="180" />
      <el-table-column label="创建时间" prop="createTime" :formatter="dateFormatter" width="180" />
      <el-table-column label="操作" width="220">
        <template #default="scope">
          <el-button link type="primary" @click="openReadDetail(scope.row)">明细</el-button>
          <el-button link type="primary" @click="openForm('update', scope.row.id)">编辑</el-button>
          <el-button
            v-hasPermi="['meeting:notification:publish']"
            link
            type="success"
            v-if="scope.row.publishStatus !== 1"
            @click="handlePublish(scope.row.id)"
          >
            发布
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

  <Dialog v-model="readDetailVisible" title="阅读明细" width="900px">
    <div v-loading="readDetailLoading">
      <el-row :gutter="12" class="mb-16px">
        <el-col :span="8">
          <el-statistic title="参会总数" :value="readDetail?.attendeeCount || 0" />
        </el-col>
        <el-col :span="8">
          <el-statistic title="已读人数" :value="readDetail?.readCount || 0" />
        </el-col>
        <el-col :span="8">
          <el-statistic title="未读人数" :value="readDetail?.unreadCount || 0" />
        </el-col>
      </el-row>
      <el-row :gutter="12" class="mb-16px">
        <el-col :span="8">
          <el-statistic title="已送达" :value="readDetail?.deliveredCount || 0" />
        </el-col>
        <el-col :span="8">
          <el-statistic title="送达失败" :value="readDetail?.failedCount || 0" />
        </el-col>
        <el-col :span="8">
          <el-statistic title="待送达" :value="readDetail?.pendingCount || 0" />
        </el-col>
      </el-row>
      <el-row :gutter="16">
        <el-col :span="12">
          <div class="font-600 mb-8px">已读名单</div>
          <el-table :data="readDetail?.readUsers || []" height="360">
            <el-table-column label="姓名" prop="nickname" min-width="120" />
            <el-table-column label="角色" min-width="100">
              <template #default="scope">{{ roleLabelMap[scope.row.role] || '与会人员' }}</template>
            </el-table-column>
            <el-table-column label="座位" prop="seatId" min-width="100" />
            <el-table-column label="已读时间" prop="readTime" :formatter="dateFormatter" min-width="170" />
          </el-table>
        </el-col>
        <el-col :span="12">
          <div class="font-600 mb-8px">未读名单</div>
          <el-table :data="readDetail?.unreadUsers || []" height="360">
            <el-table-column label="姓名" prop="nickname" min-width="120" />
            <el-table-column label="角色" min-width="100">
              <template #default="scope">{{ roleLabelMap[scope.row.role] || '与会人员' }}</template>
            </el-table-column>
            <el-table-column label="座位" prop="seatId" min-width="100" />
          </el-table>
        </el-col>
      </el-row>
      <div class="font-600 mt-16px mb-8px">终端送达回执</div>
      <el-table :data="readDetail?.terminalReceipts || []" height="320" empty-text="暂无终端回执">
        <el-table-column label="用户" min-width="140">
          <template #default="scope">
            <div>{{ scope.row.nickname }}</div>
            <div class="text-12px text-[var(--el-text-color-secondary)]">{{ roleLabelMap[scope.row.role] || '与会人员' }}</div>
          </template>
        </el-table-column>
        <el-table-column label="终端" min-width="220">
          <template #default="scope">
            <div>{{ scope.row.roomName || '-' }} / {{ scope.row.seatName || scope.row.seatId || '-' }}</div>
            <div class="text-12px text-[var(--el-text-color-secondary)]">{{ scope.row.deviceName || '-' }}</div>
          </template>
        </el-table-column>
        <el-table-column label="送达状态" width="120">
          <template #default="scope">
            <el-tag :type="deliveryTagType(scope.row.deliveryStatus)">{{ scope.row.deliveryStatusText || '-' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="在线" width="90">
          <template #default="scope">
            <el-tag :type="scope.row.online ? 'success' : 'info'">{{ scope.row.online ? '在线' : '离线' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="阅读状态" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.read ? 'success' : 'warning'">{{ scope.row.read ? '已读' : '未读' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="失败原因" prop="failureReason" min-width="200" show-overflow-tooltip />
        <el-table-column label="最后心跳" min-width="170">
          <template #default="scope">{{ scope.row.lastHeartbeatTime ? dayjs(scope.row.lastHeartbeatTime).format('YYYY-MM-DD HH:mm:ss') : '-' }}</template>
        </el-table-column>
      </el-table>
    </div>
  </Dialog>
</template>

<script lang="ts" setup>
import dayjs from 'dayjs'
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
const roleLabelMap: Record<number, string> = {
  0: '与会人员',
  1: '主持人',
  2: '会议秘书'
}
const readDetailVisible = ref(false)
const readDetailLoading = ref(false)
const readDetail = ref<NotificationApi.MeetingNotificationReadDetailVO>()

const getList = async () => {
  loading.value = true
  try {
    const data = await NotificationApi.getMeetingNotificationStatsPage(queryParams)
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

const openReadDetail = async (row: NotificationApi.MeetingNotificationStatsVO) => {
  readDetailVisible.value = true
  readDetailLoading.value = true
  readDetail.value = undefined
  try {
    readDetail.value = await NotificationApi.getMeetingNotificationReadDetail(row.id!)
  } finally {
    readDetailLoading.value = false
  }
}

const deliveryTagType = (status?: string) => {
  if (status === 'delivered') return 'success'
  if (status === 'failed') return 'danger'
  return 'warning'
}

onMounted(getList)
</script>

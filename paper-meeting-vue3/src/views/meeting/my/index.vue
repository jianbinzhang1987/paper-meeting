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
        <el-button type="primary" @click="openForm('create', undefined, 1)">
          <Icon icon="ep:plus" /> 预约会议
        </el-button>
        <el-button type="success" @click="openForm('create', undefined, 0)">
          <Icon icon="ep:video-play" /> 即时会议
        </el-button>
        <el-button type="warning" @click="openCopyDialog">
          <Icon icon="ep:document-copy" /> 嵌用会议
        </el-button>
      </el-form-item>
    </el-form>
  </ContentWrap>

  <ContentWrap>
    <el-table v-loading="loading" :data="list">
      <el-table-column label="会议编号" align="center" prop="id" />
      <el-table-column label="会议名称" align="center" prop="name" :show-overflow-tooltip="true" />
      <el-table-column label="开始时间" align="center" prop="startTime" :formatter="dateFormatter" width="180" />
      <el-table-column label="结束时间" align="center" prop="endTime" :formatter="dateFormatter" width="180" />
      <el-table-column label="状态" align="center" prop="status">
        <template #default="scope">
          <dict-tag :type="DICT_TYPE.MEETING_STATUS" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="320">
        <template #default="scope">
          <el-button link type="primary" @click="openDetail(scope.row.id)">详情/配置</el-button>
          <el-button link type="primary" @click="openForm('update', scope.row.id)">编辑</el-button>
          <el-button link type="warning" @click="handleSaveTemplate(scope.row.id)">存为模板</el-button>
          <el-button link type="primary" v-if="scope.row.status === 0" @click="handleSubmitBooking(scope.row)">提交预约</el-button>
          <el-button link type="warning" v-if="scope.row.status === 1" @click="handleCancelApproval(scope.row)">撤销审核</el-button>
          <el-button link type="success" v-if="scope.row.status === 2" @click="handleStart(scope.row)">开始</el-button>
          <el-button link type="danger" v-if="scope.row.status === 3" @click="handleStop(scope.row)">结束</el-button>
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

  <!-- 表单弹窗：添加/修改 -->
  <MeetingForm ref="formRef" @success="getList" />
  <!-- 会议配置详情 -->
  <MeetingDetail ref="detailRef" />

  <Dialog v-model="copyDialogVisible" title="嵌用会议" width="720px">
    <el-radio-group v-model="copyMode" class="mb-12px">
      <el-radio-button label="template">模板库</el-radio-button>
      <el-radio-button label="history">历史会议</el-radio-button>
    </el-radio-group>
    <el-form :inline="true" class="mb-12px">
      <el-form-item label="会议名称">
        <el-input v-model="copyQuery.name" placeholder="搜索会议" clearable />
      </el-form-item>
      <el-form-item>
        <el-button @click="getCopySourceList"><Icon icon="ep:search" />搜索</el-button>
      </el-form-item>
    </el-form>
    <el-table v-loading="copyLoading" :data="copySourceList" max-height="420">
      <el-table-column label="会议名称" prop="name" min-width="200" />
      <el-table-column label="开始时间" prop="startTime" :formatter="dateFormatter" width="180" />
      <el-table-column label="状态" width="100">
        <template #default="scope">
          <dict-tag :type="DICT_TYPE.MEETING_STATUS" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="操作" width="120">
        <template #default="scope">
          <el-button link type="primary" @click="handleCopyMeeting(scope.row.id)">生成会议</el-button>
        </template>
      </el-table-column>
    </el-table>
  </Dialog>
</template>

<script lang="ts" setup>
import { dateFormatter } from '@/utils/formatTime'
import * as MeetingApi from '@/api/meeting/info'
import MeetingForm from './MeetingForm.vue'
import MeetingDetail from './components/MeetingDetail.vue'
import { DICT_TYPE } from '@/utils/dict'

defineOptions({ name: 'MyMeeting' })

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
const copyDialogVisible = ref(false)
const copyLoading = ref(false)
const copySourceList = ref<any[]>([])
const copyMode = ref<'template' | 'history'>('template')
const copyQuery = reactive({
  pageNo: 1,
  pageSize: 20,
  name: undefined,
  status: undefined as number | undefined,
  type: undefined as number | undefined
})

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

/** 添加/修改操作 */
const formRef = ref()
const openForm = (type: string, id?: number, meetingType?: number) => {
  formRef.value.open(type, id, meetingType)
}

/** 会议详情/配置 */
const detailRef = ref()
const openDetail = (id: number) => {
  detailRef.value.open(id)
}

/** 删除按钮操作 */
const handleDelete = async (id: number) => {
  try {
    await message.delConfirm()
    await MeetingApi.deleteMeeting(id)
    message.success('删除成功')
    await getList()
  } catch {}
}

/** 提交预约 */
const handleSubmitBooking = async (row: any) => {
  try {
    await message.confirm('确认提交预约吗？')
    await MeetingApi.submitBooking(row.id)
    message.success('提交成功')
    await getList()
  } catch {}
}

const handleCancelApproval = async (row: any) => {
  try {
    const result = await message.prompt('请输入撤销审核原因', '撤销审核')
    await message.confirm('确认撤销当前审核流程吗？')
    await MeetingApi.cancelApproval({ id: row.id, remark: result.value })
    message.success('已撤销审核')
    await getList()
  } catch {}
}

/** 开始会议 */
const handleStart = async (row: any) => {
  try {
    await message.confirm('确认开始会议吗？')
    await MeetingApi.startMeeting(row.id)
    message.success('会议已开始')
    await getList()
  } catch {}
}

/** 结束会议 */
const handleStop = async (row: any) => {
  try {
    await message.confirm('确认结束会议吗？')
    await MeetingApi.stopMeeting(row.id)
    message.success('会议已结束')
    await getList()
  } catch {}
}

const openCopyDialog = async () => {
  copyDialogVisible.value = true
  await getCopySourceList()
}

const getCopySourceList = async () => {
  copyLoading.value = true
  try {
    if (copyMode.value === 'template') {
      const templateData = await MeetingApi.getMeetingPage({ ...copyQuery, type: 2, status: 0 })
      copySourceList.value = templateData.list
    } else {
      const ended = await MeetingApi.getMeetingPage({ ...copyQuery, status: 4, type: undefined })
      const archived = await MeetingApi.getMeetingPage({ ...copyQuery, status: 5, type: undefined })
      copySourceList.value = [...ended.list, ...archived.list]
    }
  } finally {
    copyLoading.value = false
  }
}

const handleCopyMeeting = async (id: number) => {
  try {
    await message.confirm('确认根据该历史会议生成新会议吗？')
    await MeetingApi.copyMeeting(id)
    message.success('已生成新的草稿会议')
    copyDialogVisible.value = false
    await getList()
  } catch {}
}

const handleSaveTemplate = async (id: number) => {
  try {
    await message.confirm('确认将该会议保存为模板吗？')
    await MeetingApi.saveAsTemplate(id)
    message.success('模板已生成')
  } catch {}
}

watch(copyMode, () => {
  if (copyDialogVisible.value) {
    getCopySourceList()
  }
})

onMounted(() => {
  getList()
})
</script>

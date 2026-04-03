<template>
  <div>
    <div class="mb-10px flex flex-wrap gap-8px">
      <el-button type="primary" @click="handleAdd">添加表决</el-button>
      <el-button v-hasPermi="['meeting:vote:force-return']" type="warning" plain @click="handleForceReturn">强制返回同屏</el-button>
      <el-button v-hasPermi="['meeting:vote:export']" type="success" plain @click="handleExport">导出表决结果</el-button>
    </div>
    <el-table :data="list">
      <el-table-column label="表决标题" prop="title" min-width="180" />
      <el-table-column label="所属议题" min-width="140">
        <template #default="scope">
          {{ getAgendaTitle(scope.row.agendaId) }}
        </template>
      </el-table-column>
      <el-table-column label="投票类型" width="100">
        <template #default="scope">
          {{ scope.row.type === 1 ? '多选' : '单选' }}
        </template>
      </el-table-column>
      <el-table-column label="匿名" width="80">
        <template #default="scope">
          {{ scope.row.isSecret ? '是' : '否' }}
        </template>
      </el-table-column>
      <el-table-column label="状态" width="100">
        <template #default="scope">
          <el-tag :type="getVoteStatusType(scope.row.status)">
            {{ getVoteStatusLabel(scope.row.status) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="选项" min-width="260">
        <template #default="scope">
          {{ scope.row.options?.map((item) => item.content).join(' / ') || '-' }}
        </template>
      </el-table-column>
      <el-table-column label="操作" width="280">
        <template #default="scope">
          <el-button
            v-if="scope.row.status !== 1"
            link
            type="primary"
            @click="handleStart(scope.row.id!)"
          >
            开始
          </el-button>
          <el-button
            v-if="scope.row.status === 1"
            link
            type="warning"
            @click="handleFinish(scope.row.id!)"
          >
            结束
          </el-button>
          <el-button
            v-hasPermi="['meeting:vote:publish']"
            v-if="scope.row.status === 1 || scope.row.status === 2"
            link
            type="success"
            @click="handlePublish(scope.row.id!)"
          >
            发布结果
          </el-button>
          <el-button link type="danger" @click="handleDelete(scope.row.id!)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="dialogVisible" title="添加表决" width="720px" append-to-body>
      <el-form :model="formData" label-width="90px">
        <el-form-item label="表决标题">
          <el-input v-model="formData.title" placeholder="请输入表决标题" />
        </el-form-item>
        <el-form-item label="所属议题">
          <el-select v-model="formData.agendaId" clearable placeholder="可选">
            <el-option
              v-for="agenda in agendaList"
              :key="agenda.id"
              :label="agenda.title"
              :value="agenda.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="投票类型">
          <el-radio-group v-model="formData.type">
            <el-radio :label="0">单选</el-radio>
            <el-radio :label="1">多选</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="匿名投票">
          <el-switch v-model="formData.isSecret" />
        </el-form-item>
        <el-form-item label="表决选项">
          <div class="w-full">
            <div
              v-for="(item, index) in formData.options"
              :key="index"
              class="flex gap-8px items-center mb-8px"
            >
              <el-input v-model="item.content" placeholder="请输入选项内容" />
              <el-button link type="danger" @click="removeOption(index)">删除</el-button>
            </div>
            <el-button link type="primary" @click="addOption">新增选项</el-button>
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="submitForm">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import * as AgendaApi from '@/api/meeting/agenda'
import * as VoteApi from '@/api/meeting/vote'

const props = defineProps<{ meetingId: number }>()

const message = useMessage()
const list = ref<VoteApi.MeetingVoteVO[]>([])
const agendaList = ref<any[]>([])
const dialogVisible = ref(false)
const submitting = ref(false)
const formData = ref<VoteApi.MeetingVoteVO>({
  meetingId: 0,
  title: '',
  type: 0,
  isSecret: true,
  options: [
    { content: '同意', sort: 1 },
    { content: '不同意', sort: 2 }
  ]
})

const getList = async () => {
  if (!props.meetingId) return
  const [votes, agendas] = await Promise.all([
    VoteApi.getMeetingVoteList(props.meetingId),
    AgendaApi.getAgendaList(props.meetingId)
  ])
  list.value = votes
  agendaList.value = agendas
}

const handleAdd = () => {
  formData.value = {
    meetingId: props.meetingId,
    title: '',
    type: 0,
    isSecret: true,
    options: [
      { content: '同意', sort: 1 },
      { content: '不同意', sort: 2 }
    ]
  }
  dialogVisible.value = true
}

const handleDelete = async (id: number) => {
  try {
    await message.delConfirm()
    await VoteApi.deleteMeetingVote(id)
    message.success('删除成功')
    await getList()
  } catch {}
}

const handleStart = async (id: number) => {
  try {
    await message.confirm('确认开始该表决吗？')
    await VoteApi.startMeetingVote(id)
    message.success('表决已开始')
    await getList()
  } catch {}
}

const handleFinish = async (id: number) => {
  try {
    await message.confirm('确认结束该表决吗？')
    await VoteApi.finishMeetingVote(id)
    message.success('表决已结束')
    await getList()
  } catch {}
}

const handlePublish = async (id: number) => {
  try {
    await message.confirm('确认发布该表决结果吗？')
    await VoteApi.publishMeetingVote(id)
    message.success('结果已发布')
    await getList()
  } catch {}
}

const handleForceReturn = async () => {
  try {
    await message.confirm('确认向当前会议终端下发强制返回同屏指令吗？')
    await VoteApi.forceReturnMeetingVote(props.meetingId)
    message.success('指令已下发')
  } catch {}
}

const handleExport = async () => {
  await VoteApi.exportMeetingVoteExcel(props.meetingId)
}

const addOption = () => {
  formData.value.options.push({
    content: '',
    sort: formData.value.options.length + 1
  })
}

const removeOption = (index: number) => {
  formData.value.options.splice(index, 1)
  formData.value.options.forEach((item, idx) => {
    item.sort = idx + 1
  })
}

const submitForm = async () => {
  if (!formData.value.title.trim()) {
    message.warning('请输入表决标题')
    return
  }
  const options = formData.value.options
    .filter((item) => item.content?.trim())
    .map((item, index) => ({ ...item, sort: index + 1 }))
  if (options.length < 2) {
    message.warning('至少保留两个有效选项')
    return
  }
  submitting.value = true
  try {
    await VoteApi.createMeetingVote({
      ...formData.value,
      meetingId: props.meetingId,
      options
    })
    dialogVisible.value = false
    message.success('创建成功')
    await getList()
  } finally {
    submitting.value = false
  }
}

const getAgendaTitle = (agendaId?: number) => {
  if (!agendaId) return '未关联议题'
  return agendaList.value.find((item) => item.id === agendaId)?.title || `议题#${agendaId}`
}

const getVoteStatusLabel = (status?: number) => {
  if (status === 1) return '进行中'
  if (status === 2) return '已结束'
  return '待开始'
}

const getVoteStatusType = (status?: number) => {
  if (status === 1) return 'success'
  if (status === 2) return 'info'
  return 'warning'
}

watch(
  () => props.meetingId,
  (val) => {
    if (val) getList()
  },
  { immediate: true }
)
</script>

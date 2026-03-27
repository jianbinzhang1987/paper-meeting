<template>
  <div>
    <div class="mb-12px flex gap-12px items-center flex-wrap">
      <el-select v-model="selectedAgendaId" clearable placeholder="选择所属议题" class="!w-260px">
        <el-option
          v-for="agenda in agendaList"
          :key="agenda.id"
          :label="agenda.title"
          :value="agenda.id"
        />
      </el-select>
      <el-upload action="#" :auto-upload="false" :show-file-list="false" multiple :on-change="handleFileChange">
        <template #trigger>
          <el-button type="primary">选择文件</el-button>
        </template>
      </el-upload>
      <el-button type="success" :loading="uploading" @click="submitUpload">上传到会议资料</el-button>
    </div>

    <el-table :data="list">
      <el-table-column label="文件名" prop="name" min-width="180" />
      <el-table-column label="所属议题" min-width="140">
        <template #default="scope">
          {{ getAgendaTitle(scope.row.agendaId) }}
        </template>
      </el-table-column>
      <el-table-column label="类型" prop="type" width="160" />
      <el-table-column label="大小" width="100">
        <template #default="scope">
          {{ formatFileSize(scope.row.size) }}
        </template>
      </el-table-column>
      <el-table-column label="上传时间" prop="createTime" :formatter="dateFormatter" width="180" />
      <el-table-column label="操作" width="140">
        <template #default="scope">
          <el-button link type="primary" @click="handlePreview(scope.row.url)">预览</el-button>
          <el-button link type="danger" @click="handleDelete(scope.row.id!)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script lang="ts" setup>
import * as AgendaApi from '@/api/meeting/agenda'
import * as MeetingFileApi from '@/api/meeting/file'
import * as FileApi from '@/api/infra/file'
import { dateFormatter } from '@/utils/formatTime'

const props = defineProps<{ meetingId: number }>()

const message = useMessage()
const list = ref<MeetingFileApi.MeetingFileVO[]>([])
const fileList = ref<File[]>([])
const agendaList = ref<any[]>([])
const selectedAgendaId = ref<number>()
const uploading = ref(false)

const getList = async () => {
  if (!props.meetingId) return
  const [files, agendas] = await Promise.all([
    MeetingFileApi.getMeetingFileList(props.meetingId),
    AgendaApi.getAgendaList(props.meetingId)
  ])
  list.value = files
  agendaList.value = agendas
}

const handleFileChange = (file: any) => {
  if (file.raw) {
    fileList.value.push(file.raw)
  }
}

const submitUpload = async () => {
  if (!fileList.value.length) {
    message.warning('请先选择文件')
    return
  }
  uploading.value = true
  try {
    for (const file of fileList.value) {
      const uploadRes = await FileApi.updateFile({ file })
      await MeetingFileApi.createMeetingFile({
        meetingId: props.meetingId,
        agendaId: selectedAgendaId.value,
        name: file.name,
        url: uploadRes.data,
        type: file.type,
        size: file.size
      })
    }
    fileList.value = []
    message.success('上传成功')
    await getList()
  } finally {
    uploading.value = false
  }
}

const handleDelete = async (id: number) => {
  await MeetingFileApi.deleteMeetingFile(id)
  message.success('删除成功')
  await getList()
}

const getAgendaTitle = (agendaId?: number) => {
  if (!agendaId) return '未关联议题'
  return agendaList.value.find((item) => item.id === agendaId)?.title || `议题#${agendaId}`
}

const handlePreview = (url: string) => {
  window.open(url, '_blank')
}

const formatFileSize = (size?: number) => {
  if (!size) return '0 KB'
  if (size >= 1024 * 1024) {
    return `${(size / 1024 / 1024).toFixed(2)} MB`
  }
  return `${(size / 1024).toFixed(2)} KB`
}

watch(
  () => props.meetingId,
  (val) => {
    if (val) getList()
  },
  { immediate: true }
)
</script>

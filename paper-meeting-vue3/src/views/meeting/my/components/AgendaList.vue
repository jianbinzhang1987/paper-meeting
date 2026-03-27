<template>
  <div>
    <el-button type="primary" @click="handleAdd" class="mb-10px">添加议题</el-button>
    <el-table :data="list" row-key="id" default-expand-all>
      <el-table-column label="标题" prop="title" />
      <el-table-column label="内容" prop="content" show-overflow-tooltip />
      <el-table-column label="页码/排序" prop="sort" width="100" />
      <el-table-column label="操作" width="120">
        <template #default="scope">
          <el-button link type="danger" @click="handleDelete(scope.row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 添加议题对话框 -->
    <el-dialog v-model="dialogVisible" title="添加议题" append-to-body>
      <el-form :model="formData" label-width="80px">
        <el-form-item label="标题" prop="title">
          <el-input v-model="formData.title" />
        </el-form-item>
        <el-form-item label="内容" prop="content">
          <el-input v-model="formData.content" type="textarea" />
        </el-form-item>
        <el-form-item label="排序" prop="sort">
          <el-input-number v-model="formData.sort" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitForm">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import * as AgendaApi from '@/api/meeting/agenda'

const props = defineProps<{ meetingId: number }>()
const list = ref([])
const dialogVisible = ref(false)
const formData = ref({
  meetingId: 0,
  title: '',
  content: '',
  sort: 1,
  parentId: 0
})

const getList = async () => {
  if (!props.meetingId) return
  list.value = await AgendaApi.getAgendaList(props.meetingId)
}

const handleAdd = () => {
  formData.value = {
    meetingId: props.meetingId,
    title: '',
    content: '',
    sort: list.value.length + 1,
    parentId: 0
  }
  dialogVisible.value = true
}

const submitForm = async () => {
  await AgendaApi.createAgenda(formData.value)
  dialogVisible.value = false
  await getList()
}

const handleDelete = async (id: number) => {
  await AgendaApi.deleteAgenda(id)
  await getList()
}

watch(() => props.meetingId, (val) => {
  if (val) getList()
}, { immediate: true })
</script>

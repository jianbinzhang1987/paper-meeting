<template>
  <ContentWrap>
    <el-form :model="queryParams" :inline="true" class="-mb-15px">
      <el-form-item label="分类">
        <el-input v-model="queryParams.category" class="!w-180px" clearable />
      </el-form-item>
      <el-form-item label="名称">
        <el-input v-model="queryParams.name" class="!w-220px" clearable />
      </el-form-item>
      <el-form-item label="状态">
        <el-select v-model="queryParams.enabled" class="!w-160px" clearable>
          <el-option label="启用" :value="true" />
          <el-option label="停用" :value="false" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button @click="handleQuery"><Icon icon="ep:search" />搜索</el-button>
        <el-button @click="resetQuery"><Icon icon="ep:refresh" />重置</el-button>
        <el-button type="primary" @click="openForm('create')"><Icon icon="ep:plus" />新增资料</el-button>
      </el-form-item>
    </el-form>
  </ContentWrap>

  <ContentWrap>
    <el-table v-loading="loading" :data="list">
      <el-table-column label="编号" prop="id" width="80" />
      <el-table-column label="分类" prop="category" width="140" />
      <el-table-column label="名称" prop="name" min-width="200" />
      <el-table-column label="地址" prop="url" min-width="260" show-overflow-tooltip />
      <el-table-column label="类型" prop="fileType" width="100" />
      <el-table-column label="排序" prop="sort" width="80" />
      <el-table-column label="状态" width="90">
        <template #default="scope">
          <el-tag :type="scope.row.enabled ? 'success' : 'info'">{{ scope.row.enabled ? '启用' : '停用' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="160">
        <template #default="scope">
          <el-button link type="primary" @click="openForm('update', scope.row.id)">编辑</el-button>
          <el-button link type="danger" @click="handleDelete(scope.row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <Pagination :total="total" v-model:page="queryParams.pageNo" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </ContentWrap>

  <Dialog v-model="dialogVisible" :title="dialogTitle" width="720px">
    <el-form ref="formRef" :model="formData" :rules="formRules" label-width="90px" v-loading="formLoading">
      <el-form-item label="分类" prop="category"><el-input v-model="formData.category" /></el-form-item>
      <el-form-item label="名称" prop="name"><el-input v-model="formData.name" /></el-form-item>
      <el-form-item label="地址" prop="url"><el-input v-model="formData.url" /></el-form-item>
      <el-form-item label="类型"><el-input v-model="formData.fileType" /></el-form-item>
      <el-form-item label="排序"><el-input-number v-model="formData.sort" :min="0" class="!w-full" /></el-form-item>
      <el-form-item label="启用"><el-switch v-model="formData.enabled" /></el-form-item>
      <el-form-item label="备注"><el-input v-model="formData.remark" type="textarea" :rows="3" /></el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="dialogVisible = false">取消</el-button>
      <el-button type="primary" :loading="formLoading" @click="submitForm">确定</el-button>
    </template>
  </Dialog>
</template>

<script lang="ts" setup>
import * as PublicFileApi from '@/api/meeting/publicFile'

defineOptions({ name: 'MeetingPublicFile' })

const message = useMessage()
const loading = ref(false)
const total = ref(0)
const list = ref<any[]>([])
const queryParams = reactive({ pageNo: 1, pageSize: 10, category: undefined, name: undefined, enabled: undefined })
const dialogVisible = ref(false)
const dialogTitle = ref('')
const formLoading = ref(false)
const formType = ref<'create' | 'update'>('create')
const formRef = ref()
const formData = ref<any>({ id: undefined, category: '', name: '', url: '', fileType: '', sort: 0, enabled: true, remark: '' })
const formRules = reactive({
  category: [{ required: true, message: '分类不能为空', trigger: 'blur' }],
  name: [{ required: true, message: '名称不能为空', trigger: 'blur' }],
  url: [{ required: true, message: '地址不能为空', trigger: 'blur' }]
})

const getList = async () => {
  loading.value = true
  try {
    const data = await PublicFileApi.getMeetingPublicFilePage(queryParams)
    list.value = data.list
    total.value = data.total
  } finally {
    loading.value = false
  }
}
const handleQuery = () => { queryParams.pageNo = 1; getList() }
const resetQuery = () => { queryParams.category = undefined; queryParams.name = undefined; queryParams.enabled = undefined; handleQuery() }
const openForm = async (type: 'create' | 'update', id?: number) => {
  dialogVisible.value = true
  dialogTitle.value = type === 'create' ? '新增资料' : '编辑资料'
  formType.value = type
  formData.value = { id: undefined, category: '', name: '', url: '', fileType: '', sort: 0, enabled: true, remark: '' }
  if (id) formData.value = await PublicFileApi.getMeetingPublicFile(id)
}
const submitForm = async () => {
  const valid = await formRef.value?.validate()
  if (!valid) return
  formLoading.value = true
  try {
    if (formType.value === 'create') await PublicFileApi.createMeetingPublicFile(formData.value)
    else await PublicFileApi.updateMeetingPublicFile(formData.value)
    message.success('保存成功')
    dialogVisible.value = false
    await getList()
  } finally { formLoading.value = false }
}
const handleDelete = async (id: number) => {
  try {
    await message.delConfirm()
    await PublicFileApi.deleteMeetingPublicFile(id)
    message.success('删除成功')
    await getList()
  } catch {}
}
onMounted(getList)
</script>

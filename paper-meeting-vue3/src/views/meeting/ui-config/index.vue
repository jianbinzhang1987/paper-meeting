<template>
  <ContentWrap>
    <el-form :model="queryParams" :inline="true" class="-mb-15px">
      <el-form-item label="样式名"><el-input v-model="queryParams.name" class="!w-220px" clearable /></el-form-item>
      <el-form-item label="状态">
        <el-select v-model="queryParams.active" class="!w-160px" clearable>
          <el-option label="已启用" :value="true" />
          <el-option label="未启用" :value="false" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button @click="handleQuery"><Icon icon="ep:search" />搜索</el-button>
        <el-button @click="resetQuery"><Icon icon="ep:refresh" />重置</el-button>
        <el-button type="primary" @click="openForm('create')"><Icon icon="ep:plus" />新增样式</el-button>
      </el-form-item>
    </el-form>
  </ContentWrap>

  <ContentWrap>
    <el-table v-loading="loading" :data="list">
      <el-table-column label="编号" prop="id" width="80" />
      <el-table-column label="样式名" prop="name" min-width="180" />
      <el-table-column label="主色" width="120">
        <template #default="scope"><span :style="{ color: scope.row.primaryColor }">{{ scope.row.primaryColor }}</span></template>
      </el-table-column>
      <el-table-column label="辅色" prop="accentColor" width="120" />
      <el-table-column label="字号" prop="fontSize" width="80" />
      <el-table-column label="状态" width="90">
        <template #default="scope"><el-tag :type="scope.row.active ? 'success' : 'info'">{{ scope.row.active ? '启用' : '未启用' }}</el-tag></template>
      </el-table-column>
      <el-table-column label="操作" width="220">
        <template #default="scope">
          <el-button link type="primary" @click="openForm('update', scope.row.id)">编辑</el-button>
          <el-button link type="success" v-if="!scope.row.active" @click="handleActivate(scope.row.id)">启用</el-button>
          <el-button link type="danger" @click="handleDelete(scope.row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <Pagination :total="total" v-model:page="queryParams.pageNo" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </ContentWrap>

  <Dialog v-model="dialogVisible" :title="dialogTitle" width="760px">
    <el-form ref="formRef" :model="formData" :rules="formRules" label-width="100px" v-loading="formLoading">
      <el-form-item label="样式名" prop="name"><el-input v-model="formData.name" /></el-form-item>
      <el-form-item label="主色" prop="primaryColor"><el-input v-model="formData.primaryColor" placeholder="#C62828" /></el-form-item>
      <el-form-item label="辅色"><el-input v-model="formData.accentColor" placeholder="#F4B400" /></el-form-item>
      <el-form-item label="基础字号"><el-input-number v-model="formData.fontSize" :min="12" :max="40" class="!w-full" /></el-form-item>
      <el-form-item label="背景图"><el-input v-model="formData.backgroundImageUrl" /></el-form-item>
      <el-form-item label="Logo"><el-input v-model="formData.logoUrl" /></el-form-item>
      <el-form-item label="扩展样式"><el-input v-model="formData.extraCss" type="textarea" :rows="4" /></el-form-item>
      <el-form-item label="备注"><el-input v-model="formData.remark" type="textarea" :rows="2" /></el-form-item>
      <el-form-item label="创建即启用"><el-switch v-model="formData.active" /></el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="dialogVisible = false">取消</el-button>
      <el-button type="primary" :loading="formLoading" @click="submitForm">确定</el-button>
    </template>
  </Dialog>
</template>

<script lang="ts" setup>
import * as UiConfigApi from '@/api/meeting/uiConfig'

defineOptions({ name: 'MeetingUiConfig' })
const message = useMessage()
const loading = ref(false)
const total = ref(0)
const list = ref<any[]>([])
const queryParams = reactive({ pageNo: 1, pageSize: 10, name: undefined, active: undefined })
const dialogVisible = ref(false)
const dialogTitle = ref('')
const formLoading = ref(false)
const formType = ref<'create' | 'update'>('create')
const formRef = ref()
const formData = ref<any>({ id: undefined, name: '', fontSize: 16, primaryColor: '', accentColor: '', backgroundImageUrl: '', logoUrl: '', extraCss: '', active: false, remark: '' })
const formRules = reactive({
  name: [{ required: true, message: '样式名不能为空', trigger: 'blur' }],
  primaryColor: [{ required: true, message: '主色不能为空', trigger: 'blur' }]
})
const getList = async () => {
  loading.value = true
  try {
    const data = await UiConfigApi.getMeetingUiConfigPage(queryParams)
    list.value = data.list
    total.value = data.total
  } finally { loading.value = false }
}
const handleQuery = () => { queryParams.pageNo = 1; getList() }
const resetQuery = () => { queryParams.name = undefined; queryParams.active = undefined; handleQuery() }
const openForm = async (type: 'create' | 'update', id?: number) => {
  dialogVisible.value = true
  dialogTitle.value = type === 'create' ? '新增样式' : '编辑样式'
  formType.value = type
  formData.value = { id: undefined, name: '', fontSize: 16, primaryColor: '', accentColor: '', backgroundImageUrl: '', logoUrl: '', extraCss: '', active: false, remark: '' }
  if (id) formData.value = await UiConfigApi.getMeetingUiConfig(id)
}
const submitForm = async () => {
  const valid = await formRef.value?.validate()
  if (!valid) return
  formLoading.value = true
  try {
    if (formType.value === 'create') await UiConfigApi.createMeetingUiConfig(formData.value)
    else await UiConfigApi.updateMeetingUiConfig(formData.value)
    message.success('保存成功')
    dialogVisible.value = false
    await getList()
  } finally { formLoading.value = false }
}
const handleActivate = async (id: number) => { await UiConfigApi.activateMeetingUiConfig(id); message.success('已启用'); await getList() }
const handleDelete = async (id: number) => {
  try { await message.delConfirm(); await UiConfigApi.deleteMeetingUiConfig(id); message.success('删除成功'); await getList() } catch {}
}
onMounted(getList)
</script>

<template>
  <ContentWrap>
    <el-form :model="queryParams" :inline="true" class="-mb-15px">
      <el-form-item label="客户端">
        <el-select v-model="queryParams.clientType" class="!w-180px" clearable>
          <el-option label="安卓客户端" :value="1" />
          <el-option label="呼叫服务端" :value="2" />
          <el-option label="大屏端" :value="3" />
          <el-option label="信息发布端" :value="4" />
        </el-select>
      </el-form-item>
      <el-form-item label="名称"><el-input v-model="queryParams.name" class="!w-220px" clearable /></el-form-item>
      <el-form-item label="状态">
        <el-select v-model="queryParams.active" class="!w-160px" clearable>
          <el-option label="当前启用" :value="true" />
          <el-option label="未启用" :value="false" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button @click="handleQuery"><Icon icon="ep:search" />搜索</el-button>
        <el-button @click="resetQuery"><Icon icon="ep:refresh" />重置</el-button>
        <el-button type="primary" @click="openForm('create')"><Icon icon="ep:plus" />新增安装包</el-button>
      </el-form-item>
    </el-form>
  </ContentWrap>

  <ContentWrap>
    <el-table v-loading="loading" :data="list">
      <el-table-column label="编号" prop="id" width="80" />
      <el-table-column label="客户端" width="120">
        <template #default="scope">{{ getClientTypeLabel(scope.row.clientType) }}</template>
      </el-table-column>
      <el-table-column label="名称" prop="name" min-width="180" />
      <el-table-column label="版本名" prop="versionName" width="120" />
      <el-table-column label="版本号" prop="versionCode" width="90" />
      <el-table-column label="强制更新" width="100">
        <template #default="scope">{{ scope.row.forceUpdate ? '是' : '否' }}</template>
      </el-table-column>
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
      <el-form-item label="客户端" prop="clientType">
        <el-select v-model="formData.clientType" class="!w-full">
          <el-option label="安卓客户端" :value="1" />
          <el-option label="呼叫服务端" :value="2" />
          <el-option label="大屏端" :value="3" />
          <el-option label="信息发布端" :value="4" />
        </el-select>
      </el-form-item>
      <el-form-item label="名称" prop="name"><el-input v-model="formData.name" /></el-form-item>
      <el-form-item label="版本名" prop="versionName"><el-input v-model="formData.versionName" /></el-form-item>
      <el-form-item label="版本号" prop="versionCode"><el-input-number v-model="formData.versionCode" :min="1" class="!w-full" /></el-form-item>
      <el-form-item label="下载地址" prop="downloadUrl"><el-input v-model="formData.downloadUrl" /></el-form-item>
      <el-form-item label="MD5"><el-input v-model="formData.md5" /></el-form-item>
      <el-form-item label="强制更新"><el-switch v-model="formData.forceUpdate" /></el-form-item>
      <el-form-item label="创建即启用"><el-switch v-model="formData.active" /></el-form-item>
      <el-form-item label="更新说明"><el-input v-model="formData.remark" type="textarea" :rows="3" /></el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="dialogVisible = false">取消</el-button>
      <el-button type="primary" :loading="formLoading" @click="submitForm">确定</el-button>
    </template>
  </Dialog>
</template>

<script lang="ts" setup>
import * as AppVersionApi from '@/api/meeting/appVersion'

defineOptions({ name: 'MeetingAppVersion' })
const message = useMessage()
const loading = ref(false)
const total = ref(0)
const list = ref<any[]>([])
const queryParams = reactive({ pageNo: 1, pageSize: 10, clientType: undefined, active: undefined, name: undefined })
const dialogVisible = ref(false)
const dialogTitle = ref('')
const formLoading = ref(false)
const formType = ref<'create' | 'update'>('create')
const formRef = ref()
const formData = ref<any>({ id: undefined, clientType: 1, name: '', versionName: '', versionCode: 1, downloadUrl: '', md5: '', forceUpdate: false, active: false, remark: '' })
const formRules = reactive({
  clientType: [{ required: true, message: '客户端不能为空', trigger: 'change' }],
  name: [{ required: true, message: '名称不能为空', trigger: 'blur' }],
  versionName: [{ required: true, message: '版本名不能为空', trigger: 'blur' }],
  versionCode: [{ required: true, message: '版本号不能为空', trigger: 'blur' }],
  downloadUrl: [{ required: true, message: '下载地址不能为空', trigger: 'blur' }]
})
const getClientTypeLabel = (value: number) => ({ 1: '安卓客户端', 2: '呼叫服务端', 3: '大屏端', 4: '信息发布端' }[value] || '-')
const getList = async () => {
  loading.value = true
  try {
    const data = await AppVersionApi.getMeetingAppVersionPage(queryParams)
    list.value = data.list
    total.value = data.total
  } finally { loading.value = false }
}
const handleQuery = () => { queryParams.pageNo = 1; getList() }
const resetQuery = () => { queryParams.clientType = undefined; queryParams.active = undefined; queryParams.name = undefined; handleQuery() }
const openForm = async (type: 'create' | 'update', id?: number) => {
  dialogVisible.value = true
  dialogTitle.value = type === 'create' ? '新增安装包' : '编辑安装包'
  formType.value = type
  formData.value = { id: undefined, clientType: 1, name: '', versionName: '', versionCode: 1, downloadUrl: '', md5: '', forceUpdate: false, active: false, remark: '' }
  if (id) formData.value = await AppVersionApi.getMeetingAppVersion(id)
}
const submitForm = async () => {
  const valid = await formRef.value?.validate()
  if (!valid) return
  formLoading.value = true
  try {
    if (formType.value === 'create') await AppVersionApi.createMeetingAppVersion(formData.value)
    else await AppVersionApi.updateMeetingAppVersion(formData.value)
    message.success('保存成功')
    dialogVisible.value = false
    await getList()
  } finally { formLoading.value = false }
}
const handleActivate = async (id: number) => { await AppVersionApi.activateMeetingAppVersion(id); message.success('已启用'); await getList() }
const handleDelete = async (id: number) => {
  try { await message.delConfirm(); await AppVersionApi.deleteMeetingAppVersion(id); message.success('删除成功'); await getList() } catch {}
}
onMounted(getList)
</script>

<template>
  <ContentWrap>
    <el-form :model="queryParams" :inline="true" class="-mb-15px">
      <el-form-item label="网站名称">
        <el-input v-model="queryParams.siteName" class="!w-220px" clearable />
      </el-form-item>
      <el-form-item label="状态">
        <el-select v-model="queryParams.active" class="!w-160px" clearable>
          <el-option label="启用中" :value="true" />
          <el-option label="未启用" :value="false" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button @click="handleQuery"><Icon icon="ep:search" />搜索</el-button>
        <el-button @click="resetQuery"><Icon icon="ep:refresh" />重置</el-button>
        <el-button type="primary" @click="openForm('create')"><Icon icon="ep:plus" />新增贴牌</el-button>
      </el-form-item>
    </el-form>
  </ContentWrap>

  <el-row :gutter="16">
    <el-col :xs="24" :xl="14">
      <ContentWrap>
        <el-table v-loading="loading" :data="list" @row-click="selectRow">
          <el-table-column label="网站名称" prop="siteName" min-width="180" />
          <el-table-column label="侧边栏标题" prop="sidebarTitle" min-width="160" />
          <el-table-column label="状态" width="90">
            <template #default="scope">
              <el-tag :type="scope.row.active ? 'success' : 'info'">{{ scope.row.active ? '启用' : '未启用' }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="220">
            <template #default="scope">
              <el-button link type="primary" @click.stop="openForm('update', scope.row.id)">编辑</el-button>
              <el-button link type="success" v-if="!scope.row.active" @click.stop="handleActivate(scope.row.id)">启用</el-button>
              <el-button link type="danger" @click.stop="handleDelete(scope.row.id)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
        <Pagination :total="total" v-model:page="queryParams.pageNo" v-model:limit="queryParams.pageSize" @pagination="getList" />
      </ContentWrap>
    </el-col>
    <el-col :xs="24" :xl="10">
      <ContentWrap>
        <div class="section-title mb-12px">贴牌预览</div>
        <template v-if="activeRecord">
          <div class="brand-preview">
            <div class="brand-sidebar">
              <img v-if="activeRecord.siteLogoUrl" :src="activeRecord.siteLogoUrl" class="brand-logo" alt="logo" />
              <div v-else class="brand-logo brand-logo--placeholder">LOGO</div>
              <div class="brand-menu">{{ activeRecord.sidebarTitle || activeRecord.siteName }}</div>
              <div class="brand-subtitle">{{ activeRecord.sidebarSubtitle || '会议管理后台' }}</div>
            </div>
            <div class="brand-main">
              <div class="brand-header">
                <div class="brand-site-name">{{ activeRecord.siteName }}</div>
                <el-tag :type="activeRecord.active ? 'success' : 'info'">{{ activeRecord.active ? '当前启用' : '草稿' }}</el-tag>
              </div>
              <div class="brand-card">
                <div class="brand-card__title">会议系统专属贴牌</div>
                <div class="brand-card__text">这里会影响站点名称、LOGO 和侧边栏文字展示。</div>
              </div>
            </div>
          </div>
        </template>
        <el-empty v-else description="选择一条贴牌记录后查看预览" />
      </ContentWrap>
    </el-col>
  </el-row>

  <Dialog v-model="dialogVisible" :title="dialogTitle" width="760px">
    <el-form ref="formRef" :model="formData" :rules="formRules" label-width="100px" v-loading="formLoading">
      <el-form-item label="网站名称" prop="siteName"><el-input v-model="formData.siteName" /></el-form-item>
      <el-form-item label="网站 Logo"><UploadImg v-model="formData.siteLogoUrl" :limit="1" :file-size="5" /></el-form-item>
      <el-form-item label="侧边栏标题"><el-input v-model="formData.sidebarTitle" /></el-form-item>
      <el-form-item label="侧边栏副标题"><el-input v-model="formData.sidebarSubtitle" /></el-form-item>
      <el-form-item label="备注"><el-input v-model="formData.remark" type="textarea" :rows="3" /></el-form-item>
      <el-form-item label="创建即启用"><el-switch v-model="formData.active" /></el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="dialogVisible = false">取消</el-button>
      <el-button type="primary" :loading="formLoading" @click="submitForm">确定</el-button>
    </template>
  </Dialog>
</template>

<script lang="ts" setup>
import * as BrandingApi from '@/api/meeting/branding'

defineOptions({ name: 'MeetingBranding' })

const message = useMessage()
const loading = ref(false)
const total = ref(0)
const list = ref<BrandingApi.MeetingBrandingVO[]>([])
const activeRecord = ref<BrandingApi.MeetingBrandingVO>()
const queryParams = reactive({ pageNo: 1, pageSize: 10, siteName: undefined as undefined | string, active: undefined as undefined | boolean })
const dialogVisible = ref(false)
const dialogTitle = ref('')
const formLoading = ref(false)
const formType = ref<'create' | 'update'>('create')
const formRef = ref()
const formData = ref<BrandingApi.MeetingBrandingVO>({ id: undefined, siteName: '', siteLogoUrl: '', sidebarTitle: '', sidebarSubtitle: '', active: false, remark: '' })

const formRules = reactive({
  siteName: [{ required: true, message: '网站名称不能为空', trigger: 'blur' }]
})

const getList = async () => {
  loading.value = true
  try {
    const data = await BrandingApi.getMeetingBrandingPage(queryParams)
    list.value = data.list
    total.value = data.total
    if (!activeRecord.value && list.value.length) activeRecord.value = list.value[0]
  } finally {
    loading.value = false
  }
}

const handleQuery = () => {
  queryParams.pageNo = 1
  getList()
}

const resetQuery = () => {
  queryParams.siteName = undefined
  queryParams.active = undefined
  handleQuery()
}

const selectRow = (row: BrandingApi.MeetingBrandingVO) => {
  activeRecord.value = row
}

const openForm = async (type: 'create' | 'update', id?: number) => {
  dialogVisible.value = true
  dialogTitle.value = type === 'create' ? '新增贴牌' : '编辑贴牌'
  formType.value = type
  formData.value = { id: undefined, siteName: '', siteLogoUrl: '', sidebarTitle: '', sidebarSubtitle: '', active: false, remark: '' }
  if (id) formData.value = await BrandingApi.getMeetingBranding(id)
}

const submitForm = async () => {
  const valid = await formRef.value?.validate()
  if (!valid) return
  formLoading.value = true
  try {
    if (formType.value === 'create') await BrandingApi.createMeetingBranding(formData.value)
    else await BrandingApi.updateMeetingBranding(formData.value)
    message.success('保存成功')
    dialogVisible.value = false
    await getList()
  } finally {
    formLoading.value = false
  }
}

const handleActivate = async (id: number) => {
  await BrandingApi.activateMeetingBranding(id)
  message.success('已启用')
  await getList()
}

const handleDelete = async (id: number) => {
  try {
    await message.delConfirm()
    await BrandingApi.deleteMeetingBranding(id)
    message.success('删除成功')
    await getList()
  } catch {}
}

onMounted(getList)
</script>

<style lang="scss" scoped>
.section-title {
  font-size: 16px;
  font-weight: 600;
}

.brand-preview {
  display: grid;
  grid-template-columns: 180px 1fr;
  overflow: hidden;
  min-height: 300px;
  border-radius: 18px;
  background: linear-gradient(135deg, #f8fafc 0%, #eef2ff 100%);
}

.brand-sidebar {
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 18px;
  background: #0f172a;
  color: #fff;
}

.brand-logo {
  width: 100%;
  height: 72px;
  border-radius: 14px;
  background: rgba(255, 255, 255, 0.12);
  object-fit: contain;
}

.brand-logo--placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
}

.brand-menu {
  padding: 10px 12px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.1);
}

.brand-subtitle {
  color: rgba(255, 255, 255, 0.72);
  font-size: 12px;
  line-height: 1.6;
}

.brand-main {
  padding: 20px;
}

.brand-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.brand-site-name {
  font-size: 22px;
  font-weight: 700;
  color: #1e3a8a;
}

.brand-card {
  margin-top: 18px;
  padding: 18px;
  border-radius: 16px;
  background: #fff;
}

.brand-card__title {
  font-size: 16px;
  font-weight: 700;
}

.brand-card__text {
  margin-top: 8px;
  color: var(--el-text-color-secondary);
  line-height: 1.7;
}
</style>

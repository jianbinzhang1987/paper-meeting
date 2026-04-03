<template>
  <div class="meeting-ui-config-page">
    <ContentWrap>
      <div class="palette-grid">
        <div
          v-for="item in list.slice(0, 4)"
          :key="item.id"
          class="palette-card"
          :style="buildPreviewVars(item)"
          @click="selectRow(item)"
        >
          <div class="palette-card__top">
            <div>
              <div class="palette-card__name">{{ item.name }}</div>
              <div class="palette-card__meta">
                {{ item.active ? '当前启用' : '待启用' }} · 字号 {{ item.fontSize || 16 }}px
              </div>
            </div>
            <el-tag :type="item.active ? 'success' : 'info'">{{ item.active ? '启用中' : '草稿' }}</el-tag>
          </div>
          <div class="palette-card__preview">
            <div class="mock-nav">无纸化会议</div>
            <div class="mock-content">
              <div class="mock-title">会前引导</div>
              <div class="mock-desc">颜色、字号、背景与 LOGO 在这里做即时预览。</div>
              <div class="mock-actions">
                <span>确认参会</span>
                <span>查看资料</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </ContentWrap>

    <ContentWrap>
      <el-form :model="queryParams" :inline="true" class="-mb-15px">
        <el-form-item label="样式名">
          <el-input v-model="queryParams.name" class="!w-220px" clearable />
        </el-form-item>
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

    <el-row :gutter="16">
      <el-col :xs="24" :xl="14">
        <ContentWrap>
          <el-table v-loading="loading" :data="list" @row-click="selectRow">
            <el-table-column label="样式名" prop="name" min-width="180" />
            <el-table-column label="主色" width="120">
              <template #default="scope">
                <span class="color-chip">
                  <span class="color-dot" :style="{ background: scope.row.primaryColor }"></span>
                  {{ scope.row.primaryColor }}
                </span>
              </template>
            </el-table-column>
            <el-table-column label="辅色" width="120">
              <template #default="scope">
                <span class="color-chip">
                  <span class="color-dot" :style="{ background: scope.row.accentColor || '#d1d5db' }"></span>
                  {{ scope.row.accentColor || '-' }}
                </span>
              </template>
            </el-table-column>
            <el-table-column label="字号" prop="fontSize" width="80" />
            <el-table-column label="状态" width="90">
              <template #default="scope">
                <el-tag :type="scope.row.active ? 'success' : 'info'">
                  {{ scope.row.active ? '启用' : '未启用' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="220" fixed="right">
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
          <div class="section-title mb-12px">样式预览与发布说明</div>
          <template v-if="activePreview">
            <div class="preview-shell" :style="buildPreviewVars(activePreview)">
              <div class="preview-sidebar">
                <div class="preview-logo" v-if="activePreview.logoUrl">
                  <img :src="activePreview.logoUrl" alt="logo" />
                </div>
                <div v-else class="preview-logo preview-logo--placeholder">LOGO</div>
                <div class="preview-menu">会议首页</div>
                <div class="preview-menu is-active">资料中心</div>
                <div class="preview-menu">会议签到</div>
              </div>
              <div class="preview-main">
                <div class="preview-banner">
                  <div>
                    <div class="preview-title">{{ activePreview.name }}</div>
                    <div class="preview-subtitle">客户端首页实时预览</div>
                  </div>
                  <el-tag :type="activePreview.active ? 'success' : 'warning'">
                    {{ activePreview.active ? '当前启用' : '未启用' }}
                  </el-tag>
                </div>
                <div class="preview-panel">
                  <div class="preview-panel__title">会前提示</div>
                  <div class="preview-panel__text">参会资料已同步到终端，请于会议开始前 10 分钟完成设备检查。</div>
                </div>
                <div class="preview-panel preview-panel--light">
                  <div class="preview-panel__title">品牌元素</div>
                  <div class="preview-panel__text">主色、辅色、背景图与扩展样式会直接影响终端视觉语言。</div>
                </div>
              </div>
            </div>
            <div class="mt-12px flex gap-10px flex-wrap">
              <el-button type="primary" :loading="dispatchLoading" @click="dispatchUiConfig(false)">
                下发样式更新
              </el-button>
              <el-button :loading="dispatchLoading" @click="dispatchUiConfig(true)">
                重推未回执终端
              </el-button>
            </div>
            <div class="terminal-summary mt-16px">
              <div class="terminal-summary__item">
                <span>在线终端</span>
                <strong>{{ terminalSummary?.onlineCount || 0 }}</strong>
              </div>
              <div class="terminal-summary__item">
                <span>收到配置</span>
                <strong>{{ terminalSummary?.matchedCount || 0 }}</strong>
              </div>
              <div class="terminal-summary__item">
                <span>未回执</span>
                <strong>{{ terminalSummary?.pendingCount || 0 }}</strong>
              </div>
              <div class="terminal-summary__item">
                <span>最近心跳</span>
                <strong>{{ formatTime(terminalSummary?.latestHeartbeatTime) }}</strong>
              </div>
            </div>
          </template>
          <el-empty v-else description="选择一套样式后查看预览" />
        </ContentWrap>
      </el-col>
    </el-row>

    <ContentWrap>
      <div class="section-title mb-12px">终端样式回执</div>
      <el-alert
        v-if="dispatchResult"
        type="info"
        :closable="false"
        show-icon
        class="mb-12px"
        :title="`下发结果：总计 ${dispatchResult.totalCount}，已下发 ${dispatchResult.dispatchedCount}，失败 ${dispatchResult.failedCount}，已命中 ${dispatchResult.matchedCount}`"
      />
      <el-table :data="terminalList" empty-text="暂无终端上报记录">
        <el-table-column label="终端" min-width="220">
          <template #default="scope">
            <div>{{ scope.row.roomName }} / {{ scope.row.seatName }}</div>
            <div class="preview-subtitle">{{ scope.row.deviceName || '-' }}</div>
          </template>
        </el-table-column>
        <el-table-column label="在线状态" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.online ? 'success' : 'info'">
              {{ scope.row.online ? '在线' : '离线' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="命中状态" width="110">
          <template #default="scope">
            <el-tag :type="scope.row.matchSelected ? 'success' : 'warning'">
              {{ scope.row.matchSelected ? '已收到' : '未回执' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="当前样式" min-width="180">
          <template #default="scope">{{ scope.row.uiConfigName || '-' }}</template>
        </el-table-column>
        <el-table-column label="贴牌" min-width="160">
          <template #default="scope">{{ scope.row.brandingName || '-' }}</template>
        </el-table-column>
        <el-table-column label="主题" width="90">
          <template #default="scope">{{ scope.row.themeMode || '-' }}</template>
        </el-table-column>
        <el-table-column label="最后心跳" min-width="170">
          <template #default="scope">{{ formatTime(scope.row.lastHeartbeatTime) }}</template>
        </el-table-column>
      </el-table>
      <div v-if="dispatchResult" class="mt-16px">
        <div class="section-title mb-8px">最近一次下发明细</div>
        <el-table :data="dispatchResult.items" max-height="320" empty-text="暂无下发记录">
          <el-table-column label="终端" min-width="220">
            <template #default="scope">
              <div>{{ scope.row.roomName || '-' }} / {{ scope.row.seatName || '-' }}</div>
              <div class="preview-subtitle">{{ scope.row.deviceName || '-' }}</div>
            </template>
          </el-table-column>
          <el-table-column label="在线" width="90">
            <template #default="scope">
              <el-tag :type="scope.row.online ? 'success' : 'info'">{{ scope.row.online ? '在线' : '离线' }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="当前样式" prop="currentValue" min-width="160" />
          <el-table-column label="状态" width="110">
            <template #default="scope">
              <el-tag :type="scope.row.deliveryStatus === 'dispatched' ? 'success' : (scope.row.deliveryStatus === 'failed' ? 'danger' : 'info')">
                {{ scope.row.deliveryStatusText }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="说明" prop="failureReason" min-width="220" show-overflow-tooltip />
        </el-table>
      </div>
    </ContentWrap>
  </div>

  <Dialog v-model="dialogVisible" :title="dialogTitle" width="860px">
    <div class="dialog-layout">
      <el-form ref="formRef" :model="formData" :rules="formRules" label-width="100px" v-loading="formLoading" class="dialog-form">
        <el-form-item label="样式名" prop="name"><el-input v-model="formData.name" /></el-form-item>
        <el-form-item label="主色" prop="primaryColor"><el-input v-model="formData.primaryColor" placeholder="#C62828" /></el-form-item>
        <el-form-item label="辅色"><el-input v-model="formData.accentColor" placeholder="#F4B400" /></el-form-item>
        <el-form-item label="基础字号"><el-input-number v-model="formData.fontSize" :min="12" :max="40" class="!w-full" /></el-form-item>
        <el-form-item label="背景图">
          <UploadImg v-model="formData.backgroundImageUrl" :limit="1" :file-size="10" />
        </el-form-item>
        <el-form-item label="Logo">
          <UploadImg v-model="formData.logoUrl" :limit="1" :file-size="5" />
        </el-form-item>
        <el-form-item label="扩展样式"><el-input v-model="formData.extraCss" type="textarea" :rows="4" /></el-form-item>
        <el-form-item label="备注"><el-input v-model="formData.remark" type="textarea" :rows="2" /></el-form-item>
        <el-form-item label="创建即启用"><el-switch v-model="formData.active" /></el-form-item>
      </el-form>
      <div class="dialog-preview">
        <div class="section-title mb-12px">实时预览</div>
        <div class="preview-shell preview-shell--compact" :style="buildPreviewVars(formData)">
          <div class="preview-sidebar">
            <div class="preview-logo" v-if="formData.logoUrl">
              <img :src="formData.logoUrl" alt="logo" />
            </div>
            <div v-else class="preview-logo preview-logo--placeholder">LOGO</div>
            <div class="preview-menu">会议首页</div>
            <div class="preview-menu is-active">资料中心</div>
          </div>
          <div class="preview-main">
            <div class="preview-banner">
              <div>
                <div class="preview-title">{{ formData.name || '未命名样式' }}</div>
                <div class="preview-subtitle">保存前即可看到视觉效果</div>
              </div>
            </div>
            <div class="preview-panel">
              <div class="preview-panel__title">主色按钮</div>
              <div class="preview-panel__text">字体、背景与 logo 变化会同步反映到此区域。</div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <template #footer>
      <el-button @click="dialogVisible = false">取消</el-button>
      <el-button type="primary" :loading="formLoading" @click="submitForm">确定</el-button>
    </template>
  </Dialog>
</template>

<script lang="ts" setup>
import * as UiConfigApi from '@/api/meeting/uiConfig'
import { formatDate } from '@/utils/formatTime'
import * as TerminalStatusApi from '@/api/meeting/terminalStatus'

defineOptions({ name: 'MeetingUiConfig' })

const message = useMessage()
const loading = ref(false)
const total = ref(0)
const list = ref<UiConfigApi.MeetingUiConfigVO[]>([])
const activePreview = ref<UiConfigApi.MeetingUiConfigVO>()
const terminalSummary = ref<TerminalStatusApi.MeetingTerminalStatusSummaryVO>()
const terminalList = ref<TerminalStatusApi.MeetingTerminalStatusVO[]>([])
const dispatchLoading = ref(false)
const dispatchResult = ref<TerminalStatusApi.MeetingTerminalDispatchRespVO>()
const queryParams = reactive({ pageNo: 1, pageSize: 10, name: undefined as undefined | string, active: undefined as undefined | boolean })
const dialogVisible = ref(false)
const dialogTitle = ref('')
const formLoading = ref(false)
const formType = ref<'create' | 'update'>('create')
const formRef = ref()
const formData = ref<UiConfigApi.MeetingUiConfigVO>({
  id: undefined,
  name: '',
  fontSize: 16,
  primaryColor: '',
  accentColor: '',
  backgroundImageUrl: '',
  logoUrl: '',
  extraCss: '',
  active: false,
  remark: ''
})

const formRules = reactive({
  name: [{ required: true, message: '样式名不能为空', trigger: 'blur' }],
  primaryColor: [{ required: true, message: '主色不能为空', trigger: 'blur' }]
})

const formatTime = (value?: Date) => (value ? formatDate(value) : '-')

const loadTerminalInsights = async () => {
  if (!activePreview.value?.id) {
    terminalSummary.value = undefined
    terminalList.value = []
    return
  }
  const params = { clientType: 1, uiConfigId: activePreview.value.id }
  const [summary, listData] = await Promise.all([
    TerminalStatusApi.getMeetingTerminalStatusSummary(params),
    TerminalStatusApi.getMeetingTerminalStatusList(params)
  ])
  terminalSummary.value = summary
  terminalList.value = listData
}

const getList = async () => {
  loading.value = true
  try {
    const data = await UiConfigApi.getMeetingUiConfigPage(queryParams)
    list.value = data.list
    total.value = data.total
    if (!activePreview.value && list.value.length) {
      activePreview.value = list.value[0]
      await loadTerminalInsights()
      return
    }
    if (activePreview.value) {
      const matched = list.value.find((item) => item.id === activePreview.value?.id)
      activePreview.value = matched || list.value[0]
      await loadTerminalInsights()
    }
  } finally {
    loading.value = false
  }
}

const handleQuery = () => {
  queryParams.pageNo = 1
  getList()
}

const resetQuery = () => {
  queryParams.name = undefined
  queryParams.active = undefined
  handleQuery()
}

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
  } finally {
    formLoading.value = false
  }
}

const handleActivate = async (id: number) => {
  await UiConfigApi.activateMeetingUiConfig(id)
  message.success('已启用')
  await getList()
}

const handleDelete = async (id: number) => {
  try {
    await message.delConfirm()
    await UiConfigApi.deleteMeetingUiConfig(id)
    message.success('删除成功')
    await getList()
    if (activePreview.value?.id === id) {
      activePreview.value = list.value[0]
    }
  } catch {}
}

const selectRow = (row: UiConfigApi.MeetingUiConfigVO) => {
  activePreview.value = row
  loadTerminalInsights()
}

const dispatchUiConfig = async (onlyPending: boolean) => {
  if (!activePreview.value?.id) {
    message.warning('请先选择样式记录')
    return
  }
  dispatchLoading.value = true
  try {
    dispatchResult.value = await TerminalStatusApi.dispatchUiConfig({
      uiConfigId: activePreview.value.id,
      clientType: 1,
      onlyPending
    })
    message.success(onlyPending ? '已执行重推' : '已下发样式更新指令')
    await loadTerminalInsights()
  } finally {
    dispatchLoading.value = false
  }
}

const buildPreviewVars = (item?: UiConfigApi.MeetingUiConfigVO) => ({
  '--preview-primary': item?.primaryColor || '#c62828',
  '--preview-accent': item?.accentColor || '#f4b400',
  '--preview-font-size': `${item?.fontSize || 16}px`,
  '--preview-bg': item?.backgroundImageUrl ? `url(${item.backgroundImageUrl}) center/cover no-repeat` : 'linear-gradient(135deg, #f8fafc 0%, #fff7ed 100%)'
})

watch(
  () => activePreview.value?.id,
  (value, oldValue) => {
    if (!value || value === oldValue) return
    loadTerminalInsights()
  }
)

onMounted(getList)
</script>

<style lang="scss" scoped>
.meeting-ui-config-page {
  .palette-grid {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 16px;
  }

  .palette-card {
    overflow: hidden;
    padding: 16px;
    border-radius: 18px;
    background: var(--preview-bg);
    cursor: pointer;
    font-size: var(--preview-font-size);
    border: 1px solid rgba(255, 255, 255, 0.4);
  }

  .palette-card__top {
    display: flex;
    justify-content: space-between;
    gap: 12px;
    margin-bottom: 16px;
  }

  .palette-card__name {
    font-size: 18px;
    font-weight: 700;
    color: #111827;
  }

  .palette-card__meta {
    color: #4b5563;
    font-size: 12px;
  }

  .palette-card__preview {
    display: flex;
    overflow: hidden;
    min-height: 170px;
    border-radius: 14px;
    background: rgba(255, 255, 255, 0.82);
    backdrop-filter: blur(8px);
  }

  .mock-nav {
    width: 92px;
    padding: 18px 12px;
    background: var(--preview-primary);
    color: #fff;
    font-weight: 600;
  }

  .mock-content {
    flex: 1;
    padding: 18px 16px;
  }

  .mock-title {
    color: var(--preview-primary);
    font-size: 1.1em;
    font-weight: 700;
  }

  .mock-desc {
    margin: 10px 0;
    color: #4b5563;
    line-height: 1.6;
  }

  .mock-actions {
    display: flex;
    gap: 8px;
  }

  .mock-actions span {
    padding: 6px 10px;
    border-radius: 999px;
    background: var(--preview-accent);
    color: #111827;
    font-size: 12px;
    font-weight: 600;
  }

  .color-chip {
    display: inline-flex;
    align-items: center;
    gap: 6px;
  }

  .color-dot {
    width: 12px;
    height: 12px;
    border-radius: 999px;
    border: 1px solid rgba(0, 0, 0, 0.08);
  }

  .section-title {
    font-size: 16px;
    font-weight: 600;
  }

  .preview-shell {
    display: grid;
    grid-template-columns: 140px 1fr;
    overflow: hidden;
    min-height: 360px;
    border-radius: 22px;
    border: 1px solid var(--el-border-color-lighter);
    background: var(--preview-bg);
    font-size: var(--preview-font-size);
  }

  .preview-shell--compact {
    min-height: 320px;
  }

  .preview-sidebar {
    display: flex;
    flex-direction: column;
    gap: 10px;
    padding: 18px 14px;
    background: rgba(17, 24, 39, 0.72);
    color: #fff;
  }

  .preview-logo {
    display: flex;
    overflow: hidden;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 64px;
    border-radius: 14px;
    background: rgba(255, 255, 255, 0.16);
  }

  .preview-logo img {
    width: 100%;
    height: 100%;
    object-fit: contain;
  }

  .preview-logo--placeholder {
    font-weight: 700;
    letter-spacing: 1px;
  }

  .preview-menu {
    padding: 10px 12px;
    border-radius: 12px;
    background: rgba(255, 255, 255, 0.08);
  }

  .preview-menu.is-active {
    background: var(--preview-primary);
  }

  .preview-main {
    padding: 22px;
    backdrop-filter: blur(2px);
  }

  .preview-banner {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    padding: 18px;
    border-radius: 18px;
    background: rgba(255, 255, 255, 0.86);
  }

  .preview-title {
    color: var(--preview-primary);
    font-size: 1.3em;
    font-weight: 700;
  }

  .preview-subtitle {
    margin-top: 6px;
    color: #6b7280;
    font-size: 12px;
  }

  .preview-panel {
    margin-top: 16px;
    padding: 18px;
    border-radius: 18px;
    background: rgba(255, 255, 255, 0.88);
    border-left: 6px solid var(--preview-primary);
  }

  .preview-panel--light {
    border-left-color: var(--preview-accent);
  }

  .preview-panel__title {
    font-size: 1.05em;
    font-weight: 700;
  }

  .preview-panel__text {
    margin-top: 8px;
    color: #4b5563;
    line-height: 1.7;
  }

  .terminal-summary {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 12px;
  }

  .terminal-summary__item {
    padding: 14px 16px;
    border-radius: 14px;
    background: rgba(255, 255, 255, 0.86);
    border: 1px solid var(--el-border-color-lighter);
  }

  .terminal-summary__item span {
    display: block;
    color: #6b7280;
    font-size: 12px;
  }

  .terminal-summary__item strong {
    display: block;
    margin-top: 8px;
    font-size: 18px;
  }

  .dialog-layout {
    display: grid;
    grid-template-columns: 1fr 320px;
    gap: 18px;
  }

  @media (max-width: 1400px) {
    .palette-grid {
      grid-template-columns: repeat(2, minmax(0, 1fr));
    }
  }

  @media (max-width: 900px) {
    .palette-grid,
    .dialog-layout,
    .preview-shell {
      grid-template-columns: 1fr;
    }

    .terminal-summary {
      grid-template-columns: 1fr;
    }
  }
}
</style>

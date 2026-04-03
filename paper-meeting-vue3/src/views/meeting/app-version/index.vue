<template>
  <div class="meeting-app-version-page">
    <ContentWrap>
      <div class="overview-grid">
        <div v-for="item in versionOverview" :key="item.label" class="overview-card">
          <div class="overview-label">{{ item.label }}</div>
          <div class="overview-value">{{ item.value }}</div>
          <div class="overview-tip">{{ item.tip }}</div>
        </div>
      </div>
    </ContentWrap>

    <ContentWrap>
      <el-form :model="queryParams" :inline="true" class="-mb-15px">
        <el-form-item label="客户端">
          <el-select v-model="queryParams.clientType" class="!w-180px" clearable>
            <el-option v-for="item in clientTypeOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="名称">
          <el-input v-model="queryParams.name" class="!w-220px" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.active" class="!w-160px" clearable>
            <el-option label="当前启用" :value="true" />
            <el-option label="未启用" :value="false" />
          </el-select>
        </el-form-item>
        <el-form-item label="更新策略">
          <el-select v-model="forceUpdateFilter" class="!w-160px" clearable>
            <el-option label="强制更新" :value="true" />
            <el-option label="普通更新" :value="false" />
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
      <el-table v-loading="loading" :data="pagedList" @row-click="selectRow">
        <el-table-column label="客户端" width="120">
          <template #default="scope">{{ getClientTypeLabel(scope.row.clientType) }}</template>
        </el-table-column>
        <el-table-column label="名称" prop="name" min-width="180" />
        <el-table-column label="版本" width="140">
          <template #default="scope">{{ scope.row.versionName }} / {{ scope.row.versionCode }}</template>
        </el-table-column>
        <el-table-column label="校验" min-width="180">
          <template #default="scope">
            <div class="check-list">
              <el-tag size="small" :type="scope.row.downloadUrl ? 'success' : 'danger'">
                {{ scope.row.downloadUrl ? '已配置下载地址' : '缺少下载地址' }}
              </el-tag>
              <el-tag size="small" :type="scope.row.md5 ? 'success' : 'warning'">
                {{ scope.row.md5 ? '已配置 MD5' : '未配置 MD5' }}
              </el-tag>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="更新策略" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.forceUpdate ? 'danger' : 'info'">
              {{ scope.row.forceUpdate ? '强制' : '普通' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="90">
          <template #default="scope">
            <el-tag :type="scope.row.active ? 'success' : 'info'">
              {{ scope.row.active ? '启用' : '未启用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="创建时间" min-width="170">
          <template #default="scope">{{ formatTime(scope.row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="scope">
            <el-button link type="primary" @click.stop="openForm('update', scope.row.id)">编辑</el-button>
            <el-button link type="success" v-if="!scope.row.active" @click.stop="handleActivate(scope.row.id)">启用</el-button>
            <el-button link type="primary" @click.stop="openLink(scope.row.downloadUrl)">下载地址</el-button>
            <el-button link type="danger" @click.stop="handleDelete(scope.row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <Pagination
        :total="filteredList.length"
        v-model:page="queryParams.pageNo"
        v-model:limit="queryParams.pageSize"
      />
    </ContentWrap>

    <ContentWrap>
      <div class="section-title mb-12px">当前版本详情</div>
      <template v-if="activeRecord">
        <div class="detail-panel">
          <div class="detail-main">
            <div class="detail-name">{{ activeRecord.name }}</div>
            <div class="detail-meta">
              <el-tag>{{ getClientTypeLabel(activeRecord.clientType) }}</el-tag>
              <el-tag :type="activeRecord.active ? 'success' : 'info'">
                {{ activeRecord.active ? '当前启用' : '未启用' }}
              </el-tag>
              <el-tag :type="activeRecord.forceUpdate ? 'danger' : 'warning'">
                {{ activeRecord.forceUpdate ? '强制更新' : '普通更新' }}
              </el-tag>
            </div>
            <div class="detail-desc">{{ activeRecord.remark || '暂无更新说明' }}</div>
            <div class="detail-actions mt-12px">
              <el-button type="primary" :loading="dispatchLoading" @click="dispatchVersion(false)">
                下发检查更新
              </el-button>
              <el-button :loading="dispatchLoading" @click="dispatchVersion(true)">
                重推待升级终端
              </el-button>
            </div>
          </div>
          <div class="detail-side">
            <div class="detail-item">
              <span>版本名</span>
              <strong>{{ activeRecord.versionName }}</strong>
            </div>
            <div class="detail-item">
              <span>版本号</span>
              <strong>{{ activeRecord.versionCode }}</strong>
            </div>
            <div class="detail-item">
              <span>MD5</span>
              <strong>{{ activeRecord.md5 || '未配置' }}</strong>
            </div>
            <div class="detail-item">
              <span>下载地址</span>
              <el-link type="primary" :href="activeRecord.downloadUrl" target="_blank">
                打开链接
              </el-link>
            </div>
            <div class="detail-item">
              <span>在线终端</span>
              <strong>{{ terminalSummary?.onlineCount || 0 }}</strong>
            </div>
            <div class="detail-item">
              <span>命中版本</span>
              <strong>{{ terminalSummary?.matchedCount || 0 }}</strong>
            </div>
            <div class="detail-item">
              <span>待升级</span>
              <strong>{{ terminalSummary?.pendingCount || 0 }}</strong>
            </div>
          </div>
        </div>
      </template>
      <el-empty v-else description="选择一条安装包记录后查看详情" />
    </ContentWrap>

    <ContentWrap>
      <div class="section-title mb-12px">终端回执</div>
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
            <div class="overview-tip">{{ scope.row.deviceName || '-' }}</div>
          </template>
        </el-table-column>
        <el-table-column label="在线状态" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.online ? 'success' : 'info'">
              {{ scope.row.online ? '在线' : '离线' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="命中状态" width="120">
          <template #default="scope">
            <el-tag :type="scope.row.matchSelected ? 'success' : 'warning'">
              {{ scope.row.matchSelected ? '已升级' : '待升级' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="会议/用户" min-width="220">
          <template #default="scope">
            <div>{{ scope.row.meetingName || '当前无会议' }}</div>
            <div class="overview-tip">{{ scope.row.userName || '未登录' }}</div>
          </template>
        </el-table-column>
        <el-table-column label="当前版本" min-width="180">
          <template #default="scope">
            {{ scope.row.appVersionName || '-' }} / {{ scope.row.appVersionCode || '-' }}
          </template>
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
              <div class="overview-tip">{{ scope.row.deviceName || '-' }}</div>
            </template>
          </el-table-column>
          <el-table-column label="在线" width="90">
            <template #default="scope">
              <el-tag :type="scope.row.online ? 'success' : 'info'">{{ scope.row.online ? '在线' : '离线' }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="当前版本" prop="currentValue" min-width="170" />
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

  <Dialog v-model="dialogVisible" :title="dialogTitle" width="780px">
    <el-form ref="formRef" :model="formData" :rules="formRules" label-width="100px" v-loading="formLoading">
      <el-form-item label="客户端" prop="clientType">
        <el-select v-model="formData.clientType" class="!w-full">
          <el-option v-for="item in clientTypeOptions" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="名称" prop="name">
        <el-input v-model="formData.name" />
      </el-form-item>
      <el-form-item label="版本名" prop="versionName">
        <el-input v-model="formData.versionName" />
      </el-form-item>
      <el-form-item label="版本号" prop="versionCode">
        <el-input-number v-model="formData.versionCode" :min="1" class="!w-full" />
      </el-form-item>
      <el-form-item label="安装包上传">
        <UploadFile
          v-model="uploadUrl"
          :limit="1"
          :file-size="500"
          :file-type="allowedUploadTypes"
          directory="meeting/app-version"
        />
      </el-form-item>
      <el-form-item label="下载地址" prop="downloadUrl">
        <el-input v-model="formData.downloadUrl" placeholder="上传后自动回填，或手动粘贴 CDN 地址" />
      </el-form-item>
      <el-form-item label="MD5">
        <el-input v-model="formData.md5" placeholder="建议填写，便于端侧校验文件完整性" />
      </el-form-item>
      <el-form-item label="强制更新">
        <el-switch v-model="formData.forceUpdate" />
      </el-form-item>
      <el-form-item label="创建即启用">
        <el-switch v-model="formData.active" />
      </el-form-item>
      <el-form-item label="更新说明">
        <el-input v-model="formData.remark" type="textarea" :rows="4" />
      </el-form-item>
      <el-alert
        title="建议启用前补齐下载地址和 MD5；强制更新版本请确保端侧已适配回滚方案。"
        type="warning"
        :closable="false"
        show-icon
      />
    </el-form>
    <template #footer>
      <el-button @click="dialogVisible = false">取消</el-button>
      <el-button type="primary" :loading="formLoading" @click="submitForm">确定</el-button>
    </template>
  </Dialog>
</template>

<script lang="ts" setup>
import { formatDate } from '@/utils/formatTime'
import * as AppVersionApi from '@/api/meeting/appVersion'
import * as TerminalStatusApi from '@/api/meeting/terminalStatus'

defineOptions({ name: 'MeetingAppVersion' })

const clientTypeOptions = [
  { label: '安卓客户端', value: 1 },
  { label: '呼叫服务端', value: 2 },
  { label: '大屏端', value: 3 },
  { label: '信息发布端', value: 4 }
]

const message = useMessage()
const loading = ref(false)
const list = ref<AppVersionApi.MeetingAppVersionVO[]>([])
const forceUpdateFilter = ref<undefined | boolean>()
const queryParams = reactive({ pageNo: 1, pageSize: 10, clientType: undefined as undefined | number, active: undefined as undefined | boolean, name: undefined as undefined | string })
const dialogVisible = ref(false)
const dialogTitle = ref('')
const formLoading = ref(false)
const formType = ref<'create' | 'update'>('create')
const formRef = ref()
const uploadUrl = ref('')
const activeRecord = ref<AppVersionApi.MeetingAppVersionVO>()
const terminalSummary = ref<TerminalStatusApi.MeetingTerminalStatusSummaryVO>()
const terminalList = ref<TerminalStatusApi.MeetingTerminalStatusVO[]>([])
const dispatchLoading = ref(false)
const dispatchResult = ref<TerminalStatusApi.MeetingTerminalDispatchRespVO>()
const formData = ref<AppVersionApi.MeetingAppVersionVO>({
  id: undefined,
  clientType: 1,
  name: '',
  versionName: '',
  versionCode: 1,
  downloadUrl: '',
  md5: '',
  forceUpdate: false,
  active: false,
  remark: ''
})

const formRules = reactive({
  clientType: [{ required: true, message: '客户端不能为空', trigger: 'change' }],
  name: [{ required: true, message: '名称不能为空', trigger: 'blur' }],
  versionName: [{ required: true, message: '版本名不能为空', trigger: 'blur' }],
  versionCode: [{ required: true, message: '版本号不能为空', trigger: 'blur' }],
  downloadUrl: [{ required: true, message: '下载地址不能为空', trigger: 'blur' }]
})

const allowedUploadTypes = ['apk', 'exe', 'msi', 'zip', 'rar', '7z', 'bin']

const formatTime = (value?: Date) => (value ? formatDate(value) : '-')

const filteredList = computed(() =>
  list.value.filter((item) => {
    if (typeof forceUpdateFilter.value === 'boolean' && item.forceUpdate !== forceUpdateFilter.value) {
      return false
    }
    return true
  })
)

const pagedList = computed(() => {
  const start = (queryParams.pageNo - 1) * queryParams.pageSize
  return filteredList.value.slice(start, start + queryParams.pageSize)
})

const versionOverview = computed(() => {
  const activeCount = list.value.filter((item) => item.active).length
  const forceCount = list.value.filter((item) => item.forceUpdate).length
  const md5ReadyCount = list.value.filter((item) => item.md5).length
  const latest = [...list.value].sort((a, b) => Number(b.versionCode || 0) - Number(a.versionCode || 0))[0]
  return [
    { label: '总版本数', value: list.value.length, tip: '管理端已维护的安装包记录' },
    { label: '当前启用', value: activeCount, tip: '各客户端当前正在使用的版本数量' },
    { label: '强制更新', value: forceCount, tip: '上线前建议再次确认端侧兼容性' },
    { label: '最新版本号', value: latest?.versionCode || '-', tip: latest ? `${latest.name} / ${latest.versionName}` : '暂无版本记录' },
    { label: 'MD5 已配置', value: md5ReadyCount, tip: '可用于端侧检查更新时做完整性校验' },
    { label: '在线终端', value: terminalSummary.value?.onlineCount || 0, tip: '最近 10 分钟内有心跳上报的终端数量' },
    { label: '命中当前版本', value: terminalSummary.value?.matchedCount || 0, tip: activeRecord.value ? `${activeRecord.value.name} 已接收的终端数量` : '选择版本后查看' }
  ]
})

const getClientTypeLabel = (value: number) =>
  clientTypeOptions.find((item) => item.value === value)?.label || '-'

const loadTerminalInsights = async () => {
  if (!activeRecord.value?.clientType) {
    terminalSummary.value = undefined
    terminalList.value = []
    return
  }
  const params = {
    clientType: activeRecord.value.clientType,
    appVersionId: activeRecord.value.id
  }
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
    const data = await AppVersionApi.getMeetingAppVersionPage({ ...queryParams, pageNo: 1, pageSize: 200 })
    list.value = data.list
    if (!activeRecord.value && list.value.length) {
      activeRecord.value = list.value[0]
      await loadTerminalInsights()
      return
    }
    if (activeRecord.value) {
      const matched = list.value.find((item) => item.id === activeRecord.value?.id)
      activeRecord.value = matched || list.value[0]
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
  queryParams.clientType = undefined
  queryParams.active = undefined
  queryParams.name = undefined
  forceUpdateFilter.value = undefined
  handleQuery()
}

const openForm = async (type: 'create' | 'update', id?: number) => {
  dialogVisible.value = true
  dialogTitle.value = type === 'create' ? '新增安装包' : '编辑安装包'
  formType.value = type
  uploadUrl.value = ''
  formData.value = { id: undefined, clientType: 1, name: '', versionName: '', versionCode: 1, downloadUrl: '', md5: '', forceUpdate: false, active: false, remark: '' }
  if (id) {
    formData.value = await AppVersionApi.getMeetingAppVersion(id)
    uploadUrl.value = formData.value.downloadUrl || ''
  }
}

watch(uploadUrl, (value) => {
  if (!value) return
  formData.value.downloadUrl = value
  if (!formData.value.name) {
    formData.value.name = decodeURIComponent(value.split('/').pop() || '')
  }
})

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
  } finally {
    formLoading.value = false
  }
}

const handleActivate = async (id: number) => {
  await AppVersionApi.activateMeetingAppVersion(id)
  message.success('已启用')
  await getList()
}

const handleDelete = async (id: number) => {
  try {
    await message.delConfirm()
    await AppVersionApi.deleteMeetingAppVersion(id)
    message.success('删除成功')
    await getList()
    if (activeRecord.value?.id === id) {
      activeRecord.value = list.value[0]
    }
  } catch {}
}

const selectRow = (row: AppVersionApi.MeetingAppVersionVO) => {
  activeRecord.value = row
  loadTerminalInsights()
}

const openLink = (url?: string) => {
  if (!url) return
  window.open(url, '_blank')
}

const dispatchVersion = async (onlyPending: boolean) => {
  if (!activeRecord.value?.id) {
    message.warning('请先选择安装包记录')
    return
  }
  dispatchLoading.value = true
  try {
    dispatchResult.value = await TerminalStatusApi.dispatchAppVersion({
      appVersionId: activeRecord.value.id,
      clientType: activeRecord.value.clientType,
      onlyPending
    })
    message.success(onlyPending ? '已执行重推' : '已下发检查更新指令')
    await loadTerminalInsights()
  } finally {
    dispatchLoading.value = false
  }
}

watch(
  () => activeRecord.value?.id,
  (value, oldValue) => {
    if (!value || value === oldValue) return
    loadTerminalInsights()
  }
)

onMounted(getList)
</script>

<style lang="scss" scoped>
.meeting-app-version-page {
  .overview-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 12px;
  }

  .overview-card {
    padding: 18px;
    border-radius: 16px;
    background: linear-gradient(135deg, #fff7ed 0%, #fffbeb 100%);
  }

  .overview-label {
    color: var(--el-text-color-secondary);
    font-size: 12px;
  }

  .overview-value {
    margin: 8px 0 6px;
    font-size: 24px;
    font-weight: 700;
  }

  .overview-tip {
    line-height: 1.5;
    color: var(--el-text-color-secondary);
    font-size: 12px;
  }

  .section-title {
    font-size: 16px;
    font-weight: 600;
  }

  .check-list {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
  }

  .detail-panel {
    display: grid;
    grid-template-columns: 1.4fr 1fr;
    gap: 16px;
    padding: 18px;
    border-radius: 18px;
    background: linear-gradient(135deg, #f8fafc 0%, #ffffff 100%);
  }

  .detail-name {
    font-size: 20px;
    font-weight: 700;
  }

  .detail-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin: 10px 0;
  }

  .detail-desc {
    color: var(--el-text-color-secondary);
    line-height: 1.8;
  }

  .detail-actions {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
  }

  .detail-side {
    display: flex;
    flex-direction: column;
    gap: 12px;
    padding: 16px;
    border-radius: 16px;
    background: rgba(255, 255, 255, 0.9);
    border: 1px solid var(--el-border-color-lighter);
  }

  .detail-item {
    display: flex;
    justify-content: space-between;
    gap: 12px;
  }

  @media (max-width: 1200px) {
    .detail-panel {
      grid-template-columns: 1fr;
    }
  }
}
</style>

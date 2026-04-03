<template>
  <div class="meeting-public-file-page">
    <el-row :gutter="16">
      <el-col :xs="24" :lg="7">
        <ContentWrap class="h-full">
          <div class="section-header">
            <div>
              <div class="section-title">目录导航</div>
              <div class="section-tip">按分类路径快速定位资料</div>
            </div>
            <el-button text type="primary" @click="selectedCategoryPath = ''">查看全部</el-button>
          </div>
          <el-input
            v-model="categoryKeyword"
            placeholder="搜索目录关键字"
            clearable
            class="mb-12px"
          >
            <template #prefix><Icon icon="ep:search" /></template>
          </el-input>
          <el-tree
            :data="categoryTree"
            node-key="path"
            highlight-current
            default-expand-all
            empty-text="暂无分类"
            :current-node-key="selectedCategoryPath || undefined"
            @node-click="handleCategorySelect"
          >
            <template #default="{ data }">
              <div class="tree-node">
                <span>{{ data.label }}</span>
                <el-tag size="small" type="info">{{ data.count }}</el-tag>
              </div>
            </template>
          </el-tree>
        </ContentWrap>
      </el-col>
      <el-col :xs="24" :lg="17">
        <ContentWrap>
          <div class="toolbar">
            <el-form :model="queryParams" :inline="true" class="-mb-15px">
              <el-form-item label="名称">
                <el-input v-model="queryParams.name" class="!w-220px" clearable />
              </el-form-item>
              <el-form-item label="状态">
                <el-select v-model="queryParams.enabled" class="!w-160px" clearable>
                  <el-option label="启用" :value="true" />
                  <el-option label="停用" :value="false" />
                </el-select>
              </el-form-item>
              <el-form-item label="类型">
                <el-select v-model="fileTypeFilter" class="!w-160px" clearable>
                  <el-option v-for="item in fileTypeOptions" :key="item" :label="item" :value="item" />
                </el-select>
              </el-form-item>
              <el-form-item>
                <el-button @click="handleQuery"><Icon icon="ep:search" />搜索</el-button>
                <el-button @click="resetQuery"><Icon icon="ep:refresh" />重置</el-button>
                <el-button type="primary" @click="openForm('create')">
                  <Icon icon="ep:plus" />新增资料
                </el-button>
                <el-button type="warning" plain @click="openArchiveDialog">
                  <Icon icon="ep:folder-remove" />按规则归档
                </el-button>
              </el-form-item>
            </el-form>
            <div class="stats-row">
              <div class="stat-card">
                <div class="stat-label">当前目录</div>
                <div class="stat-value">{{ selectedCategoryPath || '全部资料' }}</div>
              </div>
              <div class="stat-card">
                <div class="stat-label">可见资料</div>
                <div class="stat-value">{{ filteredList.length }}</div>
              </div>
              <div class="stat-card">
                <div class="stat-label">启用数量</div>
                <div class="stat-value">{{ enabledCount }}</div>
              </div>
              <div class="stat-card">
                <div class="stat-label">总浏览次数</div>
                <div class="stat-value">{{ totalViewCount }}</div>
              </div>
            </div>
          </div>
        </ContentWrap>

        <el-row :gutter="16">
          <el-col :xs="24" :xl="15">
            <ContentWrap>
              <el-table v-loading="loading" :data="pagedList" @row-click="selectRow">
                <el-table-column label="名称" min-width="220">
                  <template #default="scope">
                    <div class="file-name-cell">
                      <Icon :icon="getFileIcon(scope.row)" class="text-18px" />
                      <div>
                        <div class="font-600">{{ scope.row.name }}</div>
                        <div class="text-12px text-[var(--el-text-color-secondary)]">
                          {{ scope.row.category || '未分类' }}
                        </div>
                      </div>
                    </div>
                  </template>
                </el-table-column>
                <el-table-column label="类型" prop="fileType" width="100" />
                <el-table-column label="状态" width="90">
                  <template #default="scope">
                    <el-tag :type="scope.row.enabled ? 'success' : 'info'">
                      {{ scope.row.enabled ? '启用' : '停用' }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column label="排序" prop="sort" width="80" />
                <el-table-column label="创建时间" min-width="170">
                  <template #default="scope">
                    {{ formatTime(scope.row.createTime) }}
                  </template>
                </el-table-column>
                <el-table-column label="操作" width="210" fixed="right">
                  <template #default="scope">
                    <el-button link type="primary" @click.stop="previewFile(scope.row)">预览</el-button>
                    <el-button link type="primary" @click.stop="openForm('update', scope.row.id)">编辑</el-button>
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
          </el-col>
          <el-col :xs="24" :xl="9">
            <ContentWrap>
              <div class="section-header">
                <div>
                  <div class="section-title">资料预览</div>
                  <div class="section-tip">支持图片/PDF/下载跳转预览</div>
                </div>
                <el-button v-if="activeFile" text type="primary" @click="copyUrl(activeFile.url)">
                  复制地址
                </el-button>
              </div>
              <template v-if="activeFile">
                <div class="preview-meta">
                  <div class="preview-title">{{ activeFile.name }}</div>
                  <el-tag size="small">{{ activeFile.fileType || getFileExtension(activeFile.url) }}</el-tag>
                </div>
                <div class="preview-desc">{{ activeFile.remark || '暂无备注' }}</div>
                <div class="preview-metrics">
                  <el-tag size="small" type="info">浏览 {{ activeSummary?.viewCount || 0 }}</el-tag>
                  <el-tag size="small" type="success">打开 {{ activeSummary?.openCount || 0 }}</el-tag>
                  <el-tag size="small" type="warning">下载 {{ activeSummary?.downloadCount || 0 }}</el-tag>
                </div>
                <div class="preview-frame">
                  <img
                    v-if="isImageFile(activeFile)"
                    :src="activeFile.url"
                    alt="预览图"
                    class="preview-image"
                  />
                  <iframe
                    v-else-if="isPdfFile(activeFile)"
                    :src="activeFile.url"
                    class="preview-iframe"
                  />
                  <div v-else class="preview-placeholder">
                    <Icon icon="ep:document" class="text-42px" />
                    <span>当前类型暂不支持内嵌预览</span>
                  </div>
                </div>
                <div class="preview-actions">
                  <el-button type="primary" @click="openLink(activeFile.url)">打开资料</el-button>
                  <el-button @click="copyUrl(activeFile.url)">复制链接</el-button>
                  <el-button type="warning" plain @click="archiveSingle(activeFile)">归档资料</el-button>
                </div>
              </template>
              <el-empty v-else description="选择一条资料后查看详情" />
            </ContentWrap>
          </el-col>
        </el-row>
      </el-col>
    </el-row>
  </div>

  <Dialog v-model="dialogVisible" :title="dialogTitle" width="760px">
    <el-form ref="formRef" :model="formData" :rules="formRules" label-width="90px" v-loading="formLoading">
      <el-form-item label="分类路径" prop="category">
        <el-input v-model="formData.category" placeholder="例如：会议资料/董事会/2026" />
      </el-form-item>
      <el-form-item label="名称" prop="name">
        <el-input v-model="formData.name" placeholder="不填时可根据上传文件名补齐" />
      </el-form-item>
      <el-form-item label="上传文件">
        <UploadFile
          v-model="uploadUrl"
          :limit="1"
          :file-size="100"
          :file-type="uploadFileTypes"
          directory="meeting/public-file"
        />
      </el-form-item>
      <el-form-item label="地址" prop="url">
        <el-input v-model="formData.url" placeholder="支持上传后自动回填，也可直接粘贴外链" />
      </el-form-item>
      <el-form-item label="类型">
        <el-input v-model="formData.fileType" placeholder="如 pdf / docx / png" />
      </el-form-item>
      <el-form-item label="排序">
        <el-input-number v-model="formData.sort" :min="0" class="!w-full" />
      </el-form-item>
      <el-form-item label="启用">
        <el-switch v-model="formData.enabled" />
      </el-form-item>
      <el-form-item label="备注">
        <el-input v-model="formData.remark" type="textarea" :rows="3" />
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="dialogVisible = false">取消</el-button>
      <el-button type="primary" :loading="formLoading" @click="submitForm">确定</el-button>
    </template>
  </Dialog>

  <Dialog v-model="archiveDialogVisible" title="按规则归档" width="560px">
    <el-form :model="archiveForm" label-width="120px">
      <el-form-item label="归档前天数">
        <el-input-number v-model="archiveForm.beforeDays" :min="1" :max="3650" class="!w-full" />
      </el-form-item>
      <el-form-item label="筛选目录前缀">
        <el-input v-model="archiveForm.sourceCategoryPrefix" placeholder="可选：仅归档指定目录" />
      </el-form-item>
      <el-form-item label="归档根目录">
        <el-input v-model="archiveForm.targetCategoryPrefix" placeholder="默认：归档资料" />
      </el-form-item>
      <el-form-item label="归档后停用">
        <el-switch v-model="archiveForm.disableAfterArchive" />
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="archiveDialogVisible = false">取消</el-button>
      <el-button type="primary" :loading="archiveLoading" @click="submitArchive">执行归档</el-button>
    </template>
  </Dialog>
</template>

<script lang="ts" setup>
import { formatDate } from '@/utils/formatTime'
import * as PublicFileApi from '@/api/meeting/publicFile'

defineOptions({ name: 'MeetingPublicFile' })

interface CategoryTreeNode {
  label: string
  path: string
  count: number
  children?: CategoryTreeNode[]
}

const IMAGE_TYPES = ['png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp', 'svg']
const uploadFileTypes = [
  'pdf',
  'doc',
  'docx',
  'xls',
  'xlsx',
  'ppt',
  'pptx',
  'txt',
  'zip',
  'rar',
  '7z',
  'png',
  'jpg',
  'jpeg'
]

const message = useMessage()
const loading = ref(false)
const list = ref<PublicFileApi.MeetingPublicFileVO[]>([])
const queryParams = reactive({ pageNo: 1, pageSize: 10, category: undefined, name: undefined, enabled: undefined as undefined | boolean })
const fileTypeFilter = ref('')
const categoryKeyword = ref('')
const selectedCategoryPath = ref('')
const activeFile = ref<PublicFileApi.MeetingPublicFileVO>()
const dialogVisible = ref(false)
const dialogTitle = ref('')
const formLoading = ref(false)
const formType = ref<'create' | 'update'>('create')
const formRef = ref()
const uploadUrl = ref('')
const archiveDialogVisible = ref(false)
const archiveLoading = ref(false)
const archiveForm = ref<PublicFileApi.MeetingPublicFileArchiveReqVO>({
  beforeDays: 180,
  sourceCategoryPrefix: '',
  targetCategoryPrefix: '归档资料',
  disableAfterArchive: true
})
const formData = ref<PublicFileApi.MeetingPublicFileVO>({
  id: undefined,
  category: '',
  name: '',
  url: '',
  fileType: '',
  sort: 0,
  enabled: true,
  remark: ''
})

const formRules = reactive({
  category: [{ required: true, message: '分类路径不能为空', trigger: 'blur' }],
  name: [{ required: true, message: '名称不能为空', trigger: 'blur' }],
  url: [{ required: true, message: '地址不能为空', trigger: 'blur' }]
})

const formatTime = (value?: Date) => (value ? formatDate(value) : '-')

const fileTypeOptions = computed(() =>
  Array.from(
    new Set(
      list.value
        .map((item) => (item.fileType || getFileExtension(item.url)).toLowerCase())
        .filter(Boolean)
    )
  )
)

const enabledCount = computed(() => filteredList.value.filter((item) => item.enabled).length)
const accessSummaryMap = ref<Record<number, PublicFileApi.MeetingPublicFileAccessSummaryVO>>({})
const totalViewCount = computed(() =>
  Object.values(accessSummaryMap.value).reduce((sum, item) => sum + (item.viewCount || 0), 0)
)
const activeSummary = computed(() =>
  activeFile.value?.id ? accessSummaryMap.value[activeFile.value.id] : undefined
)

const filteredList = computed(() => {
  return list.value.filter((item) => {
    if (selectedCategoryPath.value && !item.category?.startsWith(selectedCategoryPath.value)) {
      return false
    }
    if (fileTypeFilter.value) {
      const currentType = (item.fileType || getFileExtension(item.url)).toLowerCase()
      if (currentType !== fileTypeFilter.value.toLowerCase()) return false
    }
    return true
  })
})

const pagedList = computed(() => {
  const start = (queryParams.pageNo - 1) * queryParams.pageSize
  return filteredList.value.slice(start, start + queryParams.pageSize)
})

const categoryTree = computed<CategoryTreeNode[]>(() => {
  const root: CategoryTreeNode[] = []
  const pathMap = new Map<string, CategoryTreeNode>()
  const categories = Array.from(new Set(list.value.map((item) => item.category).filter(Boolean)))
    .filter((item) => item!.includes(categoryKeyword.value.trim()) || !categoryKeyword.value.trim())
  categories.forEach((category) => {
    const segments = category!.split('/').filter(Boolean)
    let currentChildren = root
    let currentPath = ''
    segments.forEach((segment) => {
      currentPath = currentPath ? `${currentPath}/${segment}` : segment
      let node = pathMap.get(currentPath)
      if (!node) {
        node = { label: segment, path: currentPath, count: 0, children: [] }
        pathMap.set(currentPath, node)
        currentChildren.push(node)
      }
      node.count = list.value.filter((item) => item.category?.startsWith(currentPath)).length
      currentChildren = node.children || []
    })
  })
  return root
})

const getList = async () => {
  loading.value = true
  try {
    const data = await PublicFileApi.getMeetingPublicFilePage({ ...queryParams, pageNo: 1, pageSize: 200 })
    list.value = data.list
    if (data.list.length) {
      const summaryList = await PublicFileApi.getMeetingPublicFileAccessSummary(
        data.list.map((item) => item.id!).filter(Boolean)
      )
      accessSummaryMap.value = summaryList.reduce<Record<number, PublicFileApi.MeetingPublicFileAccessSummaryVO>>((acc, item) => {
        acc[item.fileId] = item
        return acc
      }, {})
    } else {
      accessSummaryMap.value = {}
    }
    if (!activeFile.value && list.value.length) {
      activeFile.value = list.value[0]
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
  queryParams.enabled = undefined
  fileTypeFilter.value = ''
  selectedCategoryPath.value = ''
  categoryKeyword.value = ''
  handleQuery()
}

const handleCategorySelect = (node: CategoryTreeNode) => {
  selectedCategoryPath.value = node.path
  queryParams.pageNo = 1
}

const selectRow = (row: PublicFileApi.MeetingPublicFileVO) => {
  activeFile.value = row
}

const previewFile = (row: PublicFileApi.MeetingPublicFileVO) => {
  activeFile.value = row
  reportAccess(row, 'view')
}

const openForm = async (type: 'create' | 'update', id?: number) => {
  dialogVisible.value = true
  dialogTitle.value = type === 'create' ? '新增资料' : '编辑资料'
  formType.value = type
  uploadUrl.value = ''
  formData.value = { id: undefined, category: selectedCategoryPath.value || '', name: '', url: '', fileType: '', sort: 0, enabled: true, remark: '' }
  if (id) {
    formData.value = await PublicFileApi.getMeetingPublicFile(id)
    uploadUrl.value = formData.value.url || ''
  }
}

watch(uploadUrl, (value) => {
  if (!value) return
  formData.value.url = value
  if (!formData.value.name) {
    formData.value.name = decodeURIComponent(value.split('/').pop() || '')
  }
  if (!formData.value.fileType) {
    formData.value.fileType = getFileExtension(value)
  }
})

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
  } finally {
    formLoading.value = false
  }
}

const handleDelete = async (id: number) => {
  try {
    await message.delConfirm()
    await PublicFileApi.deleteMeetingPublicFile(id)
    message.success('删除成功')
    await getList()
    if (activeFile.value?.id === id) {
      activeFile.value = list.value[0]
    }
  } catch {}
}

const getFileExtension = (url?: string) => {
  if (!url) return ''
  const fileName = url.split('?')[0]
  return (fileName.split('.').pop() || '').toLowerCase()
}

const isImageFile = (file: PublicFileApi.MeetingPublicFileVO) =>
  IMAGE_TYPES.includes((file.fileType || getFileExtension(file.url)).toLowerCase())

const isPdfFile = (file: PublicFileApi.MeetingPublicFileVO) =>
  (file.fileType || getFileExtension(file.url)).toLowerCase() === 'pdf'

const getFileIcon = (file: PublicFileApi.MeetingPublicFileVO) => {
  const ext = (file.fileType || getFileExtension(file.url)).toLowerCase()
  if (isImageFile(file)) return 'ep:picture'
  if (ext === 'pdf') return 'ep:document-checked'
  if (['doc', 'docx'].includes(ext)) return 'ep:document'
  if (['xls', 'xlsx'].includes(ext)) return 'ep:grid'
  if (['ppt', 'pptx'].includes(ext)) return 'ep:data-board'
  return 'ep:files'
}

const openLink = (url?: string) => {
  if (!url) return
  if (activeFile.value) reportAccess(activeFile.value, 'open')
  window.open(url, '_blank')
}

const copyUrl = async (url?: string) => {
  if (!url) return
  await navigator.clipboard.writeText(url)
  if (activeFile.value) reportAccess(activeFile.value, 'download')
  message.success('链接已复制')
}

const reportAccess = async (file: PublicFileApi.MeetingPublicFileVO, accessType: string) => {
  if (!file.id) return
  await PublicFileApi.reportMeetingPublicFileAccess({
    fileId: file.id,
    accessType,
    source: 'admin',
    operatorName: '管理端'
  })
  const current = accessSummaryMap.value[file.id] || {
    fileId: file.id,
    viewCount: 0,
    openCount: 0,
    downloadCount: 0
  }
  if (accessType === 'view') current.viewCount += 1
  else if (accessType === 'download') current.downloadCount += 1
  else current.openCount += 1
  accessSummaryMap.value[file.id] = { ...current }
}

const openArchiveDialog = () => {
  archiveForm.value = {
    beforeDays: 180,
    sourceCategoryPrefix: selectedCategoryPath.value || '',
    targetCategoryPrefix: '归档资料',
    disableAfterArchive: true
  }
  archiveDialogVisible.value = true
}

const submitArchive = async () => {
  archiveLoading.value = true
  try {
    const count = await PublicFileApi.archiveMeetingPublicFile(archiveForm.value)
    message.success(`归档完成，共处理 ${count || 0} 条资料`)
    archiveDialogVisible.value = false
    await getList()
  } finally {
    archiveLoading.value = false
  }
}

const archiveSingle = async (file: PublicFileApi.MeetingPublicFileVO) => {
  if (!file.id) return
  try {
    await message.confirm(`确认归档资料「${file.name}」吗？`)
    const count = await PublicFileApi.archiveMeetingPublicFile({
      fileIds: [file.id],
      targetCategoryPrefix: '归档资料',
      disableAfterArchive: true
    })
    message.success(`归档完成，共处理 ${count || 0} 条资料`)
    await getList()
  } catch {}
}

onMounted(getList)
</script>

<style lang="scss" scoped>
.meeting-public-file-page {
  .section-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 12px;
  }

  .section-title {
    font-size: 16px;
    font-weight: 600;
  }

  .section-tip {
    margin-top: 4px;
    color: var(--el-text-color-secondary);
    font-size: 12px;
  }

  .tree-node {
    display: flex;
    width: 100%;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
  }

  .toolbar {
    display: flex;
    flex-direction: column;
    gap: 14px;
  }

  .stats-row {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 12px;
  }

  .stat-card {
    padding: 14px 16px;
    border-radius: 14px;
    background: linear-gradient(135deg, #f8fafc 0%, #eef2ff 100%);
  }

  .stat-label {
    color: var(--el-text-color-secondary);
    font-size: 12px;
  }

  .stat-value {
    margin-top: 6px;
    font-size: 18px;
    font-weight: 700;
    word-break: break-all;
  }

  .file-name-cell {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .preview-meta {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .preview-title {
    font-size: 16px;
    font-weight: 700;
  }

  .preview-desc {
    margin: 10px 0 14px;
    color: var(--el-text-color-secondary);
    line-height: 1.6;
  }

  .preview-metrics {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 12px;
  }

  .preview-frame {
    overflow: hidden;
    min-height: 260px;
    border: 1px solid var(--el-border-color);
    border-radius: 16px;
    background: linear-gradient(180deg, #f8fafc 0%, #fff 100%);
  }

  .preview-image,
  .preview-iframe {
    width: 100%;
    height: 360px;
    border: 0;
    object-fit: contain;
    background: #fff;
  }

  .preview-placeholder {
    display: flex;
    min-height: 260px;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 12px;
    color: var(--el-text-color-secondary);
  }

  .preview-actions {
    display: flex;
    gap: 12px;
    margin-top: 14px;
  }

  @media (max-width: 1200px) {
    .stats-row {
      grid-template-columns: 1fr;
    }
  }
}
</style>

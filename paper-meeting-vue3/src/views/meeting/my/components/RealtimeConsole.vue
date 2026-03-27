<template>
  <div class="grid grid-cols-2 gap-16px">
    <el-card shadow="never">
      <template #header>
        <div class="flex items-center justify-between">
          <span>同屏审批</span>
          <div class="flex items-center gap-8px">
            <el-tag :type="isOpen ? 'success' : 'info'">{{ status }}</el-tag>
            <el-button link type="primary" @click="refreshState">刷新</el-button>
          </div>
        </div>
      </template>
      <el-empty v-if="!syncRequests.length" description="暂无同屏申请" />
      <div v-else class="flex flex-col gap-12px">
        <div
          v-for="item in syncRequests"
          :key="item.requestId"
          class="rounded-8px border border-solid border-[var(--el-border-color-lighter)] p-12px"
        >
          <div class="flex items-start justify-between gap-12px">
            <div>
              <div class="font-600">{{ item.requesterName }} · {{ item.requesterSeatName || '-' }}</div>
              <div class="mt-6px text-[var(--el-text-color-secondary)]">
                {{ item.documentTitle }}<span v-if="item.page"> · 第 {{ item.page }} 页</span>
              </div>
              <div v-if="item.approverName" class="mt-6px text-[var(--el-text-color-placeholder)]">
                处理人：{{ item.approverName }}
              </div>
            </div>
            <el-tag :type="syncTagType(item.status)">{{ syncStatusLabel(item.status) }}</el-tag>
          </div>
          <div class="mt-12px flex gap-8px">
            <template v-if="item.status === 'pending'">
              <el-button type="primary" @click="handleSync(item, 'approved')">同意</el-button>
              <el-button @click="handleSync(item, 'rejected')">拒绝</el-button>
            </template>
            <el-button v-if="item.status === 'approved'" type="danger" plain @click="handleSync(item, 'stopped')">
              停止同屏
            </el-button>
          </div>
        </div>
      </div>
    </el-card>

    <el-card shadow="never">
      <template #header>
        <div class="flex items-center justify-between">
          <span>服务处理</span>
          <el-tag :type="isOpen ? 'success' : 'info'">{{ status }}</el-tag>
        </div>
      </template>
      <el-empty v-if="!serviceRequests.length" description="暂无服务请求" />
      <div v-else class="flex flex-col gap-12px">
        <div
          v-for="item in serviceRequests"
          :key="item.requestId"
          class="rounded-8px border border-solid border-[var(--el-border-color-lighter)] p-12px"
        >
          <div class="flex items-start justify-between gap-12px">
            <div>
              <div class="font-600">{{ item.requesterName }} · {{ item.category }}</div>
              <div class="mt-6px text-[var(--el-text-color-secondary)]">
                {{ item.requesterSeatName || '-' }}｜{{ item.detail }}
              </div>
              <div v-if="item.handlerName" class="mt-6px text-[var(--el-text-color-placeholder)]">
                处理人：{{ item.handlerName }}
              </div>
            </div>
            <el-tag :type="serviceTagType(item.status)">{{ serviceStatusLabel(item.status) }}</el-tag>
          </div>
          <div class="mt-12px">
            <el-select
              :model-value="item.status"
              placeholder="更新状态"
              class="!w-180px"
              @change="(value) => handleService(item, value)"
            >
              <el-option label="待处理" value="pending" />
              <el-option label="处理中" value="processing" />
              <el-option label="已处理" value="completed" />
            </el-select>
          </div>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script lang="ts" setup>
import { useWebSocket } from '@vueuse/core'
import { getRefreshToken } from '@/utils/auth'
import * as MeetingApi from '@/api/meeting/info'

defineOptions({ name: 'MeetingRealtimeConsole' })

const props = defineProps<{
  meetingId: number
  visible: boolean
}>()

const message = useMessage()
const syncRequests = ref<MeetingApi.MeetingRealtimeSyncRequestVO[]>([])
const serviceRequests = ref<MeetingApi.MeetingRealtimeServiceRequestVO[]>([])
const server = computed(
  () =>
    (import.meta.env.VITE_BASE_URL + '/infra/ws').replace('http', 'ws') +
    '?token=' +
    getRefreshToken()
)

const { status, data, send, open, close } = useWebSocket(server, {
  immediate: false,
  autoReconnect: false,
  heartbeat: true
})

const isOpen = computed(() => status.value === 'OPEN')

const refreshState = async () => {
  if (!props.meetingId) {
    return
  }
  const state = await MeetingApi.getRealtimeState(props.meetingId)
  syncRequests.value = state.syncRequests || []
  serviceRequests.value = state.serviceRequests || []
}

const handleSync = async (
  item: MeetingApi.MeetingRealtimeSyncRequestVO,
  nextStatus: 'approved' | 'rejected' | 'stopped'
) => {
  if (!isOpen.value) {
    message.warning('实时连接未建立')
    return
  }
  sendEnvelope('meeting-sync-status-send', {
    meetingId: props.meetingId,
    requestId: item.requestId,
    requesterUserId: item.requesterUserId,
    requesterName: item.requesterName,
    requesterSeatName: item.requesterSeatName,
    documentId: item.documentId,
    documentTitle: item.documentTitle,
    page: item.page,
    status: nextStatus
  })
}

const handleService = async (
  item: MeetingApi.MeetingRealtimeServiceRequestVO,
  nextStatus: string | number | boolean
) => {
  if (typeof nextStatus !== 'string') {
    return
  }
  if (!isOpen.value) {
    message.warning('实时连接未建立')
    return
  }
  sendEnvelope('meeting-service-status-send', {
    meetingId: props.meetingId,
    requestId: item.requestId,
    requesterUserId: item.requesterUserId,
    requesterName: item.requesterName,
    requesterSeatName: item.requesterSeatName,
    category: item.category,
    detail: item.detail,
    status: nextStatus
  })
}

const sendEnvelope = (type: string, content: Record<string, unknown>) => {
  send(
    JSON.stringify({
      type,
      content: JSON.stringify(content)
    })
  )
}

const mergeSyncRequest = (item: MeetingApi.MeetingRealtimeSyncRequestVO) => {
  syncRequests.value = [item, ...syncRequests.value.filter((entry) => entry.requestId !== item.requestId)]
}

const mergeServiceRequest = (item: MeetingApi.MeetingRealtimeServiceRequestVO) => {
  serviceRequests.value = [
    item,
    ...serviceRequests.value.filter((entry) => entry.requestId !== item.requestId)
  ]
}

watch(
  data,
  (value) => {
    if (!value || value === 'pong') {
      return
    }
    try {
      const messageFrame = JSON.parse(value)
      const type = messageFrame.type
      const payload = JSON.parse(messageFrame.content || '{}')
      if (Number(payload.meetingId) !== props.meetingId) {
        return
      }
      switch (type) {
        case 'meeting-sync-request':
        case 'meeting-sync-approved':
        case 'meeting-sync-rejected':
          mergeSyncRequest(payload)
          break
        case 'meeting-sync-stopped':
          syncRequests.value = syncRequests.value.map((item) =>
            item.requestId === payload.requestId || payload.requestId === 'all'
              ? { ...item, status: 'pending' }
              : item
          )
          break
        case 'meeting-service-requested':
        case 'meeting-service-updated':
          mergeServiceRequest(payload)
          break
        default:
          break
      }
    } catch (error) {
      console.error(error)
    }
  },
  { flush: 'post' }
)

watch(
  () => [props.visible, props.meetingId] as const,
  async ([visible, meetingId]) => {
    if (!visible || !meetingId) {
      close()
      return
    }
    await refreshState()
    if (!isOpen.value) {
      open()
    }
  },
  { immediate: true }
)

onBeforeUnmount(() => {
  close()
})

const syncStatusLabel = (statusValue: string) => {
  switch (statusValue) {
    case 'approved':
      return '已同意'
    case 'rejected':
      return '已拒绝'
    default:
      return '待审批'
  }
}

const syncTagType = (statusValue: string) => {
  switch (statusValue) {
    case 'approved':
      return 'success'
    case 'rejected':
      return 'info'
    default:
      return 'warning'
  }
}

const serviceStatusLabel = (statusValue: string) => {
  switch (statusValue) {
    case 'processing':
      return '处理中'
    case 'completed':
      return '已处理'
    default:
      return '待处理'
  }
}

const serviceTagType = (statusValue: string) => {
  switch (statusValue) {
    case 'processing':
      return 'warning'
    case 'completed':
      return 'success'
    default:
      return 'info'
  }
}
</script>

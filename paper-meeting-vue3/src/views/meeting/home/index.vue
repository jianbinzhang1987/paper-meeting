<template>
  <div class="meeting-home">
    <el-row :gutter="16" class="mb-16px">
      <el-col :xs="12" :sm="12" :md="6" v-for="item in summaryCards" :key="item.label">
        <el-card shadow="hover" class="summary-card">
          <div class="summary-label">{{ item.label }}</div>
          <div class="summary-value">{{ item.value }}</div>
          <div class="summary-tip">{{ item.tip }}</div>
        </el-card>
      </el-col>
    </el-row>

    <ContentWrap>
      <div class="toolbar">
        <div>
          <div class="toolbar-title">快速告警</div>
          <div class="toolbar-subtitle">优先处理待审批、即将开始、会议室冲突与终端异常</div>
        </div>
      </div>
      <el-row :gutter="16">
        <el-col :xs="24" :md="6">
          <el-card shadow="never" class="alert-card alert-card--warning">
            <div class="alert-card__header">
              <span>待审批会议</span>
              <strong>{{ pendingApprovalCount }}</strong>
            </div>
            <div class="alert-card__desc">
              {{ pendingApprovalCount ? '存在待审批预约，建议尽快处理以免影响会前配置。' : '当前没有待审批预约。' }}
            </div>
            <el-button link type="primary" @click="goMeetingList(1)">查看审批列表</el-button>
          </el-card>
        </el-col>
        <el-col :xs="24" :md="6">
          <el-card shadow="never" class="alert-card alert-card--danger">
            <div class="alert-card__header">
              <span>两小时内开始</span>
              <strong>{{ imminentMeetings.length }}</strong>
            </div>
            <div class="alert-list" v-if="imminentMeetings.length">
              <div v-for="item in imminentMeetings.slice(0, 3)" :key="item.meetingId" class="alert-list__item">
                <span>{{ item.meetingName }}</span>
                <span>{{ formatDateTime(item.startTime) }}</span>
              </div>
            </div>
            <div v-else class="alert-card__desc">当前没有两小时内开始的会议。</div>
          </el-card>
        </el-col>
        <el-col :xs="24" :md="6">
          <el-card shadow="never" class="alert-card alert-card--info">
            <div class="alert-card__header">
              <span>会议室冲突</span>
              <strong>{{ roomConflicts.length }}</strong>
            </div>
            <div class="alert-list" v-if="roomConflicts.length">
              <div v-for="item in roomConflicts.slice(0, 3)" :key="item.id" class="alert-list__item">
                <span>{{ item.roomName }}</span>
                <span>{{ item.timeText }}</span>
              </div>
            </div>
            <div v-else class="alert-card__desc">今日会议室排期未发现时间重叠。</div>
          </el-card>
        </el-col>
        <el-col :xs="24" :md="6">
          <el-card shadow="never" class="alert-card alert-card--critical">
            <div class="alert-card__header">
              <span>终端异常</span>
              <strong>{{ terminalAlerts.length }}</strong>
            </div>
            <div class="alert-list" v-if="terminalAlerts.length">
              <div v-for="item in terminalAlerts.slice(0, 3)" :key="item.id" class="alert-list__item">
                <span>{{ item.terminal }}</span>
                <span>{{ item.reason }}</span>
              </div>
            </div>
            <div v-else class="alert-card__desc">当前未发现离线超时或连接异常终端。</div>
            <el-button link type="primary" @click="goUiConfig">查看终端回执</el-button>
          </el-card>
        </el-col>
      </el-row>
    </ContentWrap>

    <ContentWrap>
      <div class="toolbar">
        <div>
          <div class="toolbar-title">今日会议室占用</div>
          <div class="toolbar-subtitle">按会议室展示当前占用和下一场安排</div>
        </div>
        <div class="toolbar-actions">
          <el-button type="primary" @click="openForm('create', undefined, 1)">
            <Icon icon="ep:plus" /> 新建预约
          </el-button>
          <el-button @click="getOverview">
            <Icon icon="ep:refresh" /> 刷新
          </el-button>
        </div>
      </div>

      <el-row v-loading="loading" :gutter="16">
        <el-col
          v-for="room in overview.rooms"
          :key="room.roomId"
          :xs="24"
          :sm="12"
          :lg="8"
          class="mb-16px"
        >
          <el-card shadow="hover" class="room-card">
            <div class="room-header">
              <div>
                <div class="room-name">{{ room.roomName }}</div>
                <div class="room-meta">
                  <span>{{ room.location || '未设置位置' }}</span>
                  <span>容纳 {{ room.capacity || 0 }} 人</span>
                </div>
              </div>
              <el-tag :type="tagType(room)">
                {{ roomStatusText(room) }}
              </el-tag>
            </div>

            <div class="room-section">
              <div class="section-label">当前安排</div>
              <div v-if="room.currentMeetingId" class="section-main">
                <div class="meeting-name">{{ room.currentMeetingName }}</div>
                <div class="meeting-time">
                  {{ formatTimeRange(room.currentMeetingStartTime, room.currentMeetingEndTime) }}
                </div>
              </div>
              <el-empty v-else description="当前空闲" :image-size="56" />
            </div>

            <div class="room-section">
              <div class="section-label">下一场会议</div>
              <div v-if="room.nextMeetingId" class="section-main">
                <div class="meeting-name">{{ room.nextMeetingName }}</div>
                <div class="meeting-time">
                  {{ formatTimeRange(room.nextMeetingStartTime, room.nextMeetingEndTime) }}
                </div>
              </div>
              <div v-else class="section-placeholder">今日暂无后续安排</div>
            </div>

            <div class="room-footer">
              <div class="today-count">今日 {{ room.todayMeetingCount }} 场</div>
              <div class="footer-actions">
                <el-button link type="primary" @click="openRoomBooking(room)">预定此会议室</el-button>
                <el-button link @click="goRoomManage">会议室管理</el-button>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </ContentWrap>

    <ContentWrap>
      <div class="toolbar">
        <div>
          <div class="toolbar-title">今日会议列表</div>
          <div class="toolbar-subtitle">支持从首页直接查看会议详情</div>
        </div>
      </div>

      <el-table v-loading="loading" :data="overview.todayMeetings" empty-text="今日暂无会议">
        <el-table-column label="会议名称" prop="meetingName" min-width="220" />
        <el-table-column label="会议室" prop="roomName" min-width="140" />
        <el-table-column label="开始时间" min-width="160">
          <template #default="{ row }">
            {{ formatDateTime(row.startTime) }}
          </template>
        </el-table-column>
        <el-table-column label="结束时间" min-width="160">
          <template #default="{ row }">
            {{ formatDateTime(row.endTime) }}
          </template>
        </el-table-column>
        <el-table-column label="状态" width="110">
          <template #default="{ row }">
            <dict-tag :type="DICT_TYPE.MEETING_STATUS" :value="row.status" />
          </template>
        </el-table-column>
        <el-table-column label="保密级别" width="100">
          <template #default="{ row }">
            <el-tag :type="row.level === 1 ? 'danger' : 'success'">
              {{ row.level === 1 ? '保密' : '普通' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openMeetingDetail(row.meetingId)">查看详情</el-button>
            <el-button
              v-if="row.roomId"
              link
              type="success"
              @click="openRoomBookingByMeeting(row)"
            >
              再约此会议室
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </ContentWrap>

    <MeetingForm ref="formRef" @success="getOverview" />
    <MeetingDetail ref="detailRef" />
  </div>
</template>

<script lang="ts" setup>
import dayjs from 'dayjs'
import { useRouter } from 'vue-router'
import { DICT_TYPE } from '@/utils/dict'
import * as MeetingInfoApi from '@/api/meeting/info'
import * as MeetingRoomApi from '@/api/meeting/room'
import * as TerminalStatusApi from '@/api/meeting/terminalStatus'
import MeetingForm from '@/views/meeting/my/MeetingForm.vue'
import MeetingDetail from '@/views/meeting/my/components/MeetingDetail.vue'

defineOptions({ name: 'MeetingHome' })

const router = useRouter()
const loading = ref(false)
const pendingApprovalCount = ref(0)
const terminalAlerts = ref<Array<{ id: number; terminal: string; reason: string }>>([])
const overview = ref<MeetingRoomApi.MeetingRoomOverviewVO>({
  now: '',
  roomTotal: 0,
  availableRoomCount: 0,
  busyRoomCount: 0,
  todayMeetingCount: 0,
  upcomingMeetingCount: 0,
  rooms: [],
  todayMeetings: []
})

const formRef = ref()
const detailRef = ref()

const summaryCards = computed(() => [
  {
    label: '会议室总数',
    value: overview.value.roomTotal,
    tip: '当前租户已配置会议室'
  },
  {
    label: '当前空闲',
    value: overview.value.availableRoomCount,
    tip: '可直接发起预约'
  },
  {
    label: '当前占用',
    value: overview.value.busyRoomCount,
    tip: '正在进行中的会议室'
  },
  {
    label: '今日会议',
    value: overview.value.todayMeetingCount,
    tip: `待开始 ${overview.value.upcomingMeetingCount} 场`
  }
])

const imminentMeetings = computed(() => {
  const now = dayjs()
  const end = now.add(2, 'hour')
  return overview.value.todayMeetings.filter((item) => {
    const start = dayjs(item.startTime)
    return start.isAfter(now) && start.isBefore(end)
  })
})

const roomConflicts = computed(() => {
  const result: Array<{ id: string; roomName: string; timeText: string }> = []
  const roomMeetings = new Map<number, MeetingRoomApi.MeetingRoomTodayMeetingVO[]>()
  overview.value.todayMeetings.forEach((item) => {
    if (!item.roomId) return
    const current = roomMeetings.get(item.roomId) || []
    current.push(item)
    roomMeetings.set(item.roomId, current)
  })
  roomMeetings.forEach((items) => {
    const sorted = [...items].sort((a, b) => dayjs(a.startTime).valueOf() - dayjs(b.startTime).valueOf())
    for (let i = 1; i < sorted.length; i++) {
      const prev = sorted[i - 1]
      const current = sorted[i]
      if (dayjs(current.startTime).isBefore(dayjs(prev.endTime))) {
        result.push({
          id: `${prev.meetingId}-${current.meetingId}`,
          roomName: current.roomName || '未命名会议室',
          timeText: `${formatDateTime(prev.startTime)} 与 ${formatDateTime(current.startTime)}`
        })
      }
    }
  })
  return result
})

const getOverview = async () => {
  loading.value = true
  try {
    const [overviewResp, pendingResp, terminalResp] = await Promise.all([
      MeetingRoomApi.getMeetingRoomOverview(),
      MeetingInfoApi.getMeetingPage({ pageNo: 1, pageSize: 1, status: 1 }),
      TerminalStatusApi.getMeetingTerminalStatusList({ clientType: 1 }).catch(() => [])
    ])
    overview.value = overviewResp
    pendingApprovalCount.value = pendingResp.total
    terminalAlerts.value = (terminalResp || [])
      .filter((item) => isTerminalAbnormal(item))
      .slice(0, 20)
      .map((item) => ({
        id: item.id,
        terminal: `${item.roomName || '-'} / ${item.seatName || '-'}${item.deviceName ? ` (${item.deviceName})` : ''}`,
        reason: terminalAbnormalReason(item)
      }))
  } finally {
    loading.value = false
  }
}

const isTerminalAbnormal = (item: TerminalStatusApi.MeetingTerminalStatusVO) => {
  const status = (item.connectionStatus || '').toLowerCase()
  const abnormalStatus = status.includes('fail') || status.includes('error') || status.includes('offline') || status.includes('disconnect') || status.includes('abnormal')
  const heartbeatTimeout = !item.lastHeartbeatTime || dayjs(item.lastHeartbeatTime).isBefore(dayjs().subtract(30, 'minute'))
  return abnormalStatus || heartbeatTimeout
}

const terminalAbnormalReason = (item: TerminalStatusApi.MeetingTerminalStatusVO) => {
  const status = item.connectionStatus || ''
  const statusLower = status.toLowerCase()
  if (statusLower.includes('fail') || statusLower.includes('error') || statusLower.includes('offline') || statusLower.includes('disconnect') || statusLower.includes('abnormal')) {
    return `连接异常${status ? `(${status})` : ''}`
  }
  return item.lastHeartbeatTime ? `心跳超时(${formatDateTime(String(item.lastHeartbeatTime))})` : '未上报心跳'
}

const openForm = (type: string, id?: number, meetingType?: number, presetData?: Record<string, any>) => {
  formRef.value.open(type, id, meetingType, presetData)
}

const openRoomBooking = (room: MeetingRoomApi.MeetingRoomOverviewItemVO) => {
  const start = dayjs().add(1, 'hour').startOf('hour')
  openForm('create', undefined, 1, {
    roomId: room.roomId,
    name: `${room.roomName}预约会议`,
    startTime: start.valueOf(),
    endTime: start.add(1, 'hour').valueOf()
  })
}

const openRoomBookingByMeeting = (meeting: MeetingRoomApi.MeetingRoomTodayMeetingVO) => {
  const start = meeting.endTime ? dayjs(meeting.endTime).add(1, 'hour').startOf('hour') : dayjs().add(1, 'hour').startOf('hour')
  openForm('create', undefined, 1, {
    roomId: meeting.roomId,
    name: `${meeting.roomName || '会议室'}预约会议`,
    startTime: start.valueOf(),
    endTime: start.add(1, 'hour').valueOf()
  })
}

const openMeetingDetail = (id: number) => {
  detailRef.value.open(id)
}

const goRoomManage = () => {
  router.push('/meeting/room')
}

const goMeetingList = (status?: number) => {
  router.push(status !== undefined ? `/meeting/list?status=${status}` : '/meeting/list')
}

const goUiConfig = () => {
  router.push('/meeting/ui-config')
}

const roomStatusText = (room: MeetingRoomApi.MeetingRoomOverviewItemVO) => {
  if (room.roomStatus === 1) {
    return '已停用'
  }
  return room.busyNow ? '占用中' : '空闲'
}

const tagType = (room: MeetingRoomApi.MeetingRoomOverviewItemVO) => {
  if (room.roomStatus === 1) {
    return 'info'
  }
  return room.busyNow ? 'danger' : 'success'
}

const formatTimeRange = (start?: string, end?: string) => {
  if (!start || !end) {
    return '-'
  }
  return `${dayjs(start).format('MM-DD HH:mm')} - ${dayjs(end).format('HH:mm')}`
}

const formatDateTime = (value?: string) => {
  return value ? dayjs(value).format('MM-DD HH:mm') : '-'
}

onMounted(() => {
  getOverview()
})
</script>

<style scoped lang="scss">
.meeting-home {
  .summary-card {
    border: none;
    background:
      linear-gradient(135deg, rgba(16, 57, 145, 0.08), rgba(12, 152, 216, 0.12)),
      #fff;
  }

  .summary-label {
    color: var(--el-text-color-secondary);
    font-size: 13px;
  }

  .summary-value {
    margin-top: 10px;
    color: #163a8a;
    font-size: 30px;
    font-weight: 700;
    line-height: 1;
  }

  .summary-tip {
    margin-top: 10px;
    color: var(--el-text-color-secondary);
    font-size: 12px;
  }

  .toolbar {
    display: flex;
    gap: 12px;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 16px;
  }

  .toolbar-title {
    color: var(--el-text-color-primary);
    font-size: 18px;
    font-weight: 600;
  }

  .toolbar-subtitle {
    margin-top: 4px;
    color: var(--el-text-color-secondary);
    font-size: 13px;
  }

  .toolbar-actions {
    display: flex;
    gap: 12px;
  }

  .room-card {
    min-height: 286px;
    border: 1px solid rgba(22, 58, 138, 0.08);
  }

  .alert-card {
    min-height: 180px;
    border: none;
  }

  .alert-card--warning {
    background: linear-gradient(135deg, rgba(245, 158, 11, 0.12), rgba(254, 243, 199, 0.68));
  }

  .alert-card--danger {
    background: linear-gradient(135deg, rgba(220, 38, 38, 0.12), rgba(254, 226, 226, 0.78));
  }

  .alert-card--info {
    background: linear-gradient(135deg, rgba(14, 116, 144, 0.12), rgba(224, 242, 254, 0.78));
  }

  .alert-card--critical {
    background: linear-gradient(135deg, rgba(127, 29, 29, 0.14), rgba(254, 226, 226, 0.84));
  }

  .alert-card__header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-size: 15px;
    font-weight: 600;
  }

  .alert-card__header strong {
    font-size: 34px;
    line-height: 1;
  }

  .alert-card__desc {
    margin: 14px 0 10px;
    color: var(--el-text-color-secondary);
    line-height: 1.7;
    font-size: 13px;
  }

  .alert-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
    margin: 14px 0 4px;
  }

  .alert-list__item {
    display: flex;
    justify-content: space-between;
    gap: 8px;
    padding-bottom: 10px;
    border-bottom: 1px dashed rgba(15, 23, 42, 0.12);
    color: var(--el-text-color-primary);
    font-size: 13px;
  }

  .room-header,
  .room-footer {
    display: flex;
    gap: 12px;
    align-items: flex-start;
    justify-content: space-between;
  }

  .room-name {
    color: var(--el-text-color-primary);
    font-size: 18px;
    font-weight: 600;
  }

  .room-meta {
    display: flex;
    gap: 12px;
    margin-top: 6px;
    color: var(--el-text-color-secondary);
    font-size: 12px;
    flex-wrap: wrap;
  }

  .room-section {
    margin-top: 18px;
    padding: 14px;
    border-radius: 12px;
    background: #f7faff;
  }

  .section-label {
    color: #5b6b8a;
    font-size: 12px;
    margin-bottom: 8px;
  }

  .section-main {
    min-height: 56px;
  }

  .meeting-name {
    color: var(--el-text-color-primary);
    font-size: 15px;
    font-weight: 600;
  }

  .meeting-time,
  .section-placeholder,
  .today-count {
    color: var(--el-text-color-secondary);
    font-size: 12px;
    margin-top: 6px;
  }

  .footer-actions {
    display: flex;
    gap: 6px;
    align-items: center;
  }

  @media (max-width: 768px) {
    .toolbar,
    .room-header,
    .room-footer {
      flex-direction: column;
      align-items: stretch;
    }

    .toolbar-actions {
      justify-content: flex-start;
    }
  }
}
</style>

<template>
  <div class="meeting-control-page">
    <ContentWrap>
      <el-form :inline="true" :model="queryParams" class="-mb-15px">
        <el-form-item label="会议名称">
          <el-input
            v-model="queryParams.name"
            placeholder="请输入会议名称"
            clearable
            class="!w-240px"
            @keyup.enter="loadMeetings"
          />
        </el-form-item>
        <el-form-item>
          <el-button @click="loadMeetings"><Icon icon="ep:search" />搜索</el-button>
          <el-button @click="resetQuery"><Icon icon="ep:refresh" />重置</el-button>
        </el-form-item>
      </el-form>
    </ContentWrap>

    <el-row :gutter="16">
      <el-col :xs="24" :lg="8">
        <ContentWrap>
          <div class="panel-title">进行中会议</div>
          <el-empty v-if="!meetingLoading && meetings.length === 0" description="暂无进行中的会议" />
          <div v-loading="meetingLoading" class="meeting-list">
            <div
              v-for="meeting in meetings"
              class="meeting-card"
              :class="{ active: selectedMeetingId === meeting.id }"
              @click="selectMeeting(meeting.id!)"
            >
              <div class="meeting-name">{{ meeting.name }}</div>
              <div class="meeting-meta">
                <span>{{ formatDateTime(meeting.startTime) }}</span>
                <span>{{ formatDateTime(meeting.endTime) }}</span>
              </div>
            </div>
          </div>
        </ContentWrap>
      </el-col>
      <el-col :xs="24" :lg="16">
        <ContentWrap v-loading="dashboardLoading">
          <div class="panel-header">
            <div>
              <div class="panel-title">表决控制中心</div>
              <div class="panel-subtitle">
                {{ selectedMeeting?.name || '请选择左侧会议' }}
              </div>
            </div>
            <div class="panel-actions" v-if="selectedMeetingId">
              <el-button
                v-hasPermi="['meeting:vote:force-return']"
                type="warning"
                plain
                @click="handleForceReturn"
              >
                <Icon icon="ep:refresh-left" />强制返回同屏
              </el-button>
              <el-button type="primary" plain @click="openMeetingDetail">
                <Icon icon="ep:view" />会议详情
              </el-button>
            </div>
          </div>

          <el-empty
            v-if="selectedMeetingId && dashboard && dashboard.votes.length === 0"
            description="当前会议暂无表决"
          />
          <el-empty v-else-if="!selectedMeetingId" description="请选择进行中的会议" />

          <div v-else class="vote-list">
            <el-card v-for="vote in dashboard?.votes || []" :key="vote.id" shadow="hover" class="vote-card">
              <template #header>
                <div class="vote-header">
                  <div>
                    <div class="vote-title">{{ vote.title }}</div>
                    <div class="vote-meta">
                      <span>{{ vote.agendaTitle }}</span>
                      <span>{{ vote.secret ? '匿名表决' : '实名表决' }}</span>
                      <span>{{ vote.type === 1 ? '多选' : '单选' }}</span>
                    </div>
                  </div>
                  <el-tag :type="statusType(vote.status)">{{ statusLabel(vote.status) }}</el-tag>
                </div>
              </template>

              <el-row :gutter="12" class="summary-row">
                <el-col :xs="12" :md="6"><div class="summary-box"><span>应到</span><strong>{{ vote.attendeeCount }}</strong></div></el-col>
                <el-col :xs="12" :md="6"><div class="summary-box"><span>已投</span><strong>{{ vote.votedCount }}</strong></div></el-col>
                <el-col :xs="12" :md="6"><div class="summary-box"><span>未投</span><strong>{{ vote.pendingCount }}</strong></div></el-col>
                <el-col :xs="12" :md="6"><div class="summary-box"><span>参与率</span><strong>{{ formatRate(vote.turnoutRate) }}</strong></div></el-col>
              </el-row>

              <el-table :data="vote.options" size="small">
                <el-table-column label="选项" prop="content" min-width="180" />
                <el-table-column label="票数" prop="voteCount" width="100" />
                <el-table-column label="占比" width="120">
                  <template #default="{ row }">{{ formatRate(row.voteRate) }}</template>
                </el-table-column>
              </el-table>

              <div class="vote-actions">
                <el-button
                  v-if="vote.status !== 1"
                  type="primary"
                  link
                  @click="handleVoteAction(vote.id, 'start')"
                >
                  开始
                </el-button>
                <el-button
                  v-if="vote.status === 1"
                  type="warning"
                  link
                  @click="handleVoteAction(vote.id, 'finish')"
                >
                  结束
                </el-button>
                <el-button
                  v-hasPermi="['meeting:vote:publish']"
                  v-if="vote.status === 1 || vote.status === 2"
                  type="success"
                  link
                  @click="handleVoteAction(vote.id, 'publish')"
                >
                  发布结果
                </el-button>
                <el-button
                  v-hasPermi="['meeting:vote:export']"
                  type="success"
                  link
                  @click="handleExportVotes"
                >
                  导出结果
                </el-button>
              </div>
            </el-card>
          </div>
        </ContentWrap>
      </el-col>
    </el-row>

    <MeetingDetail ref="detailRef" />
  </div>
</template>

<script lang="ts" setup>
import dayjs from 'dayjs'
import * as MeetingApi from '@/api/meeting/info'
import * as VoteApi from '@/api/meeting/vote'
import MeetingDetail from '../my/components/MeetingDetail.vue'

defineOptions({ name: 'MeetingVoteControlCenter' })

const message = useMessage()
const meetingLoading = ref(false)
const dashboardLoading = ref(false)
const meetings = ref<MeetingApi.MeetingVO[]>([])
const selectedMeetingId = ref<number>()
const dashboard = ref<VoteApi.MeetingVoteDashboardVO>()
const queryParams = reactive({
  pageNo: 1,
  pageSize: 50,
  name: undefined,
  status: 3
})

const selectedMeeting = computed(() =>
  meetings.value.find((item) => item.id === selectedMeetingId.value)
)

const loadMeetings = async () => {
  meetingLoading.value = true
  try {
    const data = await MeetingApi.getMeetingPage(queryParams)
    meetings.value = data.list || []
    if (meetings.value.length === 0) {
      selectedMeetingId.value = undefined
      dashboard.value = undefined
      return
    }
    if (!selectedMeetingId.value || !meetings.value.some((item) => item.id === selectedMeetingId.value)) {
      selectedMeetingId.value = meetings.value[0].id
    }
    await loadDashboard()
  } finally {
    meetingLoading.value = false
  }
}

const loadDashboard = async () => {
  if (!selectedMeetingId.value) {
    dashboard.value = undefined
    return
  }
  dashboardLoading.value = true
  try {
    dashboard.value = await VoteApi.getMeetingVoteDashboard(selectedMeetingId.value)
  } finally {
    dashboardLoading.value = false
  }
}

const resetQuery = async () => {
  queryParams.name = undefined
  await loadMeetings()
}

const selectMeeting = async (meetingId: number) => {
  selectedMeetingId.value = meetingId
  await loadDashboard()
}

const handleVoteAction = async (voteId: number, action: 'start' | 'finish' | 'publish') => {
  const labels = {
    start: '开始',
    finish: '结束',
    publish: '发布结果'
  }
  try {
    await message.confirm(`确认${labels[action]}该表决吗？`)
    if (action === 'start') await VoteApi.startMeetingVote(voteId)
    if (action === 'finish') await VoteApi.finishMeetingVote(voteId)
    if (action === 'publish') await VoteApi.publishMeetingVote(voteId)
    message.success(`${labels[action]}成功`)
    await loadDashboard()
  } catch {}
}

const handleForceReturn = async () => {
  if (!selectedMeetingId.value) return
  try {
    await message.confirm('确认向当前会议终端下发强制返回同屏指令吗？')
    await VoteApi.forceReturnMeetingVote(selectedMeetingId.value)
    message.success('指令已下发')
  } catch {}
}

const handleExportVotes = async () => {
  if (!selectedMeetingId.value) return
  await VoteApi.exportMeetingVoteExcel(selectedMeetingId.value)
}

const detailRef = ref()
const openMeetingDetail = () => {
  if (!selectedMeetingId.value) return
  detailRef.value.open(selectedMeetingId.value)
}

const statusLabel = (status: number) => {
  if (status === 1) return '进行中'
  if (status === 2) return '已结束'
  return '待开始'
}

const statusType = (status: number) => {
  if (status === 1) return 'success'
  if (status === 2) return 'info'
  return 'warning'
}

const formatRate = (value?: number) => `${Number(value || 0).toFixed(2)}%`
const formatDateTime = (value?: Date) => (value ? dayjs(value).format('MM-DD HH:mm') : '-')

onMounted(() => {
  loadMeetings()
})
</script>

<style scoped lang="scss">
.meeting-control-page {
  .panel-header,
  .vote-header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 12px;
  }

  .panel-title,
  .vote-title {
    font-size: 18px;
    font-weight: 600;
    color: var(--el-text-color-primary);
  }

  .panel-subtitle,
  .vote-meta {
    margin-top: 4px;
    color: var(--el-text-color-secondary);
    font-size: 13px;
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
  }

  .meeting-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .meeting-card {
    border: 1px solid var(--el-border-color-light);
    border-radius: 12px;
    padding: 14px 16px;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .meeting-card.active {
    border-color: var(--el-color-primary);
    background: var(--el-color-primary-light-9);
  }

  .meeting-name {
    font-size: 15px;
    font-weight: 600;
  }

  .meeting-meta {
    margin-top: 6px;
    color: var(--el-text-color-secondary);
    font-size: 12px;
    display: flex;
    justify-content: space-between;
    gap: 8px;
  }

  .vote-list {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .summary-row {
    margin-bottom: 12px;
  }

  .summary-box {
    border-radius: 10px;
    background: #f6f8fc;
    padding: 12px;
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .summary-box span {
    color: var(--el-text-color-secondary);
    font-size: 12px;
  }

  .summary-box strong {
    font-size: 20px;
    line-height: 1;
  }

  .vote-actions {
    margin-top: 12px;
    display: flex;
    gap: 12px;
    justify-content: flex-end;
  }
}
</style>

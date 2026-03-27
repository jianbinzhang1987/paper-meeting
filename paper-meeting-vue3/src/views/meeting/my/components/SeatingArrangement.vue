<template>
  <div class="seating-container">
    <div class="attendee-list">
      <div class="panel-title">待排座人员</div>
      <div
        v-for="item in unassignedAttendees"
        :key="item.id"
        class="attendee-item"
        draggable="true"
        @dragstart="onDragStart($event, item)"
      >
        {{ getAttendeeName(item) }}
      </div>
    </div>
    <div class="seat-grid">
      <div class="toolbar">
        <div class="room-screen">{{ roomName }} / 讲台屏幕</div>
        <el-button type="primary" :loading="saving" @click="saveSeats">保存排座</el-button>
      </div>
      <div class="seats">
        <div
          v-for="seat in seats"
          :key="seat.id"
          class="seat-box"
          :class="{ occupied: !!seat.attendeeId }"
          @dragover.prevent
          @drop="onDrop($event, seat)"
        >
          <div v-if="seat.attendeeName" class="occupant-name">{{ seat.attendeeName }}</div>
          <div v-else class="seat-label">{{ seat.label }}</div>
          <el-icon v-if="seat.attendeeId" class="remove-btn" @click="removeAttendee(seat)"
            ><CircleClose
          /></el-icon>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { CircleClose } from '@element-plus/icons-vue'
import * as AttendeeApi from '@/api/meeting/attendee'
import * as MeetingApi from '@/api/meeting/info'
import * as MeetingRoomApi from '@/api/meeting/room'
import * as UserApi from '@/api/system/user'

const props = defineProps<{ meetingId: number }>()

const message = useMessage()
const attendees = ref<AttendeeApi.MeetingAttendeeVO[]>([])
const userMap = ref<Record<number, UserApi.UserVO>>({})
const seats = ref<any[]>([])
const roomName = ref('会议室')
const saving = ref(false)

const unassignedAttendees = computed(() => attendees.value.filter((item) => !item.seatId))

const onDragStart = (event: DragEvent, attendee: AttendeeApi.MeetingAttendeeVO) => {
  event.dataTransfer?.setData('attendeeId', attendee.id!.toString())
  event.dataTransfer?.setData('attendeeName', getAttendeeName(attendee))
}

const onDrop = (event: DragEvent, seat: any) => {
  const attendeeId = Number(event.dataTransfer?.getData('attendeeId'))
  if (!attendeeId) return
  clearSeatByAttendee(attendeeId)
  if (seat.attendeeId) {
    const oldAttendee = attendees.value.find((item) => item.id === seat.attendeeId)
    if (oldAttendee) {
      oldAttendee.seatId = undefined
    }
  }
  seat.attendeeId = attendeeId
  const attendee = attendees.value.find((item) => item.id === attendeeId)
  seat.attendeeName = attendee ? getAttendeeName(attendee) : null
  if (attendee) {
    attendee.seatId = seat.id
  }
}

const removeAttendee = (seat: any) => {
  const attendee = attendees.value.find((item) => item.id === seat.attendeeId)
  if (attendee) {
    attendee.seatId = undefined
  }
  seat.attendeeId = null
  seat.attendeeName = null
}

const clearSeatByAttendee = (attendeeId: number) => {
  const previousSeat = seats.value.find((item) => item.attendeeId === attendeeId)
  if (previousSeat) {
    previousSeat.attendeeId = null
    previousSeat.attendeeName = null
  }
}

const getAttendeeName = (attendee: AttendeeApi.MeetingAttendeeVO) => {
  return userMap.value[attendee.userId]?.nickname || `用户#${attendee.userId}`
}

const buildSeats = (roomConfig: string | undefined, capacity: number, attendeeList: AttendeeApi.MeetingAttendeeVO[]) => {
  const fallbackCount = Math.max(capacity || 0, attendeeList.length, 12)
  let seatDefs: Array<{ id: string; label: string }> = []
  if (roomConfig) {
    try {
      const parsed = JSON.parse(roomConfig)
      if (Array.isArray(parsed)) {
        seatDefs = parsed.map((item: any, index: number) => ({
          id: String(item.id || item.code || item.seatId || `S-${index + 1}`),
          label: item.label || item.name || `座位${index + 1}`
        }))
      } else if (Array.isArray(parsed?.seats)) {
        seatDefs = parsed.seats.map((item: any, index: number) => ({
          id: String(item.id || item.code || item.seatId || `S-${index + 1}`),
          label: item.label || item.name || `座位${index + 1}`
        }))
      }
    } catch {
      seatDefs = []
    }
  }
  if (!seatDefs.length) {
    seatDefs = Array.from({ length: fallbackCount }, (_, index) => ({
      id: `S-${index + 1}`,
      label: `座位${index + 1}`
    }))
  }
  return seatDefs.map((seat) => {
    const attendee = attendeeList.find((item) => item.seatId === seat.id)
    return {
      id: seat.id,
      label: seat.label,
      attendeeId: attendee?.id || null,
      attendeeName: attendee ? getAttendeeName(attendee) : null
    }
  })
}

const getData = async () => {
  if (!props.meetingId) return
  const [meeting, attendeeList, users] = await Promise.all([
    MeetingApi.getMeeting(props.meetingId),
    AttendeeApi.getAttendeeList(props.meetingId),
    UserApi.getSimpleUserList()
  ])
  attendees.value = attendeeList
  userMap.value = users.reduce<Record<number, UserApi.UserVO>>((acc, item) => {
    acc[item.id] = item
    return acc
  }, {})
  roomName.value = meeting.roomName || '会议室'
  if (meeting.roomId) {
    const room = await MeetingRoomApi.getMeetingRoom(meeting.roomId)
    seats.value = buildSeats(room.config, room.capacity || 0, attendeeList)
  } else {
    seats.value = buildSeats('', attendeeList.length, attendeeList)
  }
}

const saveSeats = async () => {
  saving.value = true
  try {
    await AttendeeApi.assignSeats(
      attendees.value.map((item) => ({
        attendeeId: item.id!,
        seatId: item.seatId
      }))
    )
    message.success('排座已保存')
    await getData()
  } finally {
    saving.value = false
  }
}

watch(
  () => props.meetingId,
  (val) => {
    if (val) getData()
  },
  { immediate: true }
)
</script>

<style scoped>
.seating-container {
  display: flex;
  gap: 20px;
}

.panel-title {
  font-weight: 600;
  margin-bottom: 12px;
}

.attendee-list {
  width: 220px;
  border: 1px solid #ddd;
  padding: 10px;
  background: #f9f9f9;
}

.attendee-item {
  padding: 8px;
  margin-bottom: 5px;
  background: #fff;
  border: 1px solid #eee;
  cursor: move;
}

.seat-grid {
  flex: 1;
  border: 1px solid #ddd;
  padding: 20px;
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  margin-bottom: 24px;
}

.room-screen {
  width: 60%;
  height: 40px;
  background: #eee;
  line-height: 40px;
  border-radius: 4px;
  text-align: center;
}

.seats {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 15px;
}

.seat-box {
  min-height: 80px;
  border: 2px dashed #ccc;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  background: #fff;
  padding: 8px;
}

.seat-box.occupied {
  border-style: solid;
  border-color: #409eff;
  background: #ecf5ff;
}

.occupant-name {
  font-weight: bold;
  text-align: center;
}

.seat-label {
  color: #999;
  font-size: 12px;
  text-align: center;
}

.remove-btn {
  position: absolute;
  top: -8px;
  right: -8px;
  color: #f56c6c;
  cursor: pointer;
  display: none;
}

.seat-box.occupied:hover .remove-btn {
  display: block;
}
</style>

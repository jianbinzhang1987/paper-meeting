import request from '@/config/axios'

export interface MeetingRoomVO {
  id?: number
  name: string
  location: string
  capacity: number
  status: number
  config: string
  createTime?: Date
}

export interface MeetingRoomOverviewItemVO {
  roomId: number
  roomName: string
  location?: string
  capacity?: number
  roomStatus: number
  busyNow: boolean
  todayMeetingCount: number
  currentMeetingId?: number
  currentMeetingName?: string
  currentMeetingStartTime?: string
  currentMeetingEndTime?: string
  nextMeetingId?: number
  nextMeetingName?: string
  nextMeetingStartTime?: string
  nextMeetingEndTime?: string
}

export interface MeetingRoomTodayMeetingVO {
  meetingId: number
  meetingName: string
  roomId?: number
  roomName?: string
  status: number
  level?: number
  startTime?: string
  endTime?: string
}

export interface MeetingRoomOverviewVO {
  now: string
  roomTotal: number
  availableRoomCount: number
  busyRoomCount: number
  todayMeetingCount: number
  upcomingMeetingCount: number
  rooms: MeetingRoomOverviewItemVO[]
  todayMeetings: MeetingRoomTodayMeetingVO[]
}

// 查询会议室分页
export const getMeetingRoomPage = (params: any) => {
  return request.get({ url: '/meeting/room/page', params })
}

// 查询会议室详情
export const getMeetingRoom = (id: number) => {
  return request.get({ url: '/meeting/room/get?id=' + id })
}

// 查询会议室概览
export const getMeetingRoomOverview = () => {
  return request.get<MeetingRoomOverviewVO>({ url: '/meeting/room/overview' })
}

// 新增会议室
export const createMeetingRoom = (data: MeetingRoomVO) => {
  return request.post({ url: '/meeting/room/create', data })
}

// 修改会议室
export const updateMeetingRoom = (data: MeetingRoomVO) => {
  return request.put({ url: '/meeting/room/update', data })
}

// 删除会议室
export const deleteMeetingRoom = (id: number) => {
  return request.delete({ url: '/meeting/room/delete?id=' + id })
}

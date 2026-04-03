import request from '@/config/axios'

export interface MeetingNotificationVO {
  id?: number
  meetingId: number
  content: string
  publishStatus?: number
  publishedTime?: Date
  createTime?: Date
}

export interface MeetingNotificationStatsVO extends MeetingNotificationVO {
  attendeeCount: number
  readCount: number
  unreadCount: number
}

export interface MeetingNotificationReadUserVO {
  userId: number
  nickname: string
  role: number
  seatId?: string
  readTime?: Date
}

export interface MeetingNotificationReadDetailVO {
  attendeeCount: number
  readCount: number
  unreadCount: number
  deliveredCount: number
  failedCount: number
  pendingCount: number
  readUsers: MeetingNotificationReadUserVO[]
  unreadUsers: MeetingNotificationReadUserVO[]
  terminalReceipts: MeetingNotificationTerminalReceiptVO[]
}

export interface MeetingNotificationTerminalReceiptVO {
  userId: number
  nickname: string
  role: number
  seatId?: string
  read?: boolean
  readTime?: Date
  roomName?: string
  seatName?: string
  deviceName?: string
  online?: boolean
  deliveryStatus: string
  deliveryStatusText: string
  failureReason?: string
  lastHeartbeatTime?: Date
}

export const getMeetingNotificationPage = (params: any) => {
  return request.get({ url: '/meeting/notification/page', params })
}

export const getMeetingNotificationStatsPage = (params: any) => {
  return request.get({ url: '/meeting/notification/page-with-stats', params })
}

export const getMeetingNotification = (id: number) => {
  return request.get({ url: '/meeting/notification/get', params: { id } })
}

export const getMeetingNotificationReadDetail = (id: number) => {
  return request.get({ url: '/meeting/notification/read-detail', params: { id } })
}

export const createMeetingNotification = (data: MeetingNotificationVO) => {
  return request.post({ url: '/meeting/notification/create', data })
}

export const updateMeetingNotification = (data: MeetingNotificationVO) => {
  return request.put({ url: '/meeting/notification/update', data })
}

export const deleteMeetingNotification = (id: number) => {
  return request.delete({ url: '/meeting/notification/delete', params: { id } })
}

export const publishMeetingNotification = (id: number) => {
  return request.post({ url: '/meeting/notification/publish', params: { id } })
}

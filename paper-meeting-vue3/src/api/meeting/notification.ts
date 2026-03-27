import request from '@/config/axios'

export interface MeetingNotificationVO {
  id?: number
  meetingId: number
  content: string
  publishStatus?: number
  publishedTime?: Date
  createTime?: Date
}

export const getMeetingNotificationPage = (params: any) => {
  return request.get({ url: '/meeting/notification/page', params })
}

export const getMeetingNotification = (id: number) => {
  return request.get({ url: '/meeting/notification/get', params: { id } })
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

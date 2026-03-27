import request from '@/config/axios'

export interface MeetingAttendeeVO {
  id?: number
  meetingId: number
  userId: number
  nickname?: string
  role: number
  status: number
  signInTime?: Date
  seatId?: string
}

// 添加参会人
export const createAttendee = (data: MeetingAttendeeVO) => {
  return request.post({ url: '/meeting/attendee/create', data })
}

// 移除参会人
export const deleteAttendee = (id: number) => {
  return request.delete({ url: '/meeting/attendee/delete?id=' + id })
}

// 获得参会人列表
export const getAttendeeList = (meetingId: number) => {
  return request.get({ url: '/meeting/attendee/list?meetingId=' + meetingId })
}

// 签到
export const signIn = (meetingId: number, userId: number) => {
  return request.post({ url: `/meeting/attendee/sign-in?meetingId=${meetingId}&userId=${userId}` })
}

export const assignSeats = (data: { attendeeId: number; seatId?: string }[]) => {
  return request.put({ url: '/meeting/attendee/assign-seats', data })
}

export const exportAttendeeExcel = (meetingId: number) => {
  return request.download({ url: '/meeting/attendee/export-excel', params: { meetingId } })
}

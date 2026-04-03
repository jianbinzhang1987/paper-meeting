import request from '@/config/axios'

export interface MeetingUserGroupVO {
  id?: number
  name: string
  description?: string
  userIds: number[]
  active?: boolean
  remark?: string
  createTime?: Date
}

export const getMeetingUserGroupPage = (params: any) => {
  return request.get({ url: '/meeting/user-group/page', params })
}

export const getMeetingUserGroup = (id: number) => {
  return request.get({ url: '/meeting/user-group/get', params: { id } })
}

export const getMeetingUserGroupSimpleList = () => {
  return request.get({ url: '/meeting/user-group/simple-list' })
}

export const createMeetingUserGroup = (data: MeetingUserGroupVO) => {
  return request.post({ url: '/meeting/user-group/create', data })
}

export const updateMeetingUserGroup = (data: MeetingUserGroupVO) => {
  return request.put({ url: '/meeting/user-group/update', data })
}

export const deleteMeetingUserGroup = (id: number) => {
  return request.delete({ url: '/meeting/user-group/delete', params: { id } })
}

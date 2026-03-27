import request from '@/config/axios'

export interface MeetingPublicFileVO {
  id?: number
  category: string
  name: string
  url: string
  fileType?: string
  sort?: number
  enabled?: boolean
  remark?: string
  createTime?: Date
}

export const getMeetingPublicFilePage = (params: any) => {
  return request.get({ url: '/meeting/public-file/page', params })
}

export const getMeetingPublicFile = (id: number) => {
  return request.get({ url: '/meeting/public-file/get', params: { id } })
}

export const createMeetingPublicFile = (data: MeetingPublicFileVO) => {
  return request.post({ url: '/meeting/public-file/create', data })
}

export const updateMeetingPublicFile = (data: MeetingPublicFileVO) => {
  return request.put({ url: '/meeting/public-file/update', data })
}

export const deleteMeetingPublicFile = (id: number) => {
  return request.delete({ url: '/meeting/public-file/delete', params: { id } })
}

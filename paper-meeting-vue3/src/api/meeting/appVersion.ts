import request from '@/config/axios'

export interface MeetingAppVersionVO {
  id?: number
  clientType: number
  name: string
  versionName: string
  versionCode: number
  downloadUrl: string
  md5?: string
  forceUpdate?: boolean
  active?: boolean
  remark?: string
  createTime?: Date
}

export const getMeetingAppVersionPage = (params: any) => {
  return request.get({ url: '/meeting/app-version/page', params })
}

export const getMeetingAppVersion = (id: number) => {
  return request.get({ url: '/meeting/app-version/get', params: { id } })
}

export const createMeetingAppVersion = (data: MeetingAppVersionVO) => {
  return request.post({ url: '/meeting/app-version/create', data })
}

export const updateMeetingAppVersion = (data: MeetingAppVersionVO) => {
  return request.put({ url: '/meeting/app-version/update', data })
}

export const deleteMeetingAppVersion = (id: number) => {
  return request.delete({ url: '/meeting/app-version/delete', params: { id } })
}

export const activateMeetingAppVersion = (id: number) => {
  return request.post({ url: '/meeting/app-version/activate', params: { id } })
}

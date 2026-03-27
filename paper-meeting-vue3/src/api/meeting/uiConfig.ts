import request from '@/config/axios'

export interface MeetingUiConfigVO {
  id?: number
  name: string
  fontSize?: number
  primaryColor: string
  accentColor?: string
  backgroundImageUrl?: string
  logoUrl?: string
  extraCss?: string
  active?: boolean
  remark?: string
  createTime?: Date
}

export const getMeetingUiConfigPage = (params: any) => {
  return request.get({ url: '/meeting/ui-config/page', params })
}

export const getMeetingUiConfig = (id: number) => {
  return request.get({ url: '/meeting/ui-config/get', params: { id } })
}

export const createMeetingUiConfig = (data: MeetingUiConfigVO) => {
  return request.post({ url: '/meeting/ui-config/create', data })
}

export const updateMeetingUiConfig = (data: MeetingUiConfigVO) => {
  return request.put({ url: '/meeting/ui-config/update', data })
}

export const deleteMeetingUiConfig = (id: number) => {
  return request.delete({ url: '/meeting/ui-config/delete', params: { id } })
}

export const activateMeetingUiConfig = (id: number) => {
  return request.post({ url: '/meeting/ui-config/activate', params: { id } })
}

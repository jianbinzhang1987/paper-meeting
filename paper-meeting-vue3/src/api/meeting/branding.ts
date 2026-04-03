import request from '@/config/axios'

export interface MeetingBrandingVO {
  id?: number
  siteName: string
  siteLogoUrl?: string
  sidebarTitle?: string
  sidebarSubtitle?: string
  active?: boolean
  remark?: string
  createTime?: Date
}

export const getMeetingBrandingPage = (params: any) => {
  return request.get({ url: '/meeting/branding/page', params })
}

export const getMeetingBranding = (id: number) => {
  return request.get({ url: '/meeting/branding/get', params: { id } })
}

export const getActiveMeetingBranding = () => {
  return request.get({ url: '/meeting/branding/active' })
}

export const createMeetingBranding = (data: MeetingBrandingVO) => {
  return request.post({ url: '/meeting/branding/create', data })
}

export const updateMeetingBranding = (data: MeetingBrandingVO) => {
  return request.put({ url: '/meeting/branding/update', data })
}

export const deleteMeetingBranding = (id: number) => {
  return request.delete({ url: '/meeting/branding/delete', params: { id } })
}

export const activateMeetingBranding = (id: number) => {
  return request.post({ url: '/meeting/branding/activate', params: { id } })
}

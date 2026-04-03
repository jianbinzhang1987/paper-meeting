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

export interface MeetingPublicFileAccessLogVO {
  fileId: number
  meetingId?: number
  userId?: number
  accessType: string
  source?: string
  operatorName?: string
}

export interface MeetingPublicFileAccessSummaryVO {
  fileId: number
  viewCount: number
  openCount: number
  downloadCount: number
  lastAccessTime?: Date
}

export interface MeetingPublicFileCategoryTreeNodeVO {
  label: string
  path: string
  count: number
  children?: MeetingPublicFileCategoryTreeNodeVO[]
}

export interface MeetingPublicFileArchiveReqVO {
  fileIds?: number[]
  beforeDays?: number
  sourceCategoryPrefix?: string
  targetCategoryPrefix?: string
  disableAfterArchive?: boolean
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

export const reportMeetingPublicFileAccess = (data: MeetingPublicFileAccessLogVO) => {
  return request.post({ url: '/meeting/public-file/access-log/report', data })
}

export const getMeetingPublicFileAccessSummary = (fileIds: number[]) => {
  return request.get({ url: '/meeting/public-file/access-log/summary', params: { fileIds: fileIds.join(',') } })
}

export const getMeetingPublicFileCategoryTree = () => {
  return request.get<MeetingPublicFileCategoryTreeNodeVO[]>({ url: '/meeting/public-file/category-tree' })
}

export const archiveMeetingPublicFile = (data: MeetingPublicFileArchiveReqVO) => {
  return request.post<number>({ url: '/meeting/public-file/archive', data })
}

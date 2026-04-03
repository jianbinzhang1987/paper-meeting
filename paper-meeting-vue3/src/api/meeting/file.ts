import request from '@/config/axios'

export interface MeetingFileVO {
  id?: number
  meetingId: number
  agendaId?: number
  name: string
  url: string
  type?: string
  size?: number
  createTime?: Date
}

export const getMeetingFileList = (meetingId: number) => {
  return request.get<MeetingFileVO[]>({ url: '/meeting/file/list', params: { meetingId } })
}

export const createMeetingFile = (data: MeetingFileVO) => {
  return request.post<number>({ url: '/meeting/file/create', data })
}

export const deleteMeetingFile = (id: number) => {
  return request.delete({ url: '/meeting/file/delete?id=' + id })
}

export const exportMeetingFileExcel = (meetingId: number) => {
  return request.download({ url: '/meeting/file/export-excel', params: { meetingId } })
}

export const exportMeetingDocumentMarkExcel = (meetingId: number) => {
  return request.download({ url: '/meeting/file/export-mark-excel', params: { meetingId } })
}

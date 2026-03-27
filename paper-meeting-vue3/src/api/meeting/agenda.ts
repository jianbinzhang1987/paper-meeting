import request from '@/config/axios'

export interface MeetingAgendaVO {
  id?: number
  meetingId: number
  parentId: number
  title: string
  content: string
  sort: number
  isVote: boolean
}

// 创建议题
export const createAgenda = (data: MeetingAgendaVO) => {
  return request.post({ url: '/meeting/agenda/create', data })
}

// 删除议题
export const deleteAgenda = (id: number) => {
  return request.delete({ url: '/meeting/agenda/delete?id=' + id })
}

// 获得议题列表
export const getAgendaList = (meetingId: number) => {
  return request.get({ url: '/meeting/agenda/list?meetingId=' + meetingId })
}

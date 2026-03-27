import request from '@/config/axios'

export interface MeetingVoteOptionVO {
  id?: number
  voteId?: number
  content: string
  sort?: number
}

export interface MeetingVoteVO {
  id?: number
  meetingId: number
  agendaId?: number
  title: string
  type: number
  isSecret?: boolean
  status?: number
  options: MeetingVoteOptionVO[]
  createTime?: Date
}

export const getMeetingVoteList = (meetingId: number) => {
  return request.get<MeetingVoteVO[]>({ url: '/meeting/vote/list', params: { meetingId } })
}

export const createMeetingVote = (data: MeetingVoteVO) => {
  return request.post<number>({ url: '/meeting/vote/create', data })
}

export const deleteMeetingVote = (id: number) => {
  return request.delete({ url: '/meeting/vote/delete?id=' + id })
}

export const exportMeetingVoteExcel = (meetingId: number) => {
  return request.download({ url: '/meeting/vote/export-excel', params: { meetingId } })
}

export const startMeetingVote = (id: number) => {
  return request.post({ url: '/meeting/vote/start', params: { id } })
}

export const finishMeetingVote = (id: number) => {
  return request.post({ url: '/meeting/vote/finish', params: { id } })
}

export const publishMeetingVote = (id: number) => {
  return request.post({ url: '/meeting/vote/publish', params: { id } })
}

export const forceReturnMeetingVote = (meetingId: number) => {
  return request.post({ url: '/meeting/vote/force-return', params: { meetingId } })
}

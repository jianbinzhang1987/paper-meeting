import request from '@/config/axios'

export interface MeetingVO {
  id?: number
  name: string
  description: string
  startTime: Date
  endTime: Date
  roomId: number
  status: number
  type: number
  level: number
  controlType?: number
  requireApproval?: boolean
  password?: string
  watermark: boolean
  summary?: string
  archiveTime?: Date
  createTime?: Date
}

export interface MeetingApprovalReqVO {
  id: number
  approved: boolean
  remark?: string
}

export interface MeetingApprovalCancelReqVO {
  id: number
  remark?: string
}

export interface MeetingApprovalLogVO {
  id: number
  meetingId: number
  action: number
  actionName: string
  operatorId?: number
  operatorName?: string
  remark?: string
  createTime: Date
}

export interface MeetingRealtimeSyncRequestVO {
  requestId: string
  requesterUserId?: number
  requesterName: string
  requesterSeatName?: string
  documentId?: string
  documentTitle: string
  page?: number
  status: string
  approverUserId?: number
  approverName?: string
}

export interface MeetingRealtimeServiceRequestVO {
  requestId: string
  requesterUserId?: number
  requesterName: string
  requesterSeatName?: string
  category: string
  detail: string
  status: string
  handlerUserId?: number
  handlerName?: string
}

export interface MeetingRealtimeStateVO {
  syncRequests: MeetingRealtimeSyncRequestVO[]
  serviceRequests: MeetingRealtimeServiceRequestVO[]
}

// 查询会议分页
export const getMeetingPage = (params: any) => {
  return request.get({ url: '/meeting/info/page', params })
}

// 查询会议详情
export const getMeeting = (id: number) => {
  return request.get({ url: '/meeting/info/get?id=' + id })
}

// 新增会议
export const createMeeting = (data: MeetingVO) => {
  return request.post({ url: '/meeting/info/create', data })
}

// 修改会议
export const updateMeeting = (data: MeetingVO) => {
  return request.put({ url: '/meeting/info/update', data })
}

// 删除会议
export const deleteMeeting = (id: number) => {
  return request.delete({ url: '/meeting/info/delete?id=' + id })
}

// 提交预约
export const submitBooking = (id: number) => {
  return request.post({ url: '/meeting/info/submit-booking?id=' + id })
}

// 审批预约
export const approveBooking = (data: MeetingApprovalReqVO) => {
  return request.post({ url: '/meeting/info/approve-booking', data })
}

// 撤销审核
export const cancelApproval = (data: MeetingApprovalCancelReqVO) => {
  return request.post({ url: '/meeting/info/cancel-approval', data })
}

// 审批历史
export const getApprovalLogList = (meetingId: number) => {
  return request.get<MeetingApprovalLogVO[]>({ url: '/meeting/info/approval-log', params: { meetingId } })
}

export const getRealtimeState = (meetingId: number) => {
  return request.get<MeetingRealtimeStateVO>({ url: '/meeting/info/realtime-state', params: { meetingId } })
}

// 开始会议
export const startMeeting = (id: number) => {
  return request.post({ url: '/meeting/info/start?id=' + id })
}

// 结束会议
export const stopMeeting = (id: number) => {
  return request.post({ url: '/meeting/info/stop?id=' + id })
}

// 归档会议
export const archiveMeeting = (id: number) => {
  return request.post({ url: '/meeting/info/archive?id=' + id })
}

// 撤回归档
export const rollbackArchiveMeeting = (id: number) => {
  return request.post({ url: '/meeting/info/rollback-archive?id=' + id })
}

// 复制会议
export const copyMeeting = (id: number) => {
  return request.post({ url: '/meeting/info/copy?id=' + id })
}

// 保存为模板
export const saveAsTemplate = (id: number) => {
  return request.post({ url: '/meeting/info/save-template?id=' + id })
}

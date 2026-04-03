import request from '@/config/axios'

export interface MeetingTerminalStatusQueryVO {
  clientType?: number
  appVersionId?: number
  uiConfigId?: number
}

export interface MeetingTerminalStatusVO {
  id: number
  clientType: number
  roomName?: string
  seatName?: string
  deviceName?: string
  meetingId?: number
  meetingName?: string
  userId?: number
  userName?: string
  themeMode?: string
  connectionStatus?: string
  appVersionId?: number
  appVersionName?: string
  appVersionCode?: number
  uiConfigId?: number
  uiConfigName?: string
  brandingId?: number
  brandingName?: string
  lastBootstrapTime?: Date
  lastHeartbeatTime?: Date
  online?: boolean
  matchSelected?: boolean
}

export interface MeetingTerminalStatusSummaryVO {
  totalCount: number
  onlineCount: number
  matchedCount: number
  pendingCount: number
  latestHeartbeatTime?: Date
}

export interface MeetingTerminalDispatchItemVO {
  terminalId: number
  clientType?: number
  roomName?: string
  seatName?: string
  deviceName?: string
  online?: boolean
  currentValue?: string
  matched?: boolean
  deliveryStatus: string
  deliveryStatusText: string
  failureReason?: string
  lastHeartbeatTime?: Date
}

export interface MeetingTerminalDispatchRespVO {
  targetType: string
  targetId: number
  totalCount: number
  dispatchedCount: number
  failedCount: number
  matchedCount: number
  items: MeetingTerminalDispatchItemVO[]
}

export const getMeetingTerminalStatusList = (params: MeetingTerminalStatusQueryVO) => {
  return request.get({ url: '/meeting/terminal-status/list', params })
}

export const getMeetingTerminalStatusSummary = (params: MeetingTerminalStatusQueryVO) => {
  return request.get({ url: '/meeting/terminal-status/summary', params })
}

export const dispatchAppVersion = (params: { appVersionId: number; clientType?: number; onlyPending?: boolean }) => {
  return request.post<MeetingTerminalDispatchRespVO>({ url: '/meeting/terminal-status/dispatch-app-version', params })
}

export const dispatchUiConfig = (params: { uiConfigId: number; clientType?: number; onlyPending?: boolean }) => {
  return request.post<MeetingTerminalDispatchRespVO>({ url: '/meeting/terminal-status/dispatch-ui-config', params })
}

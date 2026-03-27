<template>
  <Dialog v-model="dialogVisible" :title="dialogTitle">
    <el-form
      ref="formRef"
      :model="formData"
      :rules="formRules"
      label-width="100px"
      v-loading="formLoading"
    >
      <el-form-item label="会议名称" prop="name">
        <el-input v-model="formData.name" placeholder="请输入会议名称" />
      </el-form-item>
      <el-form-item label="会议简述" prop="description">
        <el-input v-model="formData.description" type="textarea" placeholder="请输入内容" />
      </el-form-item>
      <el-form-item label="开始时间" prop="startTime">
        <el-date-picker
          v-model="formData.startTime"
          type="datetime"
          value-format="x"
          placeholder="选择日期时间"
        />
      </el-form-item>
      <el-form-item label="结束时间" prop="endTime">
        <el-date-picker
          v-model="formData.endTime"
          type="datetime"
          value-format="x"
          placeholder="选择日期时间"
        />
      </el-form-item>
      <el-form-item label="会议室" prop="roomId">
        <el-select v-model="formData.roomId" placeholder="请选择会议室">
          <el-option
            v-for="item in roomList"
            :key="item.id"
            :label="item.name"
            :value="item.id"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="类型" prop="type">
        <el-radio-group v-model="formData.type">
          <el-radio :label="0">即时会议</el-radio>
          <el-radio :label="1">预约会议</el-radio>
          <el-radio :label="2">会议模板</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="保密级别" prop="level">
        <el-radio-group v-model="formData.level">
          <el-radio :label="0">普通</el-radio>
          <el-radio :label="1">保密</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="控制方式" prop="controlType">
        <el-radio-group v-model="formData.controlType">
          <el-radio :label="0">秘书控制</el-radio>
          <el-radio :label="1">自由控制</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="需要审批" prop="requireApproval">
        <el-switch v-model="formData.requireApproval" :disabled="formData.type !== 1" />
      </el-form-item>
      <el-form-item label="水印" prop="watermark">
        <el-switch v-model="formData.watermark" />
      </el-form-item>
      <el-form-item label="会议记录" prop="summary">
        <el-input v-model="formData.summary" type="textarea" placeholder="请输入会议记录" />
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="dialogVisible = false">取 消</el-button>
      <el-button :disabled="formLoading" type="primary" @click="submitForm">确 定</el-button>
    </template>
  </Dialog>
</template>
<script lang="ts" setup>
import * as MeetingApi from '@/api/meeting/info'
import * as MeetingRoomApi from '@/api/meeting/room'

const { t } = useI18n()
const message = useMessage()

const dialogVisible = ref(false)
const dialogTitle = ref('')
const formLoading = ref(false)
const formType = ref('')
const formData = ref({
  id: undefined,
  name: '',
  description: '',
  startTime: undefined,
  endTime: undefined,
  roomId: undefined,
  status: 0,
  type: 1,
  level: 0,
  controlType: 0,
  requireApproval: true,
  watermark: false,
  summary: ''
})
const formRules = reactive({
  name: [{ required: true, message: '会议名称不能为空', trigger: 'blur' }],
  startTime: [{ required: true, message: '开始时间不能为空', trigger: 'blur' }],
  endTime: [{ required: true, message: '结束时间不能为空', trigger: 'blur' }]
})
const formRef = ref()

const roomList = ref<any[]>([])
type MeetingFormPresetData = Partial<typeof formData.value>

/** 打开弹窗 */
const open = async (
  type: string,
  id?: number,
  meetingType?: number,
  presetData?: MeetingFormPresetData
) => {
  dialogVisible.value = true
  dialogTitle.value = type === 'create' ? '新建会议' : '修改会议'
  formType.value = type
  resetForm()
  if (meetingType !== undefined) {
    formData.value.type = meetingType
  }
  if (presetData) {
    formData.value = {
      ...formData.value,
      ...presetData
    }
  }
  // 加载会议室列表
  const rooms = await MeetingRoomApi.getMeetingRoomPage({ pageNo: 1, pageSize: 100 })
  roomList.value = rooms.list
  // 修改时，设置数据
  if (id) {
    formLoading.value = true
    try {
      formData.value = await MeetingApi.getMeeting(id)
    } finally {
      formLoading.value = false
    }
  }
}
defineExpose({ open })

/** 提交表单 */
const emit = defineEmits(['success'])
const submitForm = async () => {
  // 校验表单
  if (!formRef) return
  const valid = await formRef.value.validate()
  if (!valid) return
  // 提交请求
  formLoading.value = true
  try {
    const data = formData.value as any
    if (formType.value === 'create') {
      await MeetingApi.createMeeting(data)
      message.success(t('common.createSuccess'))
    } else {
      await MeetingApi.updateMeeting(data)
      message.success(t('common.updateSuccess'))
    }
    dialogVisible.value = false
    // 发送操作成功的事件
    emit('success')
  } finally {
    formLoading.value = false
  }
}

/** 重置表单 */
const resetForm = () => {
  formData.value = {
    id: undefined,
    name: '',
    description: '',
    startTime: undefined,
    endTime: undefined,
    roomId: undefined,
    status: 0,
    type: 1,
    level: 0,
    controlType: 0,
    requireApproval: true,
    watermark: false,
    summary: ''
  }
  formRef.value?.resetFields()
}
</script>

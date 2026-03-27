<template>
  <Dialog v-model="dialogVisible" :title="dialogTitle">
    <el-form
      ref="formRef"
      :model="formData"
      :rules="formRules"
      label-width="100px"
      v-loading="formLoading"
    >
      <el-form-item label="房间名称" prop="name">
        <el-input v-model="formData.name" placeholder="请输入房间名称" />
      </el-form-item>
      <el-form-item label="所在位置" prop="location">
        <el-input v-model="formData.location" placeholder="请输入位置" />
      </el-form-item>
      <el-form-item label="容纳人数" prop="capacity">
        <el-input-number v-model="formData.capacity" :min="1" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-radio-group v-model="formData.status">
          <el-radio :label="0">可用</el-radio>
          <el-radio :label="1">停用</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="座位配置" prop="config">
        <el-input v-model="formData.config" type="textarea" placeholder="请输入 JSON 配置" />
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="dialogVisible = false">取 消</el-button>
      <el-button :disabled="formLoading" type="primary" @click="submitForm">确 定</el-button>
    </template>
  </Dialog>
</template>
<script lang="ts" setup>
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
  location: '',
  capacity: 10,
  status: 0,
  config: ''
})
const formRules = reactive({
  name: [{ required: true, message: '房间名称不能为空', trigger: 'blur' }],
  status: [{ required: true, message: '状态不能为空', trigger: 'blur' }]
})
const formRef = ref()

/** 打开弹窗 */
const open = async (type: string, id?: number) => {
  dialogVisible.value = true
  dialogTitle.value = type === 'create' ? '新建会议室' : '修改会议室'
  formType.value = type
  resetForm()
  if (id) {
    formLoading.value = true
    try {
      formData.value = await MeetingRoomApi.getMeetingRoom(id)
    } finally {
      formLoading.value = false
    }
  }
}
defineExpose({ open })

/** 提交表单 */
const emit = defineEmits(['success'])
const submitForm = async () => {
  if (!formRef) return
  const valid = await formRef.value.validate()
  if (!valid) return
  formLoading.value = true
  try {
    const data = formData.value as any
    if (formType.value === 'create') {
      await MeetingRoomApi.createMeetingRoom(data)
      message.success(t('common.createSuccess'))
    } else {
      await MeetingRoomApi.updateMeetingRoom(data)
      message.success(t('common.updateSuccess'))
    }
    dialogVisible.value = false
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
    location: '',
    capacity: 10,
    status: 0,
    config: ''
  }
  formRef.value?.resetFields()
}
</script>

<template>
  <ContentWrap>
    <el-form :model="queryParams" :inline="true" class="-mb-15px">
      <el-form-item label="组名">
        <el-input v-model="queryParams.name" class="!w-220px" clearable />
      </el-form-item>
      <el-form-item label="状态">
        <el-select v-model="queryParams.active" class="!w-160px" clearable>
          <el-option label="启用" :value="true" />
          <el-option label="停用" :value="false" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button @click="handleQuery"><Icon icon="ep:search" />搜索</el-button>
        <el-button @click="resetQuery"><Icon icon="ep:refresh" />重置</el-button>
        <el-button type="primary" @click="openForm('create')"><Icon icon="ep:plus" />新增用户组</el-button>
      </el-form-item>
    </el-form>
  </ContentWrap>

  <ContentWrap>
    <el-table v-loading="loading" :data="list">
      <el-table-column label="组名" prop="name" min-width="160" />
      <el-table-column label="描述" prop="description" min-width="220" show-overflow-tooltip />
      <el-table-column label="成员数" width="100">
        <template #default="scope">{{ scope.row.userIds?.length || 0 }}</template>
      </el-table-column>
      <el-table-column label="成员" min-width="280">
        <template #default="scope">
          <el-space wrap>
            <el-tag v-for="userId in scope.row.userIds || []" :key="userId" size="small">
              {{ userMap[userId]?.nickname || `用户#${userId}` }}
            </el-tag>
          </el-space>
        </template>
      </el-table-column>
      <el-table-column label="状态" width="90">
        <template #default="scope">
          <el-tag :type="scope.row.active ? 'success' : 'info'">{{ scope.row.active ? '启用' : '停用' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="180">
        <template #default="scope">
          <el-button link type="primary" @click="openForm('update', scope.row.id)">编辑</el-button>
          <el-button link type="danger" @click="handleDelete(scope.row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <Pagination :total="total" v-model:page="queryParams.pageNo" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </ContentWrap>

  <Dialog v-model="dialogVisible" :title="dialogTitle" width="780px">
    <el-form ref="formRef" :model="formData" :rules="formRules" label-width="90px" v-loading="formLoading">
      <el-form-item label="组名" prop="name"><el-input v-model="formData.name" /></el-form-item>
      <el-form-item label="描述"><el-input v-model="formData.description" type="textarea" :rows="2" /></el-form-item>
      <el-form-item label="成员" prop="userIds">
        <el-select v-model="formData.userIds" multiple filterable class="!w-full" placeholder="请选择系统用户">
          <el-option v-for="item in userList" :key="item.id" :label="item.nickname" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="启用"><el-switch v-model="formData.active" /></el-form-item>
      <el-form-item label="备注"><el-input v-model="formData.remark" type="textarea" :rows="2" /></el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="dialogVisible = false">取消</el-button>
      <el-button type="primary" :loading="formLoading" @click="submitForm">确定</el-button>
    </template>
  </Dialog>
</template>

<script lang="ts" setup>
import * as UserApi from '@/api/system/user/index'
import * as UserGroupApi from '@/api/meeting/userGroup'

defineOptions({ name: 'MeetingUserGroup' })

const message = useMessage()
const loading = ref(false)
const total = ref(0)
const list = ref<UserGroupApi.MeetingUserGroupVO[]>([])
const userList = ref<UserApi.UserVO[]>([])
const queryParams = reactive({ pageNo: 1, pageSize: 10, name: undefined as undefined | string, active: undefined as undefined | boolean })
const dialogVisible = ref(false)
const dialogTitle = ref('')
const formLoading = ref(false)
const formType = ref<'create' | 'update'>('create')
const formRef = ref()
const formData = ref<UserGroupApi.MeetingUserGroupVO>({ id: undefined, name: '', description: '', userIds: [], active: true, remark: '' })

const formRules = reactive({
  name: [{ required: true, message: '组名不能为空', trigger: 'blur' }],
  userIds: [{ required: true, message: '成员不能为空', trigger: 'change' }]
})

const userMap = computed(() =>
  userList.value.reduce<Record<number, UserApi.UserVO>>((acc, item) => {
    acc[item.id] = item
    return acc
  }, {})
)

const getList = async () => {
  loading.value = true
  try {
    const [data, users] = await Promise.all([
      UserGroupApi.getMeetingUserGroupPage(queryParams),
      userList.value.length ? Promise.resolve(userList.value) : UserApi.getSimpleUserList()
    ])
    list.value = data.list
    total.value = data.total
    userList.value = users
  } finally {
    loading.value = false
  }
}

const handleQuery = () => {
  queryParams.pageNo = 1
  getList()
}

const resetQuery = () => {
  queryParams.name = undefined
  queryParams.active = undefined
  handleQuery()
}

const openForm = async (type: 'create' | 'update', id?: number) => {
  dialogVisible.value = true
  dialogTitle.value = type === 'create' ? '新增用户组' : '编辑用户组'
  formType.value = type
  formData.value = { id: undefined, name: '', description: '', userIds: [], active: true, remark: '' }
  if (!userList.value.length) userList.value = await UserApi.getSimpleUserList()
  if (id) formData.value = await UserGroupApi.getMeetingUserGroup(id)
}

const submitForm = async () => {
  const valid = await formRef.value?.validate()
  if (!valid) return
  formLoading.value = true
  try {
    if (formType.value === 'create') await UserGroupApi.createMeetingUserGroup(formData.value)
    else await UserGroupApi.updateMeetingUserGroup(formData.value)
    message.success('保存成功')
    dialogVisible.value = false
    await getList()
  } finally {
    formLoading.value = false
  }
}

const handleDelete = async (id: number) => {
  try {
    await message.delConfirm()
    await UserGroupApi.deleteMeetingUserGroup(id)
    message.success('删除成功')
    await getList()
  } catch {}
}

onMounted(getList)
</script>

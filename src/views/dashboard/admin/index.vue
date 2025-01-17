<!--
 ADempiere-Vue (Frontend) for ADempiere ERP & CRM Smart Business Solution
 Copyright (C) 2017-Present E.R.P. Consultores y Asociados, C.A. www.erpya.com
 Contributor(s): Edwin Betancourt EdwinBetanc0urt@outlook.com https://github.com/EdwinBetanc0urt
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program. If not, see <https:www.gnu.org/licenses/>.
-->

<template>
  <div class="dashboard-editor-container">
    <el-row :gutter="12">
      <el-col :span="24" style="padding-right:10px;margin-bottom:20px;">
        <el-card shadow="always">
          <el-col :span="16" style="padding-right:10px;margin-bottom:20px;">
            <h1 style="margin-bottom: 5px;">{{ $t('component.dashboard.header.welcome') }} {{ userInfo.name }}</h1>
            {{ userInfo.description }}
          </el-col>

          <el-col :span="8">
            <br>
            <b>{{ $t('component.dashboard.header.role') }}: </b> {{ currentRole.name }} <br>
            <b>{{ $t('component.dashboard.header.client') }}: </b> {{ currentRole.clientName }} <br>
            <b>{{ $t('component.dashboard.header.organization') }}: </b> {{ organization.name }} <br>
            <b>{{ $t('component.dashboard.header.warehouse') }}: </b> {{ warehouse.name }} <br>
            <br>
          </el-col>
        </el-card>
      </el-col>
    </el-row>

    <el-row v-if="!isEmptyValue(dashboardsList)" :gutter="8">
      <el-col v-if="!isEmptyValue(mainDashboard)" :span="24" style="padding-right:8px;margin-bottom:2px;">
        <dashboard-definition
          :metadata="mainDashboard"
          :title="mainDashboard.name"
        />
      </el-col>

      <template v-for="(dashboardAttributes, index) in listDashboard">
        <el-col
          :key="index"
          :xs="{ span: 24 }"
          :sm="{ span: 24 }"
          :md="{ span: 24 }"
          :lg="{ span: 12 }"
          :xl="{ span: 12 }"
          style="padding-right:8px;margin-bottom:2px;"
        >
          <dashboard-definition
            :metadata="dashboardAttributes"
            :title="dashboardAttributes.name"
            :main="true"
          />
        </el-col>
      </template>
    </el-row>
  </div>
</template>

<script>
import { defineComponent, computed, onMounted, watch } from '@vue/composition-api'

import store from '@/store'

// Components and Mixins
import DashboardDefinition from '@theme/components/ADempiere/Dashboard/index.vue'

// Utils and Helper Methods
import { isEmptyValue } from '@/utils/ADempiere/valueUtils.js'

export default defineComponent({
  name: 'DashboardAdmin',

  components: {
    DashboardDefinition
  },

  setup() {
    const dashboardsList = computed(() => {
      return store.getters.getStoredDashboardsList
    })

    const mainDashboard = computed(() => {
      return store.getters.getStoredMainDashboard
    })

    const listDashboard = computed(() => {
      const list = dashboardsList.value
      if (isEmptyValue(list)) {
        return []
      }
      if (!isEmptyValue(mainDashboard.value)) {
        return list.filter(dashboard => mainDashboard.value.id !== dashboard.id)
      }
      return list
    })

    const currentRole = computed(() => {
      return store.getters['user/getRole']
    })

    const roleUuid = computed(() => {
      return store.getters.getRoleUuid
    })

    const userInfo = computed(() => {
      return store.getters['user/userInfo']
    })

    const organization = computed(() => {
      return store.getters['user/getOrganization']
    })

    const warehouse = computed(() => {
      return store.getters['user/getWarehouse'] || {
        name: ''
      }
    })

    function loadDashboardsList() {
      store.dispatch('getDashboardListFromServer', {
        roleId: currentRole.value.id,
        roleUuid: currentRole.value.uuid
      })
    }

    watch(roleUuid, (newValue, oldValue) => {
      loadDashboardsList()
    })

    onMounted(() => {
      if (isEmptyValue(dashboardsList.value)) {
        loadDashboardsList()
      }
    })

    return {
      dashboardsList,
      mainDashboard,
      listDashboard,
      userInfo,
      currentRole,
      organization,
      warehouse
    }
  }
})
</script>

<style lang="scss" scoped>
.dashboard-editor-container {
  padding: 32px;
  background-color: rgb(240, 242, 245);
  position: relative;

  .github-corner {
    position: absolute;
    top: 0px;
    border: 0;
    right: 0;
  }

  .chart-wrapper {
    background: #fff;
    padding: 16px 16px 0;
    margin-bottom: 32px;
  }
}

@media (max-width:1024px) {
  .chart-wrapper {
    padding: 8px;
  }
}
</style>

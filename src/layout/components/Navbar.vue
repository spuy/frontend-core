<template>
  <div class="navbar">
    <hamburger id="hamburger-container" :is-active="sidebar.opened" class="hamburger-container" @toggleClick="toggleSideBar" />

    <el-button
      v-if="isMenuMobile && isMobile"
      type="text"
      icon="el-icon-close"
      style="padding-top: 13px; color: #000000;font-size: 121%;font-weight: 615!important;"
      @click="isMenuOption()"
    />
    <breadcrumb v-if="device!=='mobile'" id="breadcrumb-container" class="breadcrumb-container" :style="isMobile ? { width: '40%' } : { width: 'auto' } " />
    <div v-if="isMenuMobile && isMobile" style="display: inline-flex; float: right;">
      <el-button icon="el-icon-s-tools" type="text" />
      <search id="header-search" class="right-menu-item" style="padding-top: 10px;" />
      <header-notification style="padding-top: 6px;" />
    </div>
    <div class="right-menu">
      <template>
        <!-- <el-tooltip class="item" effect="dark" content="Reinicia Cache" placement="top-start">
          <el-button icon="el-icon-refresh-right" type="text" style="color: black;font-size: 18px;" @click="cacheReset()" />
        </el-tooltip> -->
        <el-tooltip v-if="!isMobile" :content="$t('route.guide')" placement="top-start">
          <el-button icon="el-icon-info" type="text" style="color: black;font-size: larger" @click.prevent.stop="guide" />
        </el-tooltip>
        <search id="header-search" class="right-menu-item" />
        <header-notification id="badge-navar" />
        <error-log v-if="!isMobile" class="errLog-container right-menu-item hover-effect" />

        <screenfull v-if="!isMobile" id="screenfull" class="right-menu-item hover-effect" />

        <!--
        <el-tooltip :content="$t('navbar.size')" effect="dark" placement="bottom">
          <size-select id="size-select" class="right-menu-item hover-effect" />
        </el-tooltip>
        -->

        <lang-select class="right-menu-item hover-effect" />

      </template>
      <el-button v-if="!isMobile" type="text" icon="el-icon-more" @click="isMenuOption()" />
      <el-popover
        placement="bottom"
        width="260"
        trigger="click"
      >
        <div style="padding: 10px;">
          <profile-preview
            :user="user"
            :avatar="avatar"
          />
          <el-button type="text" style="float: left;" @click="cacheReset()"> {{ $t('navbar.resetCache') }}</el-button>
          <el-button type="text" style="float: right;" @click="logout">{{ $t('navbar.logOut') }}</el-button>
        </div>
        <el-button slot="reference" type="text" style="padding-top: 0px;">
          <img v-if="!isEmptyValue(avatar)" :src="avatarResize" class="user-avatar">
          <svg-icon v-else icon-class="AD" style="width: 2em !important;height: 2em !important;font-size: 27px;" />
        </el-button>
      </el-popover>
    </div>
  </div>
</template>

<script>
import ProfilePreview from '@/layout/components/ProfilePreview'
import { mapGetters } from 'vuex'
import Breadcrumb from '@theme/components/Breadcrumb'
import Hamburger from '@theme/components/Hamburger'
import ErrorLog from '@theme/components/ErrorLog'
import Screenfull from '@theme/components/Screenfull'
// import SizeSelect from '@theme/components/SizeSelect'
import LangSelect from '@theme/components/LangSelect'
import Search from '@theme/components/HeaderSearch'
import HeaderNotification from '@theme/components/ADempiere/HeaderNotification'
import { getImagePath } from '@/utils/ADempiere/resource.js'
import Driver from 'driver.js' // import driver.js
import 'driver.js/dist/driver.min.css' // import driver.js css

export default {
  components: {
    Breadcrumb,
    HeaderNotification,
    Hamburger,
    ErrorLog,
    Screenfull,
    // SizeSelect,
    LangSelect,
    ProfilePreview,
    Search
  },
  data() {
    return {
      user: {},
      isMenuMobile: false,
      driver: null
    }
  },
  computed: {
    isMobile() {
      return this.$store.state.app.device === 'mobile'
    },
    showGuide() {
      const typeViews = this.$route.meta.type
      if (!this.isEmptyValue(typeViews) && typeViews !== 'window') {
        return true
      }
      return false
    },
    ...mapGetters([
      'sidebar',
      'avatar',
      'device'
    ]),
    avatarResize() {
      const { uri } = getImagePath({
        file: this.avatar,
        width: 40,
        height: 40
      })

      return uri
    },
    fieldPanel() {
      if (this.$route.meta.type === 'browser') return this.$store.getters.getStoredBrowser(this.$route.meta.uuid).fieldsList.filter(field => field.isMandatory || field.isShowedFromUser)
      if (this.$route.meta.type === 'report') return this.$store.getters.getStoredReport(this.$route.meta.uuid).fieldsList.filter(field => field.isMandatory || field.isShowedFromUser)
      if (this.$route.meta.type === 'window') {
        const { currentTab } = this.$store.getters.getContainerInfo
        if (!this.isEmptyValue(currentTab)) {
          const {
            parentUuid,
            containerUuid
          } = currentTab
          return this.$store.getters.getStoredFieldsFromTab(parentUuid, containerUuid).filter(field => field.isMandatory || field.isShowedFromUser)
        }
        return []
      }
      return this.$store.getters.getStoredFieldsFromProcess(this.$route.meta.uuid).filter(field => field.isMandatory || field.isShowedFromUser)
    },
    fieldTab() {
      const tab = this.$store.getters.getStoredWindow(this.$route.meta.uuid)
      if (!this.isEmptyValue(tab)) {
        const tabChildIndex = parseInt(this.$route.query.tabChild)
        const tabIndex = parseInt(this.$route.query.tab)
        const fieldsListParentTab = tab.tabsListParent[tabIndex].fieldsList.filter(field => field.isMandatory && field.isShowedFromUser)
        const fieldsListChildTab = tab.tabsListChild[tabChildIndex].fieldsList.filter(field => field.isMandatory && field.isShowedFromUser)
        return fieldsListParentTab.concat(fieldsListChildTab)
      }
      return []
    },
    getForm() {
      return this.$store.getters.getForm(this.$route.meta.uuid)
    },
    formSteps() {
      let form
      switch (this.getForm.fileName) {
        case 'WFActivity':
          form = require('@theme/components/ADempiere/Form/WorkflowActivity/Guide/steps')
          break
        case 'VPOS':
          form = require('@theme/components/ADempiere/Form/VPOS/Guide/steps')
          break
        default:
          form = {
            default: []
          }
          break
      }
      return form.default
    },
    defaultViews() {
      return {
        type: this.$route.meta.type,
        uuid: this.$route.meta.uuid
      }
    }
  },
  mounted() {
    this.driver = new Driver()
  },
  methods: {
    guide() {
      this.driver = new Driver()
      const value = this.formatGuide(this.$route.meta.type)
      this.driver.defineSteps(value)
      this.driver.start()
    },
    isMenuOption() {
      this.isMenuMobile = !this.isMenuMobile
    },
    cacheReset() {
      this.$store.dispatch('runCache')
    },
    toggleSideBar() {
      this.$store.dispatch('app/toggleSideBar')
    },
    async logout() {
      await this.$store.dispatch('user/logout')
      this.$router.push({
        path: '/login'
      }, () => {})
      this.$store.commit('setPointOfSalesList', [])
      this.$store.commit('setListOrderLine', [])
      this.$store.commit('setOrder', {
        documentType: {},
        documentStatus: {
          value: ''
        },
        totalLines: 0,
        grandTotal: 0,
        salesRepresentative: {},
        businessPartner: {
          value: '',
          uuid: ''
        }
      })
    },
    handleClick() {
      this.$router.push({
        name: 'Profile'
      }, () => {})
    },
    formatGuide(type) {
      let field
      switch (type) {
        case 'report':
          field = this.fieldPanel.map(steps => {
            return {
              element: '#' + steps.columnName,
              popover: {
                title: steps.name,
                description: steps.description,
                position: 'top'
              }
            }
          })
          break
        case 'process':
          field = this.fieldPanel.map(steps => {
            return {
              element: '#' + steps.columnName,
              popover: {
                title: steps.name,
                description: steps.description,
                position: 'top'
              }
            }
          })
          break
        case 'browser':
          field = this.fieldPanel.map(steps => {
            return {
              element: '#' + steps.columnName,
              popover: {
                title: steps.name,
                description: steps.description,
                position: 'top'
              }
            }
          })
          break
        case 'window':
          field = this.fieldPanel.map(steps => {
            return {
              element: '#' + steps.columnName,
              popover: {
                title: steps.name,
                description: steps.description,
                position: 'top'
              }
            }
          })
          break
        case 'form':
          field = this.formSteps
          break
      }
      return field
    }
  }
}
</script>

<style lang="scss" scoped>
.el-dropdown {
  display: inline-block;
  position: relative;
  color: #606266;
  font-size: 14px;
  width: 50px;
}
.navbar {
  height: 50px;
  overflow: hidden;
  position: relative;
  background: #fff;
  box-shadow: 0 1px 4px rgba(0,21,41,.08);

  .hamburger-container {
    line-height: 46px;
    height: 100%;
    float: left;
    cursor: pointer;
    transition: background .3s;
    -webkit-tap-highlight-color:transparent;

    &:hover {
      background: rgba(0, 0, 0, .025)
    }
  }

  .breadcrumb-container {
    float: left;
  }

  .errLog-container {
    display: inline-block;
    vertical-align: top;
  }

  .right-menu {
    float: right;
    display: flex;
    height: 100%;
    line-height: 50px;

    &:focus {
      outline: none;
    }

    .right-menu-item {
      display: inline-block;
      padding: 0 8px;
      height: 100%;
      font-size: 18px;
      color: #5a5e66;
      vertical-align: text-bottom;

      &.hover-effect {
        cursor: pointer;
        transition: background .3s;

        &:hover {
          background: rgba(0, 0, 0, .025)
        }
      }
    }

    .avatar-container {
      margin-right: 30px;

      .avatar-wrapper {
        margin-top: 5px;
        position: relative;

        .user-avatar {
          cursor: pointer;
          width: 40px;
          height: 40px;
          border-radius: 10px;
        }

        .el-icon-caret-bottom {
          cursor: pointer;
          position: absolute;
          right: -20px;
          top: 25px;
          font-size: 12px;
        }
      }
    }
  }
}
</style>

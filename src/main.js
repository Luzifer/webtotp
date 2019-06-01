import Vue from 'vue'
import BootstrapVue from 'bootstrap-vue'
import VueQr from 'vue-qr'

import 'bootstrap/dist/css/bootstrap.css'
import 'bootswatch/dist/darkly/bootstrap.css'

import app from './app.vue'

Vue.use(BootstrapVue)
Vue.use(VueQr)

new Vue({
  el: '#app',
  components: { app },
  render: c => c('app'),
})

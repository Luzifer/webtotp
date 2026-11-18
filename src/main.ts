import 'bootstrap/dist/css/bootstrap.css' // Bootstrap 5 Styles

import { createApp, h } from 'vue'

import App from './app.vue'

const app = createApp({
  name: 'WebTOTP',

  render() {
    return h(App)
  },
})

app.mount('#app')

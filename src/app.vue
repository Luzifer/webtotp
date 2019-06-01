<template>
  <div id="app">

    <b-navbar toggleable="lg" type="dark" variant="primary">
      <b-navbar-brand href="#" @click="blankSecret">WebTOTP</b-navbar-brand>
    </b-navbar>

    <b-container>
      <b-row class="justify-content-center mt-5">
        <b-col cols="12" md="6">

          <b-card header="Your code currently is..." v-if="code">
            <b-card-text class="text-center">
              <b-input
                class="code text-center"
                @click="copy($event)"
                readonly
                ref="code"
                title="click to copy"
                :value="code"
                v-b-tooltip:hover
                />

                <p class="mb-0"><a href="#" @click.prevent="showQR = !showQR">Toggle QR-Code</a></p>

                <p class="my-5" v-if="showQR"><vue-qr :text="qrURL" :size="200" :dotScale="1.0" /></p>
            </b-card-text>

            <b-progress
              class="justify-content-center"
              :max="30000"
              slot="footer"
              :value="timeLeft"
              />

          </b-card>

          <b-card header="Set secret..." v-else>
            <b-form-group label="Secret (Base32 encoded or plain):">
              <b-form-input v-model="secret" trim></b-form-input>
            </b-form-group>
            <div class="text-right">
              <b-btn @click="updateSecret" variant="success">Get code!</b-btn>
            </div>
          </b-card>

        </b-col>
      </b-row>
    </b-container>

  </div>
</template>

<script>
import otp from 'otp'

export default {
  name: 'app',

  computed: {
    qrURL() {
      return otp({ secret: this.secret }).totpURL
    },
  },

  data() {
    return {
      code: null,
      secret: null,
      showQR: false,
      ticker: null,
      timeLeft: 0,
    }
  },

  methods: {
    blankSecret() {
      if (this.ticker) {
        window.clearTimeout(this.ticker)
      }

      this.code = ''
      this.secret = ''
      this.showQR = false
      window.location.hash = ''
    },

    copy(evt) {
      evt.target.select()
      document.execCommand("copy")
    },

    hashUpdate() {
      if (window.location.hash === '') {
        this.blankSecret()
        return
      }

      this.secret = window.location.hash.substr(1)
      this.updateCode()
    },

    updateCode() {
      if (this.secret) {
        this.code = otp({ secret: this.secret }).totp()
        this.timeLeft = 30000 - new Date().getTime() % 30000
      }

      this.ticker = window.setTimeout(() => this.updateCode(), 250)
    },

    updateSecret() {
      window.location.hash = this.secret
      this.updateCode()
    },
  },

  mounted() {
    this.hashUpdate()
    window.onhashchange = () => this.hashUpdate()
  },
}
</script>

<style scoped>
.code {
  background-color: transparent;
  color: white;
  cursor: pointer;
  font-size: 2.5em;
  letter-spacing: 0.5em;
}
</style>


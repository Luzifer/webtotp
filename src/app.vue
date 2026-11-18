<template>
  <div id="app">
    <nav
      class="navbar bg-primary-subtle"
    >
      <div class="container-fluid">
        <a
          class="navbar-brand"
          href="#"
          @click="blankSecret"
        >
          WebTOTP
        </a>
      </div>
    </nav>

    <div class="container">
      <div class="row justify-content-center mt-5">
        <div class="col-12 col-md-6">
          <div
            v-if="code"
            class="card"
          >
            <div class="card-header">
              Your current code
            </div>

            <div class="card-body text-center">
              <input
                v-tooltip
                class="form-control code text-center"
                readonly
                title="click to copy"
                :value="code"
                @click="copy($event)"
              >

              <p class="mb-0">
                <a
                  href="#"
                  @click.prevent="showQR = !showQR"
                >Toggle QR-Code</a>
              </p>

              <p
                v-if="showQR"
                class="my-5"
              >
                <vue-qr
                  :text="qrURL"
                  :size="200"
                  :dot-scale="1.0"
                />
              </p>
            </div>

            <div class="card-footer">
              <div
                class="progress"
                role="progressbar"
                aria-label="Time remaining"
                aria-valuemin="0"
                aria-valuemax="30000"
                :aria-valuenow="timeLeft"
              >
                <div
                  class="progress-bar"
                  :style="{ width: (timeLeft / 30000) * 100 + '%' }"
                />
              </div>
            </div>
          </div>

          <div
            v-else
            class="card"
          >
            <div class="card-header">
              Set secret...
            </div>

            <div class="card-body">
              <div class="mb-3">
                <label
                  for="secret"
                  class="form-label"
                >Secret (Base32 encoded or plain):</label>

                <input
                  id="secret"
                  v-model.trim="secret"
                  class="form-control"
                >
              </div>

              <div class="text-end">
                <button
                  type="button"
                  class="btn btn-success"
                  @click="updateSecret"
                >
                  Get code!
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { markRaw } from 'vue'
import { OTP } from 'otp'
import Tooltip from 'bootstrap/js/dist/tooltip'
import VueQr from 'vue-qr'

export default {
  components: { VueQr },

  computed: {
    qrURL(): string {
      return this.otp?.totpURL || ''
    },
  },

  data() {
    return {
      code: null as string | null,
      otp: null as OTP | null,
      secret: null as string | null,
      showQR: false,
      ticker: null as number | null,
      timeLeft: 0,
    }
  },

  directives: {
    tooltip: {
      mounted(el: HTMLElement) {
        new Tooltip(el, { trigger: 'hover' })
      },

      unmounted(el: HTMLElement) {
        Tooltip.getInstance(el)?.dispose()
      },
    },
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

    async copy(evt: PointerEvent) {
      if (!this.code) {
        return
      }

      if (evt.target instanceof HTMLInputElement) {
        evt.target.select()
      }

      try {
        await navigator.clipboard.writeText(this.code)
      } catch (err) {
        console.error('Failed to copy the code', err)
      }
    },

    hashUpdate() {
      if (window.location.hash === '') {
        this.blankSecret()
        return
      }

      this.secret = window.location.hash.substring(1)
      this.updateSecret()
    },

    async updateCode() {
      if (this.secret && this.otp) {
        this.code = await this.otp.totp(new Date().getTime())
        this.timeLeft = 30000 - new Date().getTime() % 30000
      }

      this.ticker = window.setTimeout(() => this.updateCode(), 250)
    },

    updateSecret() {
      if (!this.secret) {
        return
      }

      window.location.hash = this.secret!
      this.otp = markRaw(OTP.parse(this.secret!))
      this.updateCode()
    },
  },

  mounted() {
    this.hashUpdate()
    window.onhashchange = () => this.hashUpdate()
  },

  name: 'WebTOTPApp',
}
</script>

<style scoped>
.code {
  background-color: transparent;
  color: inherit;
  cursor: pointer;
  font-size: 2.5em;
  letter-spacing: 0.5em;
}
</style>

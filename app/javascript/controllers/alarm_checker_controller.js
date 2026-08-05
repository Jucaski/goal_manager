import { Controller } from "@hotwired/stimulus"

const CHECK_INTERVAL = 15000
const ALARM_URL = "/scheduler/alarms"

export default class extends Controller {
  connect() {
    this.audio = new Audio()
    this.audio.preload = "auto"
    this.audioCtx = null
    this.unlocked = false
    this.fired = this.loadFired()

    this.unlockOnGesture()
    this.requestPermissionOnGesture()
    this.check()
    this.interval = setInterval(() => this.check(), CHECK_INTERVAL)
  }

  disconnect() {
    clearInterval(this.interval)
  }

  // Browsers block audio + notification prompts until the first user gesture.
  unlockOnGesture() {
    const unlock = () => {
      if (this.unlocked) return
      this.unlocked = true
      window.removeEventListener("pointerdown", unlock)
      window.removeEventListener("keydown", unlock)
      window.removeEventListener("touchstart", unlock)

      try {
        this.audioCtx = this.audioCtx || new (window.AudioContext || window.webkitAudioContext)()
        if (this.audioCtx.state === "suspended") this.audioCtx.resume()
      } catch (e) {}

      try {
        this.audio.muted = true
        this.audio.play().then(() => {
          this.audio.pause()
          this.audio.currentTime = 0
          this.audio.muted = false
        }).catch(() => {})
      } catch (e) {}
    }

    window.addEventListener("pointerdown", unlock)
    window.addEventListener("keydown", unlock)
    window.addEventListener("touchstart", unlock)
  }

  requestPermissionOnGesture() {
    const request = () => {
      if ("Notification" in window && Notification.permission === "default") {
        Notification.requestPermission().catch(() => {})
      }
      window.removeEventListener("pointerdown", request)
    }
    window.addEventListener("pointerdown", request)
  }

  async check() {
    if (!("Notification" in window)) return

    let alarms
    try {
      const today = this.todayKey()
      const resp = await fetch(`${ALARM_URL}?date=${today}`, { headers: { Accept: "application/json" } })
      alarms = await resp.json()
    } catch (e) {
      return
    }

    const now = Math.floor(Date.now() / 1000)
    alarms.forEach((alarm) => {
      // Build the epoch in the BROWSER's local timezone from wall-clock parts,
      // so the alarm rings at the wall-clock time the user set it for.
      const { year, month, day, hour, min } = alarm.start
      const startAt = Math.floor(new Date(year, month - 1, day, hour, min).getTime() / 1000)
      const alarmAt = startAt - (alarm.alarm_minutes_before || 0) * 60

      // Ring if we're at/after the alarm time and before the task is long past due.
      if (now < alarmAt) return
      if (now > startAt + 300) return
      if (this.fired.has(alarm.id)) return

      this.fired.add(alarm.id)
      this.persistFired()

      this.ring(alarm)
    })
  }

  ring(alarm) {
    this.playRingtone(alarm.ringtone)

    if (Notification.permission === "granted") {
      new Notification(`⏰ ${alarm.title}`, {
        body: alarm.tag ? `#${alarm.tag} · about to start` : "About to start"
      })
    }

    const row = document.querySelector(`[data-schedule-id="${alarm.id}"]`)
    if (row) {
      row.classList.add("scheduler-alarm-flash")
      setTimeout(() => row.classList.remove("scheduler-alarm-flash"), 5000)
    }
  }

  playRingtone(url) {
    if (url) {
      try {
        this.audio.src = url
        this.audio.load()
        const promise = this.audio.play()
        if (promise) promise.catch(() => this.playBeep())
      } catch (e) {
        this.playBeep()
      }
    } else {
      this.playBeep()
    }
  }

  playBeep() {
    try {
      this.audioCtx = this.audioCtx || new (window.AudioContext || window.webkitAudioContext)()
      if (this.audioCtx.state === "suspended") this.audioCtx.resume()

      const oscillator = this.audioCtx.createOscillator()
      const gain = this.audioCtx.createGain()
      oscillator.connect(gain)
      gain.connect(this.audioCtx.destination)
      oscillator.type = "sine"
      oscillator.frequency.value = 880
      gain.gain.setValueAtTime(0.3, this.audioCtx.currentTime)
      gain.gain.exponentialRampToValueAtTime(0.001, this.audioCtx.currentTime + 1.2)
      oscillator.start()
      oscillator.stop(this.audioCtx.currentTime + 1.2)
    } catch (e) {
      // audio not supported
    }
  }

  // Track fired alarms per day in localStorage so they don't re-ring on reload.
  loadFired() {
    try {
      const stored = JSON.parse(localStorage.getItem("scheduler_fired") || "{}")
      return new Set(stored[this.todayKey()] || [])
    } catch (e) {
      return new Set()
    }
  }

  persistFired() {
    try {
      const stored = JSON.parse(localStorage.getItem("scheduler_fired") || "{}")
      stored[this.todayKey()] = Array.from(this.fired)
      localStorage.setItem("scheduler_fired", JSON.stringify(stored))
    } catch (e) {}
  }

  todayKey() {
    const d = new Date()
    const month = String(d.getMonth() + 1).padStart(2, "0")
    const day = String(d.getDate()).padStart(2, "0")
    return `${d.getFullYear()}-${month}-${day}`
  }
}

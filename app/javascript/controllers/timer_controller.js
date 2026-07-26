import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["timeDisplay", "remainingLabel", "intervalLabel", "pausePlayBtn", "totalTimeLabel"]

  static values = {
    sets: Number,
    work: Number,
    rest: Number,
    isRunning: Boolean,
    templateId: Number
  }

  connect() {
    console.log("Timer controller connected")
    this.buildIntervals()
    this.currentIndex = 0
    this.paused = false
    this.intervalId = null
    this.startCurrentInterval()
  }

  buildIntervals() {
    this.intervals = []
    for (let i = 1; i <= this.setsValue; i++) {
      this.intervals.push({ type: "work", set: i, duration: this.workValue })
      if (i <= this.setsValue) {
        this.intervals.push({ type: "rest", set: i, duration: this.restValue })
      }
    }
  }

  remainingTotalSeconds(remaining) {
    let total = remaining
    for (let i = this.currentIndex + 1; i < this.intervals.length; i++) {
      total += this.intervals[i].duration
    }
    return total
  }

  startCurrentInterval() {
    if (this.intervalId) clearInterval(this.intervalId)
    const interval = this.intervals[this.currentIndex]
    let remaining = interval.duration
    this.updateDisplay(interval, remaining)

    this.intervalId = setInterval(() => {
      if (this.paused) return
      remaining--
      this.updateDisplay(interval, remaining)
      if (remaining <= 0) {
        this.nextInterval()
      }
    }, 1000)
  }

  updateDisplay(interval, remaining) {
    const totalRemaining = this.remainingTotalSeconds(remaining)
    const mins = Math.floor(remaining / 60)
    const secs = remaining % 60
    const formatted = `${mins.toString().padStart(2,"0")}:${secs.toString().padStart(2,"0")}`
    const totalMins = Math.floor(totalRemaining / 60)
    const totalSecs = totalRemaining % 60
    const totalFormatted = `${totalMins.toString().padStart(2, "0")}:${totalSecs.toString().padStart(2, "0")}`
    this.timeDisplayTarget.innerText = formatted
    this.remainingLabelTarget.innerText = `REMAINING ${formatted}`
    this.totalTimeLabelTarget.innerText = `TOTAL ${totalFormatted}`

    if (interval.type === "work") {
      this.intervalLabelTarget.innerText = `WORK ${interval.set}/${this.setsValue}`
      document.body.style.backgroundColor = "#2e7d32" // green
    } else {
      this.intervalLabelTarget.innerText = `REST ${interval.set}/${this.setsValue}`
      document.body.style.backgroundColor = "#1565c0" // blue
    }
  }

  nextInterval() {
    if (this.currentIndex + 1 < this.intervals.length) {
      this.currentIndex++
      this.startCurrentInterval()
    } else {
      this.completeWorkout()
    }
  }

  previousInterval() {
    if (this.currentIndex - 1 >= 0) {
      this.currentIndex--
      this.startCurrentInterval()
    }
  }

  togglePause() {
    this.paused = !this.paused
    this.pausePlayBtnTarget.innerText = this.paused ? "Play" : "Pause"
  }


  completeWorkout() {
  if (this.intervalId) clearInterval(this.intervalId)

  const token = document.querySelector('meta[name="csrf-token"]')?.content
  if (!token) {
    console.error("CSRF token not found")
    return
  }

  const params = {
    sets: this.setsValue,
    work: this.workValue,
    rest: this.restValue,
    is_running: this.isRunningValue,
    template_id: this.templateIdValue
  }

  fetch("/focus/complete", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": token
    },
    body: JSON.stringify(params)
  }).then(response => {
    if (response.redirected) {
      window.location.href = response.url
    } else {
      return response.text().then(html => {
        document.open()
        document.write(html)
        document.close()
      })
    }
  }).catch(err => console.error("Error:", err))
}
}

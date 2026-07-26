import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["totalLabel"]

  connect() {
    this.calculate()
  }

  calculate() {
    const sets = parseInt(this.element.querySelector("[name='sets']").value) || 0
    const work = parseInt(this.element.querySelector("[name='work']").value) || 0
    const rest = parseInt(this.element.querySelector("[name='rest']").value) || 0
    const totalSeconds = sets * (work + rest)
    const mins = Math.floor(totalSeconds / 60)
    const secs = totalSeconds % 60
    const formatted = `${mins.toString().padStart(2, "0")}:${secs.toString().padStart(2, "0")}`
    this.totalLabelTarget.textContent = `TOTAL ${formatted}`
  }
}

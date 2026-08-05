import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["schedules", "template"]

  add() {
    const content = this.templateTarget.innerHTML
    const wrapper = document.createElement("div")
    wrapper.innerHTML = content.trim()

    wrapper.querySelectorAll("[id]").forEach((el) => {
      const id = el.id.replace(/NEW_RECORD/g, `${Date.now()}`)
      el.id = id
      const label = el.closest("label")
      if (label) label.setAttribute("for", id)
    })

    wrapper.querySelectorAll("input, select, textarea").forEach((el) => {
      el.name = el.name.replace(/NEW_RECORD/g, `${Date.now()}`)
    })

    this.schedulesTarget.appendChild(wrapper.firstElementChild)
  }

  remove(event) {
    const field = event.target.closest("[data-schedule-builder-target=schedule]")
    if (!field) return

    const destroyInput = field.querySelector("input[name$='[_destroy]']")
    if (destroyInput) {
      destroyInput.value = "1"
      field.style.display = "none"
    } else {
      field.remove()
    }
  }
}

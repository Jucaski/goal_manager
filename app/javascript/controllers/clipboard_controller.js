import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  copy() {
    const value = this.element.dataset.clipboardCopy
    if (!value) return

    navigator.clipboard?.writeText(value).then(() => {
      this.element.textContent = "Copied!"
      setTimeout(() => {
        this.element.textContent = "Copy"
      }, 1500)
    }).catch(() => {})
  }
}

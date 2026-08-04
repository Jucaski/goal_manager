import { Controller } from "@hotwired/stimulus"
import { speakText, speakSequence } from "controllers/tts_utils"

export default class extends Controller {
  static values = { text: String, enText: String, zhText: String, autoplay: Boolean }

  connect() {
    if (this.autoplayValue) this.speak()
  }

  speak() {
    const parts = []
    if (this.enTextValue) parts.push({ text: this.enTextValue, lang: "en-US" })
    if (this.zhTextValue) parts.push({ text: this.zhTextValue, lang: "zh-CN" })
    if (!parts.length && this.textValue) parts.push({ text: this.textValue })

    if (parts.length > 1) {
      speakSequence(parts)
    } else if (parts.length === 1) {
      speakText(parts[0].text)
    }
  }
}

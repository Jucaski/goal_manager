import { Controller } from "@hotwired/stimulus"
import { speakText, speakSequence } from "controllers/tts_utils"

export default class extends Controller {
  static targets = ["back", "rating", "showAnswer"]
  static values = {
    ttsFront: Boolean,
    ttsBack: Boolean,
    frontText: String,
    backText: String,
    backEnText: String
  }

  connect() {
    if (this.ttsFrontValue && this.frontTextValue) {
      speakText(this.frontTextValue)
    }
  }

  reveal() {
    this.backTarget.classList.remove("d-none")
    this.ratingTarget.classList.remove("d-none")
    this.showAnswerTarget.classList.add("d-none")

    if (this.ttsBackValue) this.speakBack()
  }

  speakBack() {
    const parts = []
    if (this.backEnTextValue) parts.push({ text: this.backEnTextValue, lang: "en-US" })
    if (this.backTextValue) parts.push({ text: this.backTextValue, lang: "zh-CN" })

    if (parts.length > 1) {
      speakSequence(parts)
    } else if (parts.length === 1) {
      speakText(parts[0].text)
    }
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["back", "rating", "showAnswer"]
  static values = {
    ttsFront: Boolean,
    ttsBack: Boolean,
    frontText: String,
    backText: String
  }

  connect() {
    if (this.ttsFrontValue && this.frontTextValue) {
      this.speak(this.frontTextValue)
    }
  }

  reveal() {
    this.backTarget.classList.remove("d-none")
    this.ratingTarget.classList.remove("d-none")
    this.showAnswerTarget.classList.add("d-none")

    if (this.ttsBackValue && this.backTextValue) {
      this.speak(this.backTextValue)
    }
  }

  speak(text) {
    if (!("speechSynthesis" in window)) return

    const utterance = new SpeechSynthesisUtterance(text)
    utterance.lang = "zh-CN"

    const speak = () => {
      const zhVoice = speechSynthesis.getVoices().find((v) => v.lang && v.lang.toLowerCase().startsWith("zh"))
      if (zhVoice) utterance.voice = zhVoice
      speechSynthesis.cancel()
      speechSynthesis.speak(utterance)
    }

    if (speechSynthesis.getVoices().length === 0) {
      speechSynthesis.addEventListener("voiceschanged", speak, { once: true })
    } else {
      speak()
    }
  }
}

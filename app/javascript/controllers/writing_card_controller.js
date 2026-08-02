import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas", "strikes", "summary"]
  static values = { characters: Array, ratingUrl: String }

  connect() {
    this.totalStrikes = 0
    this.currentCharIndex = 0
    this.outlineShown = false
    this.writer = null
    this.updateStrikes()
    this.startCharacter(0)
  }

  startCharacter(index) {
    if (index >= this.charactersValue.length) {
      this.complete()
      return
    }

    this.currentCharIndex = index
    const character = this.charactersValue[index]
    const canvas = this.canvasTargets[index]

    this.canvasTargets.forEach((c, i) => c.classList.toggle("d-none", i !== index))

    const status = canvas.querySelector("[data-writing-status]")
    status.classList.remove("d-none")

    if (typeof HanziWriter === "undefined") {
      this.showStatus(canvas, "hanzi-writer library failed to load on this device.")
      return
    }

    let charData
    try {
      charData = JSON.parse(canvas.dataset.charData)
    } catch (e) {
      charData = null
    }

    if (!charData || !Array.isArray(charData.strokes) || charData.strokes.length === 0) {
      this.showStatus(canvas, "No stroke data for this character. Was chinese:import_hanzi run on this server?")
      return
    }

    status.classList.add("d-none")

    try {
      this.startQuiz(canvas, character, charData)
    } catch (e) {
      this.showStatus(canvas, `Failed to start drawing: ${e.message}`)
    }
  }

  startQuiz(canvas, character, charData) {
    this.writer = HanziWriter.create(canvas, character, {
      width: 220,
      height: 220,
      padding: 10,
      showCharacter: false,
      showOutline: false,
      acceptBackwardsStrokes: false,
      charDataLoader: (char, onComplete) => onComplete(charData)
    })

    this.writer.quiz({
      showHintAfterMisses: 3,
      onMistake: (data) => {
        this.totalStrikes += 1
        this.updateStrikes()
        if (this.totalStrikes >= 3 && !this.outlineShown) {
          this.outlineShown = true
          this.writer.showOutline()
        }
      },
      onComplete: () => {
        this.writer.hideCharacter()
        this.startCharacter(this.currentCharIndex + 1)
      }
    })
  }

  showStatus(canvas, message) {
    const status = canvas.querySelector("[data-writing-status]")
    status.textContent = message
    status.classList.remove("d-none")
  }

  updateStrikes() {
    this.strikesTarget.textContent = this.totalStrikes
  }

  complete() {
    const rating = this.totalStrikes === 0 ? 4 : this.totalStrikes === 1 ? 3 : this.totalStrikes === 2 ? 2 : 1
    const label = { 4: "Easy", 3: "Good", 2: "Hard", 1: "Again" }[rating]

    const summary = this.summaryTarget
    summary.classList.remove("d-none")
    summary.querySelector("[data-writing-result]").textContent = `${label} (${this.totalStrikes} strike${this.totalStrikes === 1 ? "" : "s"})`

    const token = document.querySelector('meta[name="csrf-token"]')?.content
    setTimeout(() => {
      fetch(this.ratingUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": token
        },
        body: JSON.stringify({ rating })
      }).then((resp) => {
        if (resp.redirected) {
          window.location.href = resp.url
        } else {
          window.location.reload()
        }
      }).catch(() => window.location.reload())
    }, 1200)
  }
}

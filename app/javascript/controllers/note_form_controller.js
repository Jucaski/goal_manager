import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["typedSection", "handwrittenSection", "ocrText", "drawingPad", "status"]

  connect() {
    this.tesseractReady = typeof Tesseract !== "undefined"
    this.toggle()
  }

  selectedType() {
    const selected = this.element.querySelector("input[name='note[note_type]']:checked")
    return selected ? selected.value : "typed"
  }

  toggle() {
    const handwritten = this.selectedType() === "handwritten"
    this.typedSectionTarget.classList.toggle("d-none", handwritten)
    this.handwrittenSectionTarget.classList.toggle("d-none", !handwritten)
  }

  async submit(event) {
    if (this.selectedType() !== "handwritten") return

    event.preventDefault()
    const drawingController = this.drawingPadController
    if (!drawingController) {
      this.element.submit()
      return
    }

    this.statusTarget.classList.remove("d-none")
    this.statusTarget.textContent = "Reading handwriting…"

    let text = ""
    if (this.tesseractReady && drawingController.strokes.length > 0) {
      try {
        const dataUrl = drawingController.toDataURL()
        const result = await Tesseract.recognize(dataUrl, "eng", { logger: () => {} })
        text = (result.data && result.data.text || "").trim()
      } catch (error) {
        console.error("OCR failed:", error)
      }
    }

    this.ocrTextTarget.value = text
    this.statusTarget.textContent = text ? `Handwriting recognized: “${text.slice(0, 60)}”` : "Handwriting saved without recognizable text."
    this.statusTarget.classList.add("d-none")
    this.element.submit()
  }

  get drawingPadController() {
    return this.application.getControllerForElementAndIdentifier(this.drawingPadTarget, "drawing-pad")
  }
}

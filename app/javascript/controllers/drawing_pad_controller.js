import { Controller } from "@hotwired/stimulus"

const GROW_MARGIN = 150
const GROW_CHUNK_RATIO = 0.75

export default class extends Controller {
  static targets = ["canvas", "strokes"]
  static values = { readOnly: Boolean, strokes: Array }

  connect() {
    this.currentStroke = []
    this.isDrawing = false
    this.dpr = window.devicePixelRatio || 1
    this.canvas = this.canvasTarget
    this.ctx = this.canvas.getContext("2d")
    this.strokes = Array.isArray(this.strokesValue) ? this.strokesValue : []
    this.viewWidth = 0
    this.viewHeight = 0

    if (this.readOnlyValue) {
      this.viewHeight = 200
      this.fitToContent()
    } else {
      this.viewHeight = Math.round(window.innerHeight || 800)
      this.setBacking()
      this.bindDrawing()
      this.watchWidth()
    }
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  get visibleWidth() {
    return this.canvas.clientWidth || window.innerWidth || 600
  }

  // Keep backing store in sync with the container width (orientation/resize).
  watchWidth() {
    this.observer = new ResizeObserver((entries) => {
      const width = this.visibleWidth
      if (width && Math.abs(width - this.viewWidth) > 2) {
        this.viewWidth = width
        this.setBacking()
      }
    })
    this.observer.observe(this.canvas)
  }

  setBacking() {
    if (!this.viewWidth) this.viewWidth = this.visibleWidth
    this.canvas.width = Math.round(this.viewWidth * this.dpr)
    this.canvas.height = Math.round(this.viewHeight * this.dpr)
    this.canvas.style.width = "100%"
    this.canvas.style.height = `${this.viewHeight}px`
    this.ctx.setTransform(this.dpr, 0, 0, this.dpr, 0, 0)
    this.ctx.lineWidth = 4
    this.ctx.lineCap = "round"
    this.ctx.lineJoin = "round"
    this.ctx.strokeStyle = "currentColor"
    this.ctx.fillStyle = "currentColor"
    this.redraw()
  }

  // On the read-only page, size the canvas to the drawing content instead
  // of a fixed screen height, and scale to fit the current display width.
  fitToContent() {
    let maxX = 0
    let maxY = 0
    this.strokes.forEach((stroke) => {
      stroke.forEach((point) => {
        if (point.x > maxX) maxX = point.x
        if (point.y > maxY) maxY = point.y
      })
    })

    const displayWidth = this.visibleWidth
    this.displayScale = displayWidth > 0 && maxX > displayWidth ? displayWidth / maxX : 1
    this.viewHeight = Math.max(Math.round(maxY * this.displayScale + 60), 200)
    this.viewWidth = displayWidth
    this.setBacking()
  }

  bindDrawing() {
    const canvas = this.canvas
    canvas.style.touchAction = "none"
    canvas.addEventListener("pointerdown", this.onPointerDown)
    canvas.addEventListener("pointermove", this.onPointerMove)
    canvas.addEventListener("pointerup", this.onPointerUp)
    canvas.addEventListener("pointerleave", this.onPointerUp)
  }

  onPointerDown = (event) => {
    event.preventDefault()
    this.isDrawing = true
    this.currentStroke = []
    this.canvas.setPointerCapture(event.pointerId)
    this.addPoint(event)
  }

  onPointerMove = (event) => {
    if (!this.isDrawing) return
    this.addPoint(event)
  }

  onPointerUp = (event) => {
    if (!this.isDrawing) return
    this.isDrawing = false
    if (this.currentStroke.length > 0) {
      this.strokes.push(this.currentStroke)
      this.save()
    }
    this.currentStroke = []
  }

  addPoint(event) {
    const rect = this.canvas.getBoundingClientRect()
    const x = event.clientX - rect.left
    const y = event.clientY - rect.top
    this.growIfNeeded(y)

    if (this.currentStroke.length === 0) {
      this.currentStroke.push({ x, y })
      this.drawDot(x, y)
    } else {
      const last = this.currentStroke[this.currentStroke.length - 1]
      this.currentStroke.push({ x, y })
      this.drawLine(last.x, last.y, x, y)
    }
  }

  // Infinite scroll: extend the canvas downward and follow it so the pen
  // never runs out of room.
  growIfNeeded(canvasY) {
    if (canvasY < this.viewHeight - GROW_MARGIN) return

    const delta = Math.round((window.innerHeight || 800) * GROW_CHUNK_RATIO)
    this.viewHeight += delta
    this.setBacking()
    window.scrollBy(0, delta)
  }

  drawLine(x1, y1, x2, y2) {
    this.ctx.beginPath()
    this.ctx.moveTo(x1, y1)
    this.ctx.lineTo(x2, y2)
    this.ctx.stroke()
  }

  drawDot(x, y) {
    this.ctx.beginPath()
    this.ctx.arc(x, y, this.ctx.lineWidth / 2, 0, Math.PI * 2)
    this.ctx.fill()
  }

  redraw() {
    this.ctx.clearRect(0, 0, this.viewWidth, this.viewHeight)
    this.ctx.save()
    if (this.displayScale) this.ctx.scale(this.displayScale, this.displayScale)

    const strokes = this.currentStroke.length ? this.strokes.concat([this.currentStroke]) : this.strokes
    strokes.forEach((stroke) => {
      if (stroke.length === 0) return
      this.ctx.beginPath()
      this.ctx.moveTo(stroke[0].x, stroke[0].y)
      stroke.slice(1).forEach((point) => this.ctx.lineTo(point.x, point.y))
      this.ctx.stroke()
    })
    this.ctx.restore()
  }

  save() {
    this.strokesTarget.value = JSON.stringify(this.strokes)
  }

  undo() {
    if (this.strokes.length === 0) return
    this.strokes.pop()
    this.save()
    this.setBacking()
  }

  clear() {
    this.strokes = []
    this.save()
    this.setBacking()
  }

  toDataURL() {
    return this.canvas.toDataURL("image/png")
  }
}

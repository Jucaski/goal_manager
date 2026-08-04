function hasChinese(text) {
  return /[\u3400-\u9fff]/u.test(text || "")
}

function langFor(text) {
  return hasChinese(text) ? "zh-CN" : "en-US"
}

function normalized(lang) {
  return (lang || "").toLowerCase().replace("_", "-")
}

function findVoice(lang) {
  const voices = window.speechSynthesis.getVoices()
  const wanted = normalized(lang)
  const base = wanted.split("-")[0]
  return (
    voices.find((v) => normalized(v.lang).startsWith(wanted)) ||
    voices.find((v) => normalized(v.lang).startsWith(base))
  )
}

function whenVoicesReady(cb) {
  let done = false
  const run = () => {
    if (done) return
    done = true
    cb()
  }
  if (window.speechSynthesis.getVoices().length > 0) {
    run()
  } else {
    window.speechSynthesis.addEventListener("voiceschanged", run, { once: true })
    setTimeout(run, 500)
  }
}

function utter(text, lang) {
  const u = new SpeechSynthesisUtterance(text)
  u.lang = lang || langFor(text)
  const voice = findVoice(u.lang)
  if (voice) u.voice = voice
  return u
}

// cancel + delayed speak avoids Android/Chrome dropping the utterance
function speakNow(u) {
  window.speechSynthesis.cancel()
  setTimeout(() => window.speechSynthesis.speak(u), 50)
}

export function speakText(text) {
  if (!("speechSynthesis" in window) || !text) return
  whenVoicesReady(() => speakNow(utter(text)))
}

export function speakSequence(items) {
  if (!("speechSynthesis" in window)) return
  const parts = (items || []).filter((p) => p && p.text)
  if (!parts.length) return
  whenVoicesReady(() => {
    window.speechSynthesis.cancel()
    let i = 0
    const next = () => {
      if (i >= parts.length) return
      const part = parts[i++]
      const u = utter(part.text, part.lang)
      u.onend = next
      u.onerror = next
      setTimeout(() => window.speechSynthesis.speak(u), 50)
    }
    next()
  })
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  enableNotifications() {
    if ("Notification" in window) {
      Notification.requestPermission().then((permission) => {
        if (permission === "granted") {
          new Notification("Alarm notifications enabled")
        }
      })
    } else {
      alert("This browser does not support notifications.")
    }
  }
}

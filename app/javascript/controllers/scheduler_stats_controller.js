import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["byDay", "byTag", "byTemplate"]
  static values = {
    byDayLabels: Array,
    byDayValues: Array,
    byTagLabels: Array,
    byTagValues: Array,
    byTemplateLabels: Array,
    byTemplateValues: Array
  }

  connect() {
    if (typeof Chart === "undefined") return

    const colors = [
      "#8b5cf6", "#22c55e", "#3b82f6", "#f59e0b", "#ef4444",
      "#14b8a6", "#ec4899", "#84cc16", "#f97316", "#06b6d4"
    ]

    new Chart(this.byDayTarget, {
      type: "bar",
      data: {
        labels: this.byDayLabelsValue,
        datasets: [ {
          label: "Minutes",
          data: this.byDayValuesValue,
          backgroundColor: "#8b5cf6"
        } ]
      },
      options: { scales: { y: { beginAtZero: true } } }
    })

    new Chart(this.byTagTarget, {
      type: "doughnut",
      data: {
        labels: this.byTagLabelsValue,
        datasets: [ {
          data: this.byTagValuesValue,
          backgroundColor: this.byTagLabelsValue.map((_, i) => colors[i % colors.length])
        } ]
      }
    })

    new Chart(this.byTemplateTarget, {
      type: "bar",
      data: {
        labels: this.byTemplateLabelsValue,
        datasets: [ {
          label: "Minutes",
          data: this.byTemplateValuesValue,
          backgroundColor: this.byTemplateLabelsValue.map((_, i) => colors[i % colors.length])
        } ]
      },
      options: { indexAxis: "y", scales: { x: { beginAtZero: true } } }
    })
  }
}

module FlashcardDecksHelper
  CHINESE_WORD_FIELDS = {
    "word" => "Word",
    "pinyin" => "Pinyin",
    "part_of_speech" => "Part of Speech",
    "translation" => "Translation",
    "level" => "Level",
    "decomposition" => "Decomposition",
    "etymology" => "Etymology",
    "radical" => "Radical",
    "grammar_note" => "Grammar Note",
    "example_zh1" => "Example (ZH)",
    "example_en1" => "Example (EN)",
    "example_zh2" => "Example 2 (ZH)",
    "example_en2" => "Example 2 (EN)",
    "example_zh3" => "Example 3 (ZH)",
    "example_en3" => "Example 3 (EN)"
  }.freeze

  WRITING_FIELDS = %w[word part_of_speech grammar_note example_zh1 example_en1].freeze

  PHASES = [ :new, :learning, :young, :mature ].freeze

  def phase_label(phase)
    { new: "New", learning: "Learning", young: "Young", mature: "Mature" }.fetch(phase, phase.to_s)
  end

  def heatmap_days(review_counts_by_day, weeks: 52)
    finish = Date.current
    start = finish - (weeks * 7 - 1).days
    start -= start.wday

    days = []
    while start <= finish
      7.times do |i|
        day = start + i
        count = review_counts_by_day[day] || 0
        days << { date: day, count: count, intensity: heat_intensity(count) }
      end
      start += 7
    end
    days
  end

  def heatmap_week_labels(review_counts_by_day, weeks: 52)
    finish = Date.current
    start = finish - (weeks * 7 - 1).days
    start -= start.wday

    labels = []
    current_month = nil
    while start <= finish
      label = ""
      if start.month != current_month
        label = start.strftime("%b")
        current_month = start.month
      end
      labels << label
      start += 7
    end
    labels
  end

  def heat_intensity(count)
    return 0 if count <= 0
    return 1 if count <= 2
    return 2 if count <= 4
    return 3 if count <= 7

    4
  end

  def flashcard_field_label(field)
    CHINESE_WORD_FIELDS.fetch(field, field.titleize)
  end

  def flashcard_field_value(word, field)
    value = word.public_send(field)
    return render_etymology(value) if field == "etymology"

    value
  end

  def render_etymology(value)
    return "" if value.blank?

    unless value.is_a?(Hash)
      return value
    end

    parts = []
    parts << value["type"].to_s.titleize if value["type"].present?
    parts << value["hint"] if value["hint"].present?
    parts << value["phonetic"] if value["phonetic"].present?
    parts << value["semantic"] if value["semantic"].present?
    parts.join(" — ")
  end
end

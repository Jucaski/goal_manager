module EtymologyParser
  # Parses a Python-style dict literal from the HSK CSV, e.g.
  #   {'type': 'ideographic', 'hint': "To bring a friend 友 into one's house 冖"}
  #   {'type': 'pictophonetic', 'phonetic': '巴', 'semantic': '父', 'hint': 'father'}
  # into a Ruby hash. Falls back to returning the raw string if it cannot be parsed.
  def self.parse(raw)
    return nil if raw.blank?

    text = raw.strip
    return JSON.parse(text) if json?(text)

    hash = {}
    text.scan(/'([^']+)':\s*("(?:[^"\\]|\\.)*"|'[^']*')/) do |key, value|
      hash[key] = unquote(value)
    end
    hash.presence || raw
  end

  def self.json?(text)
    text.start_with?("{") && JSON.parse(text) && true
  rescue JSON::ParserError
    false
  end

  def self.unquote(value)
    if value.start_with?('"')
      value[1..-2].gsub('\\"', '"').gsub("\\\\", "\\")
    else
      value[1..-2]
    end
  end
end

module EtymologyParser
  # Parses the etymology column from the HSK CSV into a Hash or Array of Hashes.
  #
  # Supported formats:
  #   Single JSON object:  {"type": "ideographic", "hint": "..."}
  #   Multiple JSON objects: {"type": "pictophonetic", ...}, {"type": "ideographic", ...}
  #   Legacy Python-dict literal: {'type': 'ideographic', 'hint': '...'}
  def self.parse(raw)
    return nil if raw.blank?

    text = raw.strip
    return JSON.parse(text) if json?(text)

    if text.start_with?("{")
      array_text = "[#{text}]"
      return JSON.parse(array_text) if json?(array_text)
    end

    parse_python_dict(text) || raw
  end

  def self.json?(text)
    JSON.parse(text)
    true
  rescue JSON::ParserError
    false
  end

  def self.parse_python_dict(text)
    hash = {}
    text.scan(/'([^']+)':\s*("(?:[^"\\]|\\.)*"|'[^']*')/) do |key, value|
      hash[key] = unquote(value)
    end
    hash.presence
  end

  def self.unquote(value)
    if value.start_with?('"')
      value[1..-2].gsub('\\"', '"').gsub("\\\\", "\\")
    else
      value[1..-2]
    end
  end
end

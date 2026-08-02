class ChineseWordImporter
  COLUMN_MAP = {
    "word" => "word",
    "pinyin" => "pinyin",
    "Part Of Speech" => "part_of_speech",
    "Translation" => "translation",
    "level" => "level",
    "decomposition" => "decomposition",
    "etymology" => "etymology",
    "radical" => "radical",
    "grammar_note" => "grammar_note",
    "example_zh1" => "example_zh1",
    "example_en1" => "example_en1",
    "example_zh2" => "example_zh2",
    "example_en2" => "example_en2",
    "example_zh3" => "example_zh3",
    "example_en3" => "example_en3"
  }.freeze

  def self.import!(path:)
    new(path: path).import!
  end

  def initialize(path:)
    @path = path
  end

  def import!
    imported = 0
    updated = 0

    CSV.foreach(@path, headers: true) do |row|
      attrs = {}
      COLUMN_MAP.each do |csv_col, model_col|
        attrs[model_col] = row[csv_col]
      end
      attrs["level"] = attrs["level"].to_i if attrs["level"].present?
      if attrs["etymology"].present?
        parsed = EtymologyParser.parse(attrs["etymology"])
        attrs["etymology"] = parsed.is_a?(String) ? parsed : parsed.to_json
      end

      record = ChineseWord.find_or_initialize_by(word: attrs["word"])
      was_new = record.new_record?
      record.assign_attributes(attrs)
      record.save!
      was_new ? imported += 1 : updated += 1
    end

    { imported: imported, updated: updated }
  end
end

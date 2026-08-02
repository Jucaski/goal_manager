class HanziImporter
  def self.import!(path:)
    new(path: path).import!
  end

  def initialize(path:)
    @path = path
  end

  def import!
    count = 0
    File.foreach(@path) do |line|
      data = JSON.parse(line)
      record = Hanzi.find_or_initialize_by(character: data["character"])
      record.strokes = data["strokes"] || []
      record.medians = data["medians"] || []
      record.save!
      count += 1
    end
    count
  end
end

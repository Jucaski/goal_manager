class Note < ApplicationRecord
  TYPES = [ "typed", "handwritten" ].freeze

  belongs_to :user

  validates :title, presence: true
  validates :note_type, inclusion: { in: TYPES }
  validates :content, presence: true, if: :typed?
  validate :drawing_present, if: :handwritten?

  scope :ordered, -> { order(created_at: :desc) }

  scope :search, ->(query) {
    q = "%#{sanitize_sql_like(query)}%"
    where("title ILIKE :q OR content ILIKE :q OR ocr_text ILIKE :q OR EXISTS (SELECT 1 FROM unnest(tags) AS tag WHERE tag ILIKE :q)", q: q)
  }

  scope :with_tag, ->(tag) { where(":tag = ANY(tags)", tag: tag) }

  def typed?
    note_type == "typed"
  end

  def handwritten?
    note_type == "handwritten"
  end

  def tags_string=(value)
    self.tags = value.to_s.split(/[,#\s]+/).map { |t| t.strip.delete_prefix("#") }.reject(&:blank?).uniq
  end

  def tags_string
    tags.reject(&:blank?).map { |t| "##{t}" }.join(" ")
  end

  def drawing_data=(value)
    parsed = value.is_a?(String) ? (JSON.parse(value) rescue []) : value
    super(parsed)
  end

  def preview
    body = typed? ? content : ocr_text
    body.to_s.strip.present? ? body.to_s.strip[0, 140] : "(no text)"
  end

  private

  def drawing_present
    errors.add(:base, "Please draw something before saving.") if Array(drawing_data).empty?
  end
end

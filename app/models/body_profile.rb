class BodyProfile < ApplicationRecord
  belongs_to :user

  GENDERS = [ [ "Female", "female" ], [ "Male", "male" ] ].freeze

  validates :gender, inclusion: { in: %w[female male], message: "select a body type" }, allow_blank: true
  validates :height_cm, numericality: { greater_than: 0 }, allow_nil: true

  def complete?
    gender.present? && height_cm.present?
  end

  def gender_label
    { "female" => "Female", "male" => "Male" }[gender]
  end

  def male?
    gender == "male"
  end
end

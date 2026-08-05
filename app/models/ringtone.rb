class Ringtone < ApplicationRecord
  belongs_to :user
  has_one_attached :audio

  validates :name, presence: true
  validates :audio, presence: true
  validate :audio_must_be_audio

  scope :ordered, -> { order(:name) }

  def audio_url
    return nil unless audio.attached?

    Rails.application.routes.url_helpers.rails_blob_url(audio, only_path: true)
  end

  private

  def audio_must_be_audio
    return unless audio.attached?
    return if audio.content_type.to_s.start_with?("audio/")

    errors.add(:audio, "must be an audio file")
  end
end

class Hanzi < ApplicationRecord
  self.table_name = "hanzi"
  self.primary_key = "character"

  validates :character, presence: true, uniqueness: true
end

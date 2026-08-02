class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :habits, dependent: :destroy
  has_many :day_habits, dependent: :destroy
  has_many :financial_entries, dependent: :destroy
  has_many :workout_templates, dependent: :destroy
  has_many :workout_sessions, dependent: :destroy
  has_many :books, dependent: :destroy
  has_many :yearly_goals, dependent: :destroy
  has_many :monthly_plans, dependent: :destroy
  has_many :planned_books, dependent: :destroy
  has_many :reading_logs, dependent: :destroy
  has_many :counters, dependent: :destroy
  has_many :flashcard_decks, dependent: :destroy
  has_many :flashcards, dependent: :destroy
  has_many :review_logs, dependent: :destroy
end

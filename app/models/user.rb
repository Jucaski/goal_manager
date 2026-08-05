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
  has_many :notes, dependent: :destroy
  has_many :ringtones, dependent: :destroy
  has_many :task_templates, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :time_logs, dependent: :destroy
  has_many :water_entries, dependent: :destroy

  # Returns the user's "Run" task (title "Run"), creating a Running template
  # with that task on first use so running workouts show up in the stats.
  def find_or_create_run_task
    run_task = tasks.find_by("lower(title) = ?", "run")
    return run_task if run_task

    template = task_templates.find_by("lower(name) = ?", "running") ||
               task_templates.create!(name: "Running", start_date: Date.current, days_of_week: (0..6).to_a)

    template.tasks.create!(
      title: "Run",
      tag: "running",
      alarm_minutes_before: 0,
      start_time: Time.current,
      duration_minutes: 30
    )
  end
end
